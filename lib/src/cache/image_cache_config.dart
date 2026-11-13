/// Configuration for the built-in disk cache.
class ImageCacheConfig {
  /// How long a cached file is considered fresh.
  ///
  /// After this duration the file is still used, but it is revalidated
  /// against the server with `If-None-Match` / `If-Modified-Since`.
  final Duration staleAfter;

  /// Entries older than this are deleted during cleanup.
  final Duration maxAge;

  /// Maximum number of cached files kept on disk.
  final int maxEntries;

  /// Maximum total size of the cache directory in bytes.
  final int maxBytes;

  /// Name of the folder created inside the system temporary directory.
  final String folderName;

  /// Timeout applied to a single image download.
  final Duration timeout;

  /// Creates a cache configuration.
  const ImageCacheConfig({
    this.staleAfter = const Duration(days: 7),
    this.maxAge = const Duration(days: 30),
    this.maxEntries = 400,
    this.maxBytes = 200 * 1024 * 1024,
    this.folderName = 'custom_cached_image',
    this.timeout = const Duration(seconds: 30),
  });

  /// Returns a copy with the given fields replaced.
  ImageCacheConfig copyWith({
    Duration? staleAfter,
    Duration? maxAge,
    int? maxEntries,
    int? maxBytes,
    String? folderName,
    Duration? timeout,
  }) {
    return ImageCacheConfig(
      staleAfter: staleAfter ?? this.staleAfter,
      maxAge: maxAge ?? this.maxAge,
      maxEntries: maxEntries ?? this.maxEntries,
      maxBytes: maxBytes ?? this.maxBytes,
      folderName: folderName ?? this.folderName,
      timeout: timeout ?? this.timeout,
    );
  }
}

/// Thrown when an image could not be downloaded or read from the cache.
class ImageCacheException implements Exception {
  /// Human readable failure reason.
  final String message;

  /// The URL that failed to load.
  final String? url;

  /// HTTP status code, when the failure came from the server.
  final int? statusCode;

  /// Creates a cache exception.
  const ImageCacheException(
    this.message, {
    this.url,
    this.statusCode,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ImageCacheException: $message');

    if (statusCode != null) {
      buffer.write(' (status $statusCode)');
    }

    if (url != null) {
      buffer.write(' [$url]');
    }

    return buffer.toString();
  }
}

/// Stable, filesystem safe hash used for cache file names.
String imageCacheFileKey(String value) {
  /*
   * FNV-1a 64 bit. Pure Dart so that no crypto dependency is required.
   */
  var hash = BigInt.parse('14695981039346656037');

  final prime = BigInt.parse('1099511628211');
  final mask = BigInt.parse('18446744073709551615');

  for (final codeUnit in value.codeUnits) {
    hash = (hash ^ BigInt.from(codeUnit)) * prime & mask;
  }

  final hex = hash.toRadixString(16).padLeft(16, '0');

  return '$hex${value.length.toRadixString(16)}';
}
