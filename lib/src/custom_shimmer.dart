import 'package:flutter/material.dart';

/// A dependency-free shimmer effect.
///
/// A moving linear gradient is applied to [child] through a [ShaderMask],
/// which reproduces the classic skeleton-loading animation without relying
/// on any third party package.
class CustomShimmer extends StatefulWidget {
  /// The widget the shimmer gradient is painted over.
  final Widget child;

  /// The dominant (resting) color of the shimmer.
  final Color baseColor;

  /// The color of the moving highlight band.
  final Color highlightColor;

  /// Duration of a single sweep across the widget.
  final Duration period;

  /// Sweep direction.
  final Axis direction;

  /// Whether the animation is running.
  final bool enabled;

  /// Creates a shimmer effect around [child].
  const CustomShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE4E7EC),
    this.highlightColor = const Color(0xFFF9FAFB),
    this.period = const Duration(milliseconds: 1400),
    this.direction = Axis.horizontal,
    this.enabled = true,
  });

  /// Convenience constructor that shimmers a solid colored box.
  ///
  /// This is the common case for image placeholders.
  static Widget box({
    Key? key,
    Color baseColor = const Color(0xFFE4E7EC),
    Color highlightColor = const Color(0xFFF9FAFB),
    Duration period = const Duration(milliseconds: 1400),
    Axis direction = Axis.horizontal,
    bool enabled = true,
  }) {
    return CustomShimmer(
      key: key,
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      direction: direction,
      enabled: enabled,
      child: const SizedBox.expand(
        child: ColoredBox(
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CustomShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
    }

    if (oldWidget.enabled != widget.enabled ||
        oldWidget.period != widget.period) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return ColoredBox(
        color: widget.baseColor,
        child: const SizedBox.expand(),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return _buildGradient(_controller.value).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }

  LinearGradient _buildGradient(double progress) {
    /*
     * The gradient slides from fully off-screen on one side to fully
     * off-screen on the other, which keeps the highlight band continuous
     * between repetitions.
     */
    final slide = (progress * 2.0) - 1.0;

    final Alignment begin;
    final Alignment end;

    if (widget.direction == Axis.vertical) {
      begin = Alignment(0, slide - 1);
      end = Alignment(0, slide + 1);
    } else {
      begin = Alignment(slide - 1, 0);
      end = Alignment(slide + 1, 0);
    }

    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        widget.baseColor,
        widget.baseColor,
        widget.highlightColor,
        widget.baseColor,
        widget.baseColor,
      ],
      stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
    );
  }
}
