import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

enum CachedImageLoadingStyle {
  shimmer,
  spinner,
  none,
}

class CustomCachedImage extends StatefulWidget {
  /// Display dimensions.
  final double height;
  final double width;

  /// The image URL.
  ///
  /// Null, empty, malformed, and unsupported URLs are handled locally.
  final String? imageUrl;

  /// Image border radius.
  final double borderRadius;

  /// Image fitting behavior.
  final BoxFit fit;

  /// Image alignment.
  final Alignment alignment;

  /// Use profile initials/person icon when the image fails.
  final bool isProfile;

  /// Name used for profile initials.
  final String? name;

  /// Replaces the default error UI.
  final Widget? errorWidget;

  /// Replaces the default loading UI.
  final Widget? placeholderWidget;

  /// Loading indicator style.
  final CachedImageLoadingStyle loadingStyle;

  /// Background shown behind loading/error states.
  final Color backgroundColor;

  /// Optional border.
  final BoxBorder? border;

  /// Error/fallback icon.
  final IconData fallbackIcon;

  /// Error/fallback icon color.
  final Color fallbackIconColor;

  /// Whether a retry button should appear after a network failure.
  final bool showRetryButton;

  /// Called when image loading fails.
  final ValueChanged<Object>? onError;

  /// Called when retry is triggered.
  final VoidCallback? onRetry;

  /// Called when the image is tapped.
  final VoidCallback? onTap;

  /// Optional custom cache key.
  final String? cacheKey;

  /// Automatically resize decoded images according to their display size.
  final bool optimizeMemoryCache;

  /// Optional manual memory-cache dimensions.
  final int? memCacheWidth;
  final int? memCacheHeight;

  /// Keep the previous image while a new URL loads.
  final bool useOldImageOnUrlChange;

  /// Optional Hero tag.
  final Object? heroTag;

  /// Accessibility label.
  final String? semanticLabel;

  /// Fade durations.
  final Duration fadeInDuration;
  final Duration fadeOutDuration;

  /// Image rendering quality.
  final FilterQuality filterQuality;

  /// Shimmer colors.
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  /// Internal image shape.
  final BoxShape shape;

  const CustomCachedImage({
    super.key,
    required this.height,
    required this.width,
    required this.imageUrl,
    required this.borderRadius,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.isProfile = true,
    this.name,
    this.errorWidget,
    this.placeholderWidget,
    this.loadingStyle = CachedImageLoadingStyle.shimmer,
    this.backgroundColor = const Color(0xFFF2F4F7),
    this.border,
    this.fallbackIcon = Icons.broken_image_outlined,
    this.fallbackIconColor = const Color(0xFF98A2B3),
    this.showRetryButton = true,
    this.onError,
    this.onRetry,
    this.onTap,
    this.cacheKey,
    this.optimizeMemoryCache = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.useOldImageOnUrlChange = true,
    this.heroTag,
    this.semanticLabel,
    this.fadeInDuration = const Duration(milliseconds: 250),
    this.fadeOutDuration = const Duration(milliseconds: 150),
    this.filterQuality = FilterQuality.medium,
    this.shimmerBaseColor = const Color(0xFFE4E7EC),
    this.shimmerHighlightColor = const Color(0xFFF9FAFB),
    this.shape = BoxShape.rectangle,
  });

