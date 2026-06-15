import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Sweeps an animated gradient across [child] to produce a skeleton-loader
/// shimmer.
///
/// The effect is drawn with a [ShaderMask] using [BlendMode.srcATop], so the
/// gradient colour is painted over every opaque pixel of [child]. That means
/// the placeholder fills inside [child] (the `_Block`s) only define the *shape*
/// of the skeleton — their own colour never shows. The visible colour comes
/// entirely from [baseColor]/[highlightColor].
///
/// When those are left null they resolve from [AppColors] for the current
/// theme, which is what keeps the shimmer correct in both light and dark mode.
/// Previously they were hardcoded to dark-navy constants, so in light mode the
/// skeletons rendered as dark slabs and the animated highlight was too close in
/// tone to be perceptible.
class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppColors.shimmerBase(context);
    final highlightColor =
        widget.highlightColor ?? AppColors.shimmerHighlight(context);

    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final slide = _animation.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1 + slide, -0.4),
              end: Alignment(1 + slide, 0.4),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class MediaGridShimmer extends StatelessWidget {
  const MediaGridShimmer({super.key, this.showSummary = true});

  final bool showSummary;

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSummary) ...[
              const _Block(width: 150, height: 28, radius: 8),
              const SizedBox(height: 8),
              const _Block(width: 230, height: 12, radius: 6),
              const SizedBox(height: 20),
            ],
            GridView.builder(
              itemCount: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) =>
                  const _Block(width: double.infinity, height: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class ListShimmer extends StatelessWidget {
  const ListShimmer({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) => Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          // Shape-only fill (masked by the shimmer shader); themed for clarity.
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              _Block(width: 38, height: 38, radius: 11),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Block(width: double.infinity, height: 13, radius: 5),
                    SizedBox(height: 8),
                    _Block(width: 150, height: 10, radius: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.width, required this.height, this.radius = 14});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
