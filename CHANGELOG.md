
## 1.5.0 - 2026-Feb-05

### Updated

* **`CustomCachedImage`** now provides:

    * **`errorWidget`** if provided, allowing custom fallback widgets (e.g., asset image, SVG, or any widget) when the image fails to load.
    * **Initials-based widget** when `isProfile` is `true`, showing the user's initials as a fallback.
    * **Default network image** placeholder when no custom widget or profile initials are used.

### Added

* **`name`** parameter to generate initials when the image fails to load (useful for profile images).
* **`isProfile`** flag to distinguish profile images from others (to show initials on failure).
* **`_InitialsFallback`** widget with a colored background for displaying initials.
* **`_NotFoundWidget`** for default fallback with a network image when the image fails to load.
* **`_ShimmerEffect`** as the default loading placeholder while the image is being fetched.

---

## 1.4.0 - 2025-Aug-01

### Updated

* **`CustomCachedImage`** now conditionally falls back to:

    * **`errorWidget`** if provided.
    * **Initials-based widget** when `isProfile` is `true`.
    * **Default placeholder image** otherwise.

### Added

* **`name`** parameter for generating initials fallback.
* **`isProfile`** flag to distinguish profile images from others.
* **`_InitialsFallback`** widget with a colored background.
* **`_NotFoundWidget`** for default placeholder image on failure.
* **`_ShimmerEffect`** as the default loading placeholder.

---

## 1.1.0 - 2025-05-12

### Added

* **`errorWidget`** parameter to `CustomCachedImage` to allow custom fallback widgets (e.g., asset image, SVG, or any widget) when the image fails to load.

---

## 0.0.1 - 2025-01-01

### Initial Release

* Basic `CustomCachedImage` widget with cached network image loading and shimmer placeholder.

---

### Explanation:

* **Version 1.5.0 (Feb 5, 2026)** introduces more flexibility for error handling by allowing a custom `errorWidget`, and fallback handling for profile images with initials and a default network image.
