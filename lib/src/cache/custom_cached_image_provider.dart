import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'image_cache_store_web.dart'
    if (dart.library.io) 'image_cache_store_io.dart';

/// Creates the image provider used by `CustomCachedImage`.
///
/// Native platforms get the package's own disk cached provider. The web
/// build falls back to Flutter's [NetworkImage], where the browser already
/// performs HTTP caching.
ImageProvider createCachedImageProvider({
  required String url,
  String? cacheKey,
  Map<String, String>? headers,
  double scale = 1.0,
}) {
  if (kIsWeb) {
    return NetworkImage(
      url,
      scale: scale,
      headers: headers,
    );
  }

  return CustomCachedImageProvider(
    url: url,
    cacheKey: cacheKey,
    headers: headers,
    scale: scale,
  );
}

/// An [ImageProvider] that reads from the package's own disk cache and only
/// hits the network when the cached copy is missing or stale.
@immutable
class CustomCachedImageProvider
    extends ImageProvider<CustomCachedImageProvider> {
  /// The image URL.
  final String url;

  /// Optional key used instead of [url] for cache lookups.
  final String? cacheKey;

  /// Extra request headers.
  final Map<String, String>? headers;

  /// Image scale.
  final double scale;

  /// Creates a disk cached image provider.
  const CustomCachedImageProvider({
    required this.url,
    this.cacheKey,
    this.headers,
    this.scale = 1.0,
  });

  @override
  Future<CustomCachedImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<CustomCachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CustomCachedImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, chunkEvents),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => [
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<String>('Image URL', key.url),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    CustomCachedImageProvider key,
    ImageDecoderCallback decode,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    try {
      final bytes = await ImageCacheStore.instance.load(
        key.url,
        cacheKey: key.cacheKey,
        headers: key.headers,
        onProgress: (received, total) {
          if (chunkEvents.isClosed) {
            return;
          }

          chunkEvents.add(
            ImageChunkEvent(
              cumulativeBytesLoaded: received,
              expectedTotalBytes: total,
            ),
          );
        },
      );

      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);

      return await decode(buffer);
    } catch (_) {
      /*
       * A failed load must not stay in the in-memory cache, otherwise the
       * error is replayed forever and a retry can never succeed.
       */
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });

      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CustomCachedImageProvider &&
        other.url == url &&
        other.cacheKey == cacheKey &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, cacheKey, scale);

  @override
  String toString() {
    return 'CustomCachedImageProvider("$url", scale: $scale)';
  }
}
