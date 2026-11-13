import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'image_cache_config.dart';

/// Disk backed image cache for every platform that exposes `dart:io`.
///
/// Files are stored in a dedicated folder inside the system temporary
/// directory together with a small JSON sidecar holding the validators
/// required for conditional requests.
class ImageCacheStore {
  /// The shared store instance.
  static final ImageCacheStore instance = ImageCacheStore._();

  ImageCacheStore._();

  ImageCacheConfig _config = const ImageCacheConfig();

  final Map<String, Future<Uint8List>> _inFlight = {};

  Directory? _directory;
  HttpClient? _client;
  DateTime? _lastCleanup;

  /// The active configuration.
  ImageCacheConfig get config => _config;

  /// Replaces the active configuration.
  void configure(ImageCacheConfig config) {
    final folderChanged = config.folderName != _config.folderName;

    _config = config;

    if (folderChanged) {
      _directory = null;
    }
  }

  /// Returns the bytes for [url], downloading them only when required.
  Future<Uint8List> load(
    String url, {
    String? cacheKey,
    Map<String, String>? headers,
    void Function(int received, int? total)? onProgress,
  }) {
    final key = cacheKey ?? url;

    final pending = _inFlight[key];

    if (pending != null) {
      return pending;
    }

    final future = _load(
      url: url,
      key: key,
      headers: headers,
      onProgress: onProgress,
    ).whenComplete(() {
      _inFlight.remove(key);
    });

    _inFlight[key] = future;

    return future;
  }

  Future<Uint8List> _load({
    required String url,
    required String key,
    Map<String, String>? headers,
    void Function(int received, int? total)? onProgress,
  }) async {
    final fileKey = imageCacheFileKey(key);

    final directory = await _ensureDirectory();

    final file = File('${directory.path}${Platform.pathSeparator}$fileKey.bin');

    final metaFile =
        File('${directory.path}${Platform.pathSeparator}$fileKey.json');

    final _CacheEntry? entry = await _readEntry(file, metaFile);

    if (entry != null && !entry.isStale(_config.staleAfter)) {
      return entry.bytes;
    }

    try {
      final downloaded = await _download(
        url: url,
        headers: headers,
        validators: entry?.meta,
        onProgress: onProgress,
      );

      if (downloaded == null) {
        /*
         * 304 Not Modified. The cached payload is still valid, so only the
         * freshness timestamp is refreshed.
         */
        if (entry != null) {
          await _writeMeta(
            metaFile,
            entry.meta.refreshed(),
          );

          return entry.bytes;
        }

        throw ImageCacheException(
          'Server returned 304 without a cached copy.',
          url: url,
          statusCode: HttpStatus.notModified,
        );
      }

      await _writeEntry(
        file: file,
        metaFile: metaFile,
        bytes: downloaded.bytes,
        meta: downloaded.meta,
      );

      unawaited(_cleanup());

      return downloaded.bytes;
    } catch (error) {
      /*
       * Offline or failing server: a stale copy is far better than an error
       * widget, so it is served when one exists.
       */
      if (entry != null) {
        return entry.bytes;
      }

      if (error is ImageCacheException) {
        rethrow;
      }

      throw ImageCacheException(
        error.toString(),
        url: url,
      );
    }
  }

  Future<_DownloadResult?> _download({
    required String url,
    required Map<String, String>? headers,
    required _CacheMeta? validators,
    void Function(int received, int? total)? onProgress,
  }) async {
    final Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (_) {
      throw ImageCacheException(
        'Invalid image URL.',
        url: url,
      );
    }

    if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      throw ImageCacheException(
        'Only http and https URLs are supported.',
        url: url,
      );
    }

    final client = _ensureClient();

    final request = await client.getUrl(uri).timeout(_config.timeout);

    headers?.forEach(request.headers.set);

    final etag = validators?.etag;

    if (etag != null && etag.isNotEmpty) {
      request.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
    }

    final lastModified = validators?.lastModified;

    if (lastModified != null && lastModified.isNotEmpty) {
      request.headers.set(HttpHeaders.ifModifiedSinceHeader, lastModified);
    }

    final response = await request.close().timeout(_config.timeout);

    if (response.statusCode == HttpStatus.notModified) {
      await response.drain<void>();

      return null;
    }

    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();

