# Custom Cached Image

A flexible Flutter package that combines [`cached_network_image`](https://pub.dev/packages/cached_network_image) with [`shimmer`](https://pub.dev/packages/shimmer) to provide smooth loading states, image caching, profile initials, retry handling, and customizable error fallbacks.

## ✨ Features

* **Image caching:** Loads and caches network images efficiently.
* **Shimmer loading:** Displays an animated shimmer while images are loading.
* **Multiple loading styles:** Choose shimmer, spinner, or no loading indicator.
* **Profile initials:** Displays initials when a profile image is unavailable.
* **Circle avatars:** Includes a convenient constructor for circular profile images.
* **Retry support:** Allows users to retry failed network image requests.
* **Invalid URL handling:** Handles null, empty, malformed, and unsupported URLs safely.
* **Memory optimization:** Resizes decoded images according to their display dimensions.
* **Custom placeholders:** Supports custom loading widgets.
* **Custom error widgets:** Replace the built-in fallback with your own UI.
* **Error callbacks:** Receive image-loading errors for logging or reporting.
* **Hero animations:** Add an optional Hero tag for image transitions.
* **Highly customizable:** Configure dimensions, borders, colors, radius, alignment, fit, and more.
* **Smooth transitions:** Prevents sudden image pop-ins using fade animations.

---

## 📦 Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  custom_cached_image: ^latest_version
```

Replace `latest_version` with the latest version published on pub.dev.

Then run:

```sh
flutter pub get
```

---

## 🔧 Import

```dart
import 'package:custom_cached_image/custom_cached_image.dart';
```

---

## 🚀 Basic Usage

```dart
CustomCachedImage(
  imageUrl: 'https://example.com/sample.jpg',
  width: 150,
  height: 150,
  borderRadius: 10,
  fit: BoxFit.cover,
)
```

The image is automatically cached after it loads successfully.

---

## 👤 Profile Image with Initials

Set `isProfile` to `true` and provide the user's name.

When the URL is null, empty, invalid, or fails to load, the widget displays the user's initials.

```dart
CustomCachedImage(
  imageUrl: user.profileImage,
  width: 150,
  height: 150,
  borderRadius: 75,
  isProfile: true,
  name: '${user.firstName} ${user.lastName}',
  fit: BoxFit.cover,
)
```

For example:

```text
Mansoor Ali
```

will display:

```text
MS
```

If no valid name is provided, a default person icon is displayed.

---

## ⭕ Circular Profile Image

Use `CustomCachedImage.circle` for avatars.

```dart
CustomCachedImage.circle(
  imageUrl: user.profileImage,
  name: user.fullName,
  size: 60,
)
```

You do not need to calculate the border radius manually.

---

## 🖼️ Normal Network Image

For product, property, banner, or gallery images, set `isProfile` to `false`.

```dart
CustomCachedImage(
  imageUrl: product.imageUrl,
  width: double.infinity,
  height: 220,
  borderRadius: 16,
  isProfile: false,
  fit: BoxFit.cover,
)
```

When loading fails, a local broken-image icon is displayed. The package does not make a second network request for an error image.

---

## ⏳ Loading Styles

The package supports three loading styles:

```dart
enum CachedImageLoadingStyle {
  shimmer,
  spinner,
  none,
}
```

### Shimmer

Shimmer is enabled by default.

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 150,
  height: 150,
  borderRadius: 12,
  loadingStyle: CachedImageLoadingStyle.shimmer,
)
```

### Circular Progress Indicator

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 150,
  height: 150,
  borderRadius: 12,
  loadingStyle: CachedImageLoadingStyle.spinner,
)
```

### No Loading Indicator

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 150,
  height: 150,
  borderRadius: 12,
  loadingStyle: CachedImageLoadingStyle.none,
)
```

---

## 🎨 Custom Shimmer Colors

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 200,
  height: 200,
  borderRadius: 16,
  shimmerBaseColor: Colors.grey.shade300,
  shimmerHighlightColor: Colors.grey.shade100,
)
```

---

## 🧩 Custom Placeholder

Use `placeholderWidget` to completely replace the default loading state.

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 200,
  height: 200,
  borderRadius: 16,
  placeholderWidget: const Center(
    child: CircularProgressIndicator(),
  ),
)
```

---

## ⚠️ Error Handling

The widget automatically handles:

* Null image URLs
* Empty image URLs
* Invalid image URLs
* Unsupported URL schemes
* Network request failures
* Image decoding failures
* Expired or unavailable image links

