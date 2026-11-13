import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'custom_cached_image_provider.dart';
import 'image_cache_config.dart';
import 'image_cache_store_web.dart'
    if (dart.library.io) 'image_cache_store_io.dart';

/// Entry point for configuring and controlling the built-in image cache.
///
/// ```dart
/// CustomImageCacheManager.configure(
///   const ImageCacheConfig(
///     staleAfter: Duration(days: 3),
///     maxBytes: 100 * 1024 * 1024,
///   ),
/// );
/// ```
class CustomImageCacheManager {
  const CustomImageCacheManager._();

  /// The configuration currently in use.
  static ImageCacheConfig get config => ImageCacheStore.instance.config;

  /// Applies a new cache configuration.
  static void configure(ImageCacheConfig config) {
    ImageCacheStore.instance.configure(config);
  }

  /// Removes a single image from both the disk and the in-memory cache.
  static Future<void> evict(
    String url, {
    String? cacheKey,
  }) async {
    final key = cacheKey ?? url;

    await ImageCacheStore.instance.evict(key);

    if (kIsWeb) {
      await NetworkImage(url).evict();

      return;
    }

    await CustomCachedImageProvider(
      url: url,
      cacheKey: cacheKey,
    ).evict();
  }

  /// Clears the whole disk cache and Flutter's in-memory image cache.
  static Future<void> clear() async {
    await ImageCacheStore.instance.clear();

    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }

  /// Total size of the cached files in bytes. Always zero on web.
  static Future<int> currentSizeInBytes() {
    return ImageCacheStore.instance.currentSizeInBytes();
  }
}
