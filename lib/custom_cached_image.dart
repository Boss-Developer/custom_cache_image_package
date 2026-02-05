import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A custom widget for displaying cached network images with optional shimmer effect,
/// fallback initials for profile pictures, or a placeholder image if the image fails to load.
class CustomCachedImage extends StatelessWidget {
  /// The height of the image.
  final double height;

  /// The width of the image.
  final double width;

  /// The border radius of the image.
  final double borderRadius;

  /// The image URL to load.
  final String imageUrl;

  /// Defines how the image should be inscribed into the space allocated.
  final BoxFit? fit;

  /// Whether the image is a profile picture (shows initials on failure).
  final bool isProfile;

  /// Optional full name used to generate initials if image fails.
  final String? name;

  /// Optional custom widget to show if image fails to load.
  final Widget? errorWidget;

  const CustomCachedImage({
    super.key,
    required this.height,
    required this.width,
    required this.imageUrl,
    required this.borderRadius,
    this.fit,
    this.isProfile = true,
    this.name,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        placeholder: (_, __) => _ShimmerEffect(
          height: height,
          width: width,
          borderRadius: borderRadius,
        ),
        errorWidget: (_, __, ___) => errorWidget ??
            (isProfile
                ? _InitialsFallback(name: name, size: height)
                : _NotFoundWidget(
              height: height,
              fallbackWidget: errorWidget,
            )),
      ),
    );
  }
}

/// A shimmer effect placeholder for image loading state.
class _ShimmerEffect extends StatelessWidget {
  final double height, width, borderRadius;

  const _ShimmerEffect({
    required this.height,
    required this.width,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// A fallback widget that shows user initials in a colored box if image fails to load.
class _InitialsFallback extends StatelessWidget {
  final String? name;
  final double size;

  const _InitialsFallback({this.name, required this.size});

  /// Generates initials from the name (e.g., "John Doe" -> "JD").
  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return "?";
    final parts = fullName.trim().split(" ");
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Generates a background color based on the name hash.
  Color _getColorFromName(String? name) {
    final colors = [
      Color(0xFFB39DDB), // Lavender
      Color(0xFFFFAB91), // Coral
      Color(0xFF80DEEA), // Light Blue
      Color(0xFFEF9A9A), // Soft Red
      Color(0xFFA5D6A7), // Mint Green
      Color(0xFFFFF59D), // Soft Yellow
      Color(0xFF90CAF9), // Baby Blue
      Color(0xFFF48FB1), // Pink
      Color(0xFFFFCC80), // Peach
      Color(0xFFCE93D8), // Light Purple
    ];
    if (name == null || name.isEmpty) return colors[0];
    final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getColorFromName(name);

    return Container(
      width: size,
      height: size,
      color: bgColor,
      child: Center(
        child: Text(
          _getInitials(name),
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// A default fallback widget that shows a customizable widget when image fails.
class _NotFoundWidget extends StatelessWidget {
  final double height;
  final Widget? fallbackWidget;

  const _NotFoundWidget({
    required this.height,
    this.fallbackWidget, // Accept any custom widget
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: fallbackWidget ??
          Image.network(
            'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg',
            fit: BoxFit.cover,
            height: height,
          ),
    );
  }
}