```dart
CustomCachedImage(
  imageUrl: 'invalid_url',
  width: 150,
  height: 150,
  borderRadius: 12,
  isProfile: false,
)
```

A local fallback will be displayed automatically.

---

## 🧩 Custom Error Widget

Use `errorWidget` to replace the default error UI.

```dart
CustomCachedImage(
  imageUrl: product.imageUrl,
  width: 250,
  height: 180,
  borderRadius: 14,
  isProfile: false,
  errorWidget: const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.image_not_supported_outlined),
        SizedBox(height: 8),
        Text('Image unavailable'),
      ],
    ),
  ),
)
```

---

## 🔄 Retry Failed Images

A retry button is displayed by default when a valid network URL fails to load.

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 200,
  height: 200,
  borderRadius: 16,
  isProfile: false,
  showRetryButton: true,
)
```

The retry action clears the failed cached image and attempts to load it again.

Disable the retry button when it is not needed:

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 200,
  height: 200,
  borderRadius: 16,
  showRetryButton: false,
)
```

---

## 📢 Error and Retry Callbacks

Use `onError` to log image-loading failures.

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 150,
  height: 150,
  borderRadius: 12,
  onError: (error) {
    debugPrint('Image loading failed: $error');
  },
)
```

Use `onRetry` to detect when the retry button is pressed.

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 150,
  height: 150,
  borderRadius: 12,
  onRetry: () {
    debugPrint('Image retry requested');
  },
)
```

These callbacks can be connected to logging services such as Firebase Crashlytics, Sentry, or a custom logger.

---

## 🖱️ Image Tap

Use `onTap` to make the image interactive.

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 150,
  height: 150,
  borderRadius: 12,
  onTap: () {
    debugPrint('Image tapped');
  },
)
```

---

## 🎬 Hero Animation

Provide the same `heroTag` on both screens.

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 120,
  height: 120,
  borderRadius: 16,
  heroTag: 'product-image-1',
)
```

On the destination screen:

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: double.infinity,
  height: 400,
  borderRadius: 0,
  heroTag: 'product-image-1',
)
```

Each visible Hero image must use a unique tag.

---

## 🎨 Border Customization

```dart
CustomCachedImage.circle(
  imageUrl: user.profileImage,
  name: user.fullName,
  size: 64,
  border: Border.all(
    color: Colors.blue,
    width: 2,
  ),
)
```

For a rectangular image:

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 250,
  height: 180,
  borderRadius: 16,
  border: Border.all(
    color: Colors.grey.shade300,
  ),
)
```

---

## 🎨 Background and Fallback Colors

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 180,
  height: 180,
  borderRadius: 16,
  isProfile: false,
  backgroundColor: Colors.grey.shade100,
  fallbackIconColor: Colors.grey.shade600,
)
```

---

## 🧠 Memory Optimization

Memory-cache optimization is enabled by default.

The package calculates the decoded image size using:

* Widget width
* Widget height
* Device pixel ratio

This prevents unnecessarily large images from consuming excessive memory.

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 100,
  height: 100,
  borderRadius: 12,
  optimizeMemoryCache: true,
)
```

You can provide manual cache dimensions:

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 100,
  height: 100,
  borderRadius: 12,
  memCacheWidth: 300,
  memCacheHeight: 300,
)
```

Disable automatic optimization only when necessary:

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  width: 100,
  height: 100,
  borderRadius: 12,
  optimizeMemoryCache: false,
)
```

---

## ♻️ Handling URL Changes

By default, the previous image remains visible while a new URL is loading.

```dart
CustomCachedImage(
  imageUrl: selectedImageUrl,
  width: 200,
  height: 200,
  borderRadius: 16,
  useOldImageOnUrlChange: true,
)
```

Disable this behavior when the old image should disappear immediately:

```dart
CustomCachedImage(
  imageUrl: selectedImageUrl,
  width: 200,
  height: 200,
  borderRadius: 16,
  useOldImageOnUrlChange: false,
)
```

---

## 🔑 Custom Cache Key

Use a custom cache key when the image URL changes but still represents the same image resource.

```dart
CustomCachedImage(
  imageUrl: imageUrl,
  cacheKey: 'user-profile-${user.id}',
  width: 100,
  height: 100,
  borderRadius: 50,
)
```

The cache key must uniquely identify the image.

---

## ♿ Accessibility

Provide a semantic label for screen readers.