  /// Convenient constructor for profile avatars.
  const CustomCachedImage.circle({
    super.key,
    required double size,
    required this.imageUrl,
    this.name,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.isProfile = true,
    this.errorWidget,
    this.placeholderWidget,
    this.loadingStyle = CachedImageLoadingStyle.shimmer,
    this.backgroundColor = const Color(0xFFF2F4F7),
    this.border,
    this.fallbackIcon = Icons.person_outline_rounded,
    this.fallbackIconColor = const Color(0xFF98A2B3),
    this.showRetryButton = true,
    this.onError,
    this.onRetry,
    this.onTap,
    this.cacheKey,
    this.optimizeMemoryCache = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.useOldImageOnUrlChange = true,
    this.heroTag,
    this.semanticLabel,
    this.fadeInDuration = const Duration(milliseconds: 250),
    this.fadeOutDuration = const Duration(milliseconds: 150),
    this.filterQuality = FilterQuality.medium,
    this.shimmerBaseColor = const Color(0xFFE4E7EC),
    this.shimmerHighlightColor = const Color(0xFFF9FAFB),
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shape = BoxShape.circle;

  @override
  State<CustomCachedImage> createState() => _CustomCachedImageState();
}

class _CustomCachedImageState extends State<CustomCachedImage> {
  int _reloadVersion = 0;
  bool _errorReported = false;

  String get _normalizedUrl => widget.imageUrl?.trim() ?? '';

  bool get _hasValidUrl {
    if (_normalizedUrl.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(_normalizedUrl);

    if (uri == null || uri.host.isEmpty) {
      return false;
    }

    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  @override
  void didUpdateWidget(covariant CustomCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrl != widget.imageUrl) {
      _errorReported = false;
      _reloadVersion++;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result = _buildImageContent();

    result = _buildFrame(result);

    if (widget.heroTag != null) {
      result = Hero(
        tag: widget.heroTag!,
        child: result,
      );
    }

    if (widget.onTap != null) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: result,
      );
    }

    return Semantics(
      image: true,
      label: _resolveSemanticLabel(),
      child: result,
    );
  }

  Widget _buildImageContent() {
    if (!_hasValidUrl) {
      return _buildErrorState(
        error: const FormatException(
          'Image URL is null, empty, or invalid.',
        ),
        canRetry: false,
      );
    }

    return CachedNetworkImage(
      key: ValueKey<String>(
        '${widget.cacheKey ?? _normalizedUrl}-$_reloadVersion',
      ),
      imageUrl: _normalizedUrl,
      cacheKey: widget.cacheKey,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      filterQuality: widget.filterQuality,
      useOldImageOnUrlChange: widget.useOldImageOnUrlChange,
      fadeInDuration: widget.fadeInDuration,
      fadeOutDuration: widget.fadeOutDuration,
      memCacheWidth: _resolveMemoryCacheDimension(
        logicalDimension: widget.width,
        manualDimension: widget.memCacheWidth,
      ),
      memCacheHeight: _resolveMemoryCacheDimension(
        logicalDimension: widget.height,
        manualDimension: widget.memCacheHeight,
      ),
      placeholder: (_, __) => _buildPlaceholder(),
      errorWidget: (_, __, error) {
        _reportError(error);

        return _buildErrorState(
          error: error,
          canRetry: true,
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholderWidget != null) {
      return SizedBox.expand(
        child: widget.placeholderWidget,
      );
    }

    switch (widget.loadingStyle) {
      case CachedImageLoadingStyle.shimmer:
        return _ImageShimmer(
          baseColor: widget.shimmerBaseColor,
          highlightColor: widget.shimmerHighlightColor,
        );

      case CachedImageLoadingStyle.spinner:
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
            ),
          ),
        );

      case CachedImageLoadingStyle.none:
        return const SizedBox.expand();
    }
  }

  Widget _buildErrorState({
    required Object error,
    required bool canRetry,
  }) {
    if (widget.errorWidget != null) {
      return SizedBox.expand(
        child: widget.errorWidget,
      );
    }

    final Widget fallback;

    if (widget.isProfile) {
      fallback = _ProfileFallback(
        name: widget.name,
        width: widget.width,
        height: widget.height,
        iconColor: widget.fallbackIconColor,
      );
    } else {
      fallback = _GeneralImageFallback(
        width: widget.width,
        height: widget.height,
        icon: widget.fallbackIcon,
        iconColor: widget.fallbackIconColor,
      );
    }

    if (!widget.showRetryButton || !canRetry) {
      return fallback;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        fallback,
        Positioned(
          right: 6,
          bottom: 6,
          child: _RetryButton(
            onTap: _retry,
            availableSize: _shortestSide(
              widget.width,
              widget.height,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrame(Widget child) {
    final clippedChild = widget.shape == BoxShape.circle
        ? ClipOval(
      clipBehavior: Clip.antiAlias,
      child: child,
    )
        : ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      clipBehavior: Clip.antiAlias,
      child: child,
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: widget.shape,
          border: widget.border,
          borderRadius: widget.shape == BoxShape.rectangle
              ? BorderRadius.circular(widget.borderRadius)
              : null,
        ),
        position: DecorationPosition.foreground,
        child: clippedChild,
      ),
    );
  }

  Future<void> _retry() async {
    if (!_hasValidUrl) {
      return;
    }

    _errorReported = false;
    widget.onRetry?.call();

    try {
      await CachedNetworkImage.evictFromCache(_normalizedUrl);
    } catch (error) {
      debugPrint(
        'CustomCachedImage cache eviction failed: $error',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _reloadVersion++;
    });
  }

  void _reportError(Object error) {
    if (_errorReported) {
      return;
    }

    _errorReported = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.onError?.call(error);
    });
  }

  int? _resolveMemoryCacheDimension({
    required double logicalDimension,
    required int? manualDimension,
  }) {
    if (manualDimension != null) {
      return manualDimension > 0 ? manualDimension : null;
    }

    if (!widget.optimizeMemoryCache ||
        !logicalDimension.isFinite ||
        logicalDimension <= 0) {
      return null;
    }

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return (logicalDimension * devicePixelRatio)
        .round()
        .clamp(1, 4096)
        .toInt();
  }

  String _resolveSemanticLabel() {
    if (widget.semanticLabel?.trim().isNotEmpty == true) {
      return widget.semanticLabel!.trim();
    }

    if (widget.isProfile) {
      final profileName = widget.name?.trim();

      if (profileName?.isNotEmpty == true) {
        return '$profileName profile image';
      }

      return 'Profile image';
    }

    return 'Image';
  }
}

class _ImageShimmer extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const _ImageShimmer({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: const SizedBox.expand(
        child: ColoredBox(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ProfileFallback extends StatelessWidget {
  final String? name;
  final double width;
  final double height;
  final Color iconColor;

  const _ProfileFallback({
    required this.name,
    required this.width,
    required this.height,
    required this.iconColor,
  });

  static const List<Color> _avatarColors = [
    Color(0xFF7E57C2),
    Color(0xFFEF6C00),
    Color(0xFF00838F),
    Color(0xFFC62828),
    Color(0xFF2E7D32),
    Color(0xFFF9A825),
    Color(0xFF1565C0),
    Color(0xFFAD1457),
    Color(0xFF6D4C41),
    Color(0xFF4527A0),
  ];

  @override
  Widget build(BuildContext context) {
    final initials = _generateInitials(name);
    final size = _shortestSide(width, height);

    return ColoredBox(
      color: _generateAvatarColor(name),
      child: Center(
        child: initials == null
            ? Icon(
          Icons.person_outline_rounded,
          color: iconColor,
          size: (size * 0.48).clamp(20.0, 72.0).toDouble(),
        )
            : Padding(
          padding: EdgeInsets.all(size * 0.15),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              initials,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize:
                (size * 0.4).clamp(14.0, 72.0).toDouble(),
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _generateInitials(String? fullName) {
    final normalizedName = fullName?.trim();

    if (normalizedName == null || normalizedName.isEmpty) {
      return null;
    }

    final nameParts = normalizedName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (nameParts.isEmpty) {
      return null;
    }

    if (nameParts.length == 1) {
      return _firstCharacter(nameParts.first).toUpperCase();
    }

    final firstInitial = _firstCharacter(nameParts.first);
    final lastInitial = _firstCharacter(nameParts.last);

    return '$firstInitial$lastInitial'.toUpperCase();
  }

  String _firstCharacter(String value) {
    return String.fromCharCode(value.runes.first);
  }

  Color _generateAvatarColor(String? value) {
    final normalizedValue = value?.trim().toLowerCase() ?? '';

    if (normalizedValue.isEmpty) {
      return _avatarColors.first;
    }

    var hash = 0;

    for (final codeUnit in normalizedValue.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7FFFFFFF;
    }

    return _avatarColors[hash % _avatarColors.length];
  }
}

class _GeneralImageFallback extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final Color iconColor;

  const _GeneralImageFallback({
    required this.width,
    required this.height,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = _shortestSide(width, height);

    return Center(
      child: Icon(
        icon,
        color: iconColor,
        size: (size * 0.38).clamp(22.0, 64.0).toDouble(),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final VoidCallback onTap;
  final double availableSize;

  const _RetryButton({
    required this.onTap,
    required this.availableSize,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize =
    (availableSize * 0.28).clamp(24.0, 36.0).toDouble();

    return Material(
      color: Colors.black.withValues(alpha: 0.60),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Icon(
            Icons.refresh_rounded,
            color: Colors.white,
            size: buttonSize * 0.62,
          ),
        ),
      ),
    );
  }
}

double _shortestSide(double width, double height) {
  final validWidth =
  width.isFinite && width > 0 ? width : null;

  final validHeight =
  height.isFinite && height > 0 ? height : null;

  if (validWidth != null && validHeight != null) {
    return validWidth < validHeight
        ? validWidth
        : validHeight;
  }

  return validWidth ?? validHeight ?? 48;
}