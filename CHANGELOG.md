# Changelog

All notable changes to the `custom_cached_image` package are documented in this file.

---

## 1.9.0 - 2026-07-10

### Fixed

* Fixed successfully loaded network images being hidden by the widget background.
* Fixed `DecorationPosition.foreground` painting the background color over images, shimmer placeholders, and error widgets.
* Fixed valid image URLs being rejected by unnecessary HTTP and HTTPS URL validation.
* Updated the widget to pass every non-empty image URL directly to `CachedNetworkImage`.
* Fixed profile images not displaying when using API values such as `tenant.profileImage`.
* Fixed image borders being rendered underneath loaded images.
* Fixed inconsistent clipping between images, placeholders, fallback widgets, and borders.
* Fixed stale image error states when `imageUrl` or `cacheKey` changed.
* Fixed retry requests continuing to use a failed cached image.
* Fixed cache eviction not respecting a custom `cacheKey`.
* Fixed duplicate `onError` callbacks during widget rebuilds.
* Fixed empty image URLs causing unnecessary network requests.
* Fixed minor image loading, caching, retry, and rendering issues.

### Updated

* Improved network image compatibility by removing restrictive URL parsing.
* Improved image frame rendering by keeping the background behind the image.
* Improved retry handling and cache refresh behavior.
* Improved profile image reliability.
* Improved border rendering for circular and rectangular images.


## 1.8.0 - 2026-07-10

### Added

* Added `CachedImageLoadingStyle` with support for:

    * `shimmer`
    * `spinner`
    * `none`
* Added the `CustomCachedImage.circle` constructor for circular profile images and avatars.
* Added built-in retry support for failed network images.
* Added `showRetryButton` to enable or disable the retry button.
* Added `onRetry` callback for detecting retry attempts.
* Added `onError` callback for logging image-loading errors.
* Added `onTap` callback for handling image taps.
* Added `placeholderWidget` for displaying a fully customized loading widget.
* Added support for customizable shimmer colors through:

    * `shimmerBaseColor`
    * `shimmerHighlightColor`
* Added `backgroundColor` for loading and error states.
* Added `fallbackIcon` for customizing the default error icon.
* Added `fallbackIconColor` for customizing fallback icon colors.
* Added optional image borders through the `border` parameter.
* Added image alignment support through the `alignment` parameter.
* Added optional Hero animation support through `heroTag`.
* Added accessibility support through `semanticLabel`.
* Added custom cache identification through the `cacheKey` parameter.
* Added manual memory-cache dimensions through:

    * `memCacheWidth`
    * `memCacheHeight`
* Added automatic memory-cache optimization based on the widget dimensions and device pixel ratio.
* Added `optimizeMemoryCache` to enable or disable automatic cache optimization.
* Added `useOldImageOnUrlChange` to retain the previous image while a new image is loading.
* Added configurable image fade durations through:

    * `fadeInDuration`
    * `fadeOutDuration`
* Added configurable image rendering quality through `filterQuality`.

### Updated

* Converted `CustomCachedImage` from a `StatelessWidget` to a `StatefulWidget` to support retries and improved image-state handling.
* Improved handling of null, empty, malformed, and unsupported image URLs.
* Improved cached image loading performance.
* Improved memory usage by decoding images closer to their displayed dimensions.
* Improved profile image fallback behavior.
* Improved initials generation for single-word and multi-word names.
* Improved initials sizing for both square and rectangular image containers.
* Improved profile fallback colors using deterministic name-based color generation.
* Improved image behavior when `imageUrl` changes.
* Improved clipping for rectangular and circular images.
* Improved shimmer loading behavior.
* Improved error reporting by preventing duplicate error callbacks.
* Improved retry behavior by removing the failed cached image before reloading.
* Improved accessibility for profile and standard network images.
* Improved package example with multiple image-loading scenarios.
* Updated the default non-profile fallback to use a local icon instead of loading another network image.
* Updated the package documentation with examples for:

    * Basic cached images
    * Circular profile images
    * Profile initials
    * Shimmer loading
    * Spinner loading
    * Custom placeholders
    * Custom error widgets
    * Retry handling
    * Hero animations
    * Error callbacks
    * Memory optimization