      throw ImageCacheException(
        'Failed to download image.',
        url: url,
        statusCode: response.statusCode,
      );
    }

    final total = response.contentLength >= 0 ? response.contentLength : null;

    final builder = BytesBuilder(copy: false);

    var received = 0;

    await for (final chunk in response.timeout(_config.timeout)) {
      builder.add(chunk);

      received += chunk.length;

      onProgress?.call(received, total);
    }

    final bytes = builder.takeBytes();

    if (bytes.isEmpty) {
      throw ImageCacheException(
        'Server returned an empty image body.',
        url: url,
        statusCode: response.statusCode,
      );
    }

    return _DownloadResult(
      bytes: bytes,
      meta: _CacheMeta(
        url: url,
        etag: response.headers.value(HttpHeaders.etagHeader),
        lastModified: response.headers.value(HttpHeaders.lastModifiedHeader),
        downloadedAt: DateTime.now(),
      ),
    );
  }

  /// Removes a single entry from the disk cache.
  Future<void> evict(String key) async {
    _inFlight.remove(key);

    final fileKey = imageCacheFileKey(key);

    final directory = await _ensureDirectory();

    await _deleteQuietly(
      File('${directory.path}${Platform.pathSeparator}$fileKey.bin'),
    );

    await _deleteQuietly(
      File('${directory.path}${Platform.pathSeparator}$fileKey.json'),
    );
  }

  /// Deletes every cached file.
  Future<void> clear() async {
    _inFlight.clear();

    final directory = await _ensureDirectory();

    try {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (error) {
      debugPrint('CustomCachedImage: cache clear failed: $error');
    }

    _directory = null;
  }

  /// Total size of the cache folder in bytes.
  Future<int> currentSizeInBytes() async {
    final directory = await _ensureDirectory();

    var total = 0;

    try {
      await for (final entity in directory.list()) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    } catch (error) {
      debugPrint('CustomCachedImage: cache size lookup failed: $error');
    }

    return total;
  }

  Future<Directory> _ensureDirectory() async {
    final cached = _directory;

    if (cached != null) {
      return cached;
    }

    final directory = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      '${_config.folderName}',
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    _directory = directory;

    return directory;
  }

  HttpClient _ensureClient() {
    final client = _client ??= HttpClient()
      ..connectionTimeout = _config.timeout
      ..autoUncompress = true;

    client.userAgent = 'custom_cached_image';

    return client;
  }

  Future<_CacheEntry?> _readEntry(File file, File metaFile) async {
    try {
      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        return null;
      }

      final meta = await _readMeta(metaFile);

      return _CacheEntry(
        bytes: bytes,
        meta: meta ?? _CacheMeta(downloadedAt: DateTime.now()),
      );
    } catch (error) {
      debugPrint('CustomCachedImage: cache read failed: $error');

      return null;
    }
  }

  Future<_CacheMeta?> _readMeta(File metaFile) async {
    try {
      if (!await metaFile.exists()) {
        return null;
      }

      final decoded = jsonDecode(await metaFile.readAsString());

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return _CacheMeta.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeEntry({
    required File file,
    required File metaFile,
    required Uint8List bytes,
    required _CacheMeta meta,
  }) async {
    try {
      await file.writeAsBytes(bytes, flush: false);

      await _writeMeta(metaFile, meta);
    } catch (error) {
      debugPrint('CustomCachedImage: cache write failed: $error');
    }
  }

  Future<void> _writeMeta(File metaFile, _CacheMeta meta) async {
    try {
      await metaFile.writeAsString(jsonEncode(meta.toJson()));
    } catch (error) {
      debugPrint('CustomCachedImage: cache metadata write failed: $error');
    }
  }

  Future<void> _deleteQuietly(FileSystemEntity entity) async {
    try {
      if (await entity.exists()) {
        await entity.delete();
      }
    } catch (error) {
      debugPrint('CustomCachedImage: cache delete failed: $error');
    }
  }

  Future<void> _cleanup() async {
    final lastCleanup = _lastCleanup;

    final now = DateTime.now();

    if (lastCleanup != null &&
        now.difference(lastCleanup) < const Duration(minutes: 2)) {
      return;
    }

    _lastCleanup = now;

    try {
      final directory = await _ensureDirectory();

      final files = <File>[];

      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.bin')) {
          files.add(entity);
        }
      }

      final entries = <_DiskEntry>[];

      for (final file in files) {
        final stat = await file.stat();

        entries.add(
          _DiskEntry(
            file: file,
            modified: stat.modified,
            size: stat.size,
          ),
        );
      }

      entries.sort((a, b) => b.modified.compareTo(a.modified));

      var totalBytes = 0;

      for (var index = 0; index < entries.length; index++) {
        final entry = entries[index];

        totalBytes += entry.size;

        final tooOld = now.difference(entry.modified) > _config.maxAge;

        final tooMany = index >= _config.maxEntries;

        final tooLarge = totalBytes > _config.maxBytes;

        if (tooOld || tooMany || tooLarge) {
          await _deleteQuietly(entry.file);

          await _deleteQuietly(
            File(entry.file.path.replaceFirst(
              RegExp(r'\.bin$'),
              '.json',
            )),
          );
        }
      }
    } catch (error) {
      debugPrint('CustomCachedImage: cache cleanup failed: $error');
    }
  }
}

class _DiskEntry {
  final File file;
  final DateTime modified;
  final int size;

  const _DiskEntry({
    required this.file,
    required this.modified,
    required this.size,
  });
}

class _DownloadResult {
  final Uint8List bytes;
  final _CacheMeta meta;

  const _DownloadResult({
    required this.bytes,
    required this.meta,
  });
}

class _CacheEntry {
  final Uint8List bytes;
  final _CacheMeta meta;

  const _CacheEntry({
    required this.bytes,
    required this.meta,
  });

  bool isStale(Duration staleAfter) {
    return DateTime.now().difference(meta.downloadedAt) > staleAfter;
  }
}

class _CacheMeta {
  final String? url;
  final String? etag;
  final String? lastModified;
  final DateTime downloadedAt;

  const _CacheMeta({
    required this.downloadedAt,
    this.url,
    this.etag,
    this.lastModified,
  });

  factory _CacheMeta.fromJson(Map<String, dynamic> json) {
    final millis = json['downloadedAt'];

    return _CacheMeta(
      url: json['url'] as String?,
      etag: json['etag'] as String?,
      lastModified: json['lastModified'] as String?,
      downloadedAt: millis is int
          ? DateTime.fromMillisecondsSinceEpoch(millis)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  _CacheMeta refreshed() {
    return _CacheMeta(
      url: url,
      etag: etag,
      lastModified: lastModified,
      downloadedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'etag': etag,
      'lastModified': lastModified,
      'downloadedAt': downloadedAt.millisecondsSinceEpoch,
    };
  }
}
