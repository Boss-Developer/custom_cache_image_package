import 'dart:typed_data';

import 'image_cache_config.dart';

/// Web implementation of the image cache store.
///
/// Browsers already persist HTTP responses in their own cache, and the
/// package has no way to open a writable file system there without extra
/// dependencies. On web the widget therefore renders through Flutter's own
/// network image loader and this store only keeps the API shape intact.
class ImageCacheStore {
  /// The shared store instance.
  static final ImageCacheStore instance = ImageCacheStore._();

  ImageCacheStore._();

  ImageCacheConfig _config = const ImageCacheConfig();

  /// The active configuration.
  ImageCacheConfig get config => _config;

  /// Replaces the active configuration.
  void configure(ImageCacheConfig config) {
    _config = config;
  }

  /// Not supported on web; the browser cache is used instead.
  Future<Uint8List> load(
    String url, {
    String? cacheKey,
    Map<String, String>? headers,
    void Function(int received, int? total)? onProgress,
  }) {
    throw ImageCacheException(
      'Disk caching is handled by the browser on web.',
      url: url,
    );
  }

  /// No-op on web.
  Future<void> evict(String key) async {}

  /// No-op on web.
  Future<void> clear() async {}

  /// Always zero on web.
  Future<int> currentSizeInBytes() async => 0;
}