### Fixed

* Fixed empty image URLs being passed directly to `CachedNetworkImage`.
* Fixed malformed URLs causing unnecessary image requests.
* Fixed failed fallback images triggering an additional network request.
* Fixed duplicate fallback handling when `errorWidget` was provided.
* Fixed repeated error callbacks during widget rebuilds.
* Fixed stale error states when the image URL changed.
* Fixed retry attempts continuing to use a failed cached image.
* Fixed oversized decoded images consuming unnecessary memory.
* Fixed incorrect initials sizing for rectangular images.
* Fixed profile images displaying an unclear fallback when no name was provided.
* Fixed inconsistent border clipping between the image, placeholder, and error widget.
* Fixed minor layout and image-rendering issues.

---

## 1.7.0 - 2026-03-16

### Updated

* Improved cached image loading performance.
* Improved internal image-loading behavior.
* Improved package stability.

### Fixed

* Fixed minor cached image issues.
* Fixed minor layout and fallback issues.
* Applied general bug fixes and improvements.

---

## 1.6.0 - 2026-02-25

### Added

* Added a shimmer loading effect.
* Added support for asset placeholders.

### Updated

* Improved cached image loading performance.
* Improved placeholder rendering.
* Improved image-loading transitions.

### Fixed

* Fixed minor image-loading issues.
* Applied general bug fixes and stability improvements.

---

## 1.5.0 - 2026-02-05

### Added

* Added the `errorWidget` parameter to allow a custom fallback widget when an image fails to load.
* Added support for custom fallback widgets such as:

    * Asset images
    * SVG widgets
    * Icons
    * Any custom Flutter widget
* Added the `name` parameter for generating profile initials.
* Added the `isProfile` flag to distinguish profile images from standard images.
* Added `_InitialsFallback` for displaying user initials with a generated background color.
* Added `_NotFoundWidget` as the default non-profile image fallback.
* Added `_ShimmerEffect` as the default loading placeholder.

### Updated

* Updated `CustomCachedImage` to use the following fallback priority:

    1. Display the provided `errorWidget`.
    2. Display profile initials when `isProfile` is `true`.
    3. Display the default fallback image for standard images.
* Improved error-handling flexibility.
* Improved profile image fallback behavior.

### Fixed

* Fixed image failures displaying an empty area.
* Fixed missing fallback behavior for profile images.
* Fixed minor image-loading and rendering issues.

---

## 1.4.0 - 2025-08-01

### Added

* Added the `name` parameter for generating profile initials.
* Added the `isProfile` flag for profile image fallback handling.
* Added `_InitialsFallback` with generated background colors.
* Added `_NotFoundWidget` for standard image failures.
* Added `_ShimmerEffect` as the default loading placeholder.

### Updated

* Updated image failure handling to display:

    1. The provided `errorWidget`.
    2. User initials when `isProfile` is `true`.
    3. The default placeholder image for standard images.
* Improved fallback behavior for profile and non-profile images.
* Improved the shimmer placeholder implementation.

### Fixed

* Fixed missing fallback content when profile image loading failed.
* Fixed minor placeholder and image-clipping issues.

---

## 1.1.0 - 2025-05-12

### Added

* Added the `errorWidget` parameter to `CustomCachedImage`.
* Added support for displaying custom fallback widgets when an image fails to load.
* Added support for using asset images, SVGs, icons, and other Flutter widgets as error placeholders.

### Updated

* Improved image-loading error handling.
* Improved customization options for failed images.

---

## 0.0.1 - 2025-01-01

### Initial Release

* Added the basic `CustomCachedImage` widget.
* Added cached network image loading.
* Added a shimmer loading placeholder.
* Added customizable image height and width.
* Added customizable border radius.
* Added support for different `BoxFit` options.
* Added basic image error handling.