```dart
CustomCachedImage(
  imageUrl: product.imageUrl,
  width: 200,
  height: 200,
  borderRadius: 16,
  semanticLabel: 'Front view of the selected product',
)
```

For profile images, a label is generated automatically using the supplied name.

---

## 📱 Complete Example

```dart
import 'package:custom_cached_image/custom_cached_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Custom Cached Image Example',
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Cached Image'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Profile Image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: CustomCachedImage.circle(
              imageUrl: 'https://example.com/profile.jpg',
              name: 'Mansoor Ali',
              size: 90,
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
              onError: (error) {
                debugPrint('Profile image error: $error');
              },
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Network Image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          CustomCachedImage(
            imageUrl: 'https://example.com/sample.jpg',
            width: double.infinity,
            height: 220,
            borderRadius: 18,
            isProfile: false,
            fit: BoxFit.cover,
            loadingStyle: CachedImageLoadingStyle.shimmer,
            showRetryButton: true,
            onError: (error) {
              debugPrint('Image loading error: $error');
            },
            onRetry: () {
              debugPrint('Retrying image');
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 📋 Main Parameters

| Parameter             | Type                      |            Default | Description                                |
| --------------------- | ------------------------- | -----------------: | ------------------------------------------ |
| `imageUrl`            | `String?`                 |           Required | URL of the network image                   |
| `width`               | `double`                  |           Required | Display width                              |
| `height`              | `double`                  |           Required | Display height                             |
| `borderRadius`        | `double`                  |           Required | Corner radius                              |
| `fit`                 | `BoxFit`                  |     `BoxFit.cover` | Image fitting behavior                     |
| `alignment`           | `Alignment`               | `Alignment.center` | Image alignment                            |
| `isProfile`           | `bool`                    |             `true` | Displays initials when loading fails       |
| `name`                | `String?`                 |             `null` | Name used to generate profile initials     |
| `loadingStyle`        | `CachedImageLoadingStyle` |          `shimmer` | Loading indicator style                    |
| `placeholderWidget`   | `Widget?`                 |             `null` | Custom loading widget                      |
| `errorWidget`         | `Widget?`                 |             `null` | Custom error widget                        |
| `showRetryButton`     | `bool`                    |             `true` | Shows retry after network failure          |
| `onError`             | `ValueChanged<Object>?`   |             `null` | Image error callback                       |
| `onRetry`             | `VoidCallback?`           |             `null` | Retry callback                             |
| `onTap`               | `VoidCallback?`           |             `null` | Image tap callback                         |
| `heroTag`             | `Object?`                 |             `null` | Optional Hero animation tag                |
| `border`              | `BoxBorder?`              |             `null` | Optional image border                      |
| `backgroundColor`     | `Color`                   |         Light grey | Placeholder and fallback background        |
| `optimizeMemoryCache` | `bool`                    |             `true` | Automatically optimizes decoded image size |
| `memCacheWidth`       | `int?`                    |             `null` | Manual memory-cache width                  |
| `memCacheHeight`      | `int?`                    |             `null` | Manual memory-cache height                 |
| `cacheKey`            | `String?`                 |             `null` | Optional custom cache identifier           |
| `semanticLabel`       | `String?`                 |             `null` | Accessibility description                  |

---

## 💡 Why Use This Package?

* Prevents blank spaces while network images load.
* Improves application performance through image caching.
* Reduces memory usage by optimizing decoded image dimensions.
* Provides polished loading states without additional setup.
* Handles broken and invalid image URLs safely.
* Provides built-in profile initials and circular avatar support.
* Gives users the ability to retry failed network requests.
* Keeps image-loading code consistent across your application.
* Supports extensive customization without repeating boilerplate.

---

## 🔗 Links

* [Pub.dev Package](https://pub.dev/packages/custom_cached_image)
* [GitHub Repository](https://github.com/manushah77/custom_cache_image_package)
* [Issue Tracker](https://github.com/manushah77/custom_cached_image/issues)

> Verify that the GitHub repository and issue tracker URLs use the same repository name before publishing.

---

## 🤝 Contributions

Contributions are welcome.

You can contribute by:

* Reporting bugs
* Suggesting new features
* Improving documentation
* Submitting pull requests
* Adding tests
* Improving performance

Please open an issue before submitting a major change.

---

## ❤️ Support

If this package is useful, consider:

* Starring the GitHub repository
* Liking the package on pub.dev
* Sharing it with other Flutter developers
* Reporting issues and feature suggestions

---

## 📄 License

This project is licensed under the MIT License.

See the `LICENSE` file for complete license information.
