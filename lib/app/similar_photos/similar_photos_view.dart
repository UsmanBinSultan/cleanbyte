import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/similar_photos/similar_photos_controller.dart';

class SimilarPhotosView extends StatelessWidget {
  const SimilarPhotosView({super.key, this.mode = MediaCleanupMode.photos});

  final MediaCleanupMode mode;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimilarPhotosController>(
      tag: mode.name,
      init: SimilarPhotosController(mode: mode),
      builder: (controller) {
        return Scaffold(
          backgroundColor: controller.reviewAsset != null
              ? const Color(0xFF071120)
              : Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFFFFBF5)
              : const Color(0xFF071120),
          body: SafeArea(
            child: controller.reviewAsset == null
                ? Column(
                    children: [
                      _ToolHeader(controller: controller),
                      Expanded(child: _MediaBody(controller: controller)),
                      _BottomAction(controller: controller),
                    ],
                  )
                : _SwipeReviewPane(controller: controller),
          ),
        );
      },
    );
  }
}

class _MediaBody extends StatelessWidget {
  const _MediaBody({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const MediaGridShimmer();
    }

    if (!controller.hasAccess) {
      return _AccessState(controller: controller);
    }

    if (controller.assets.isEmpty) {
      if (controller.mode.isBlurred &&
          controller.blurScanTotal > 0 &&
          controller.blurScanDone < controller.blurScanTotal) {
        return _BlurScanState(controller: controller);
      }
      return _EmptyState(controller: controller);
    }

    return RefreshIndicator(
      color: const Color(0xFF18D0B8),
      backgroundColor: const Color(0xFF111929),
      onRefresh: controller.loadAssets,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            sliver: SliverToBoxAdapter(child: _Summary(controller: controller)),
          ),
          if (controller.mode.isDuplicates)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              sliver: SliverToBoxAdapter(
                child: _AutoCleanBar(controller: controller),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.builder(
              itemCount: controller.assets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final asset = controller.assets[index];
                return _MediaTile(
                  asset: asset,
                  isVideo: controller.mode.isVideos,
                  byteSize: controller.assetByteSizes[asset.id],
                  detailLabel: _assetDetailLabel(controller, asset),
                  selected: controller.isSelected(asset),
                  keep: controller.isDuplicateKeeper(asset),
                  onTap: controller.mode == MediaCleanupMode.photos
                      ? () => controller.openAssetReview(asset)
                      : () => controller.toggleAsset(asset),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeReviewPane extends StatefulWidget {
  const _SwipeReviewPane({required this.controller});

  final SimilarPhotosController controller;

  @override
  State<_SwipeReviewPane> createState() => _SwipeReviewPaneState();
}

class _SwipeReviewPaneState extends State<_SwipeReviewPane> {
  double _dragDx = 0;

  SimilarPhotosController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final asset = controller.reviewAsset;
    if (asset == null) {
      return const SizedBox.shrink();
    }

    final index = controller.reviewAssetIndex(asset);
    final total = controller.totalCount == 0
        ? controller.assets.length
        : controller.totalCount;
    final reviewed = total == 0 ? 0 : (index + 1).clamp(1, total).toInt();
    final progress = total == 0 ? 0.0 : reviewed / total;

    return Column(
      children: [
        _SwipeReviewHeader(
          asset: asset,
          title: 'Pic ${reviewed.toString()} of ${total.toString()}',
          progress: progress.clamp(0.0, 1.0),
          onBack: controller.closeAssetReview,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = MediaQuery.sizeOf(context).height;
              final cardHeight = (screenHeight * 0.85)
                  .clamp(320.0, constraints.maxHeight - 8)
                  .toDouble();

              return Stack(
                children: [
                  Positioned(
                    left: 14,
                    right: 14,
                    top: 10,
                    height: cardHeight,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() => _dragDx += details.delta.dx);
                      },
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (_dragDx < -86 || velocity < -420) {
                          _deleteCurrent();
                        } else if (_dragDx > 86 || velocity > 420) {
                          controller.closeAssetReview();
                        } else {
                          setState(() => _dragDx = 0);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 170),
                        curve: Curves.easeOut,
                        transform: Matrix4.identity()
                          ..translateByDouble(_dragDx, 0, 0, 1)
                          ..rotateZ(_dragDx / 1400),
                        child: _SwipePhotoCard(
                          asset: asset,
                          subtitle: _reviewDetailLabel(controller, asset),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 170,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF071120).withValues(alpha: 0),
                              const Color(0xFF071120).withValues(alpha: 0.94),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 18,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SwipeActions(
                          isDeleting: controller.isDeleting,
                          onDelete: _deleteCurrent,
                          onKeep: controller.closeAssetReview,
                        ),
                        const SizedBox(height: 18),
                        _SwipeReviewStats(
                          controller: controller,
                          reviewed: reviewed,
                          total: total,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteCurrent() async {
    if (controller.isDeleting) {
      return;
    }
    setState(() => _dragDx = -220);
    final deleted = await controller.deleteReviewAsset();
    if (!deleted) {
      if (mounted) {
        setState(() => _dragDx = 0);
      }
      Get.snackbar(
        'Nothing deleted'.tr,
        'The system did not remove this photo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF111929),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}

class _SwipeReviewHeader extends StatelessWidget {
  const _SwipeReviewHeader({
    required this.asset,
    required this.title,
    required this.progress,
    required this.onBack,
  });

  final AssetEntity asset;
  final String title;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      child: Column(
        children: [
          Row(
            children: [
              _CircleIconButton(icon: LucideIcons.chevronLeft, onTap: onBack),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _monthYearLabel(asset.createDateTime),
                      style: const TextStyle(
                        color: Color(0xFF697589),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _CircleIconButton(icon: LucideIcons.rotateCcw, onTap: onBack),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              color: const Color(0xFF18D0B8),
              backgroundColor: const Color(0xFF172231),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipePhotoCard extends StatelessWidget {
  const _SwipePhotoCard({required this.asset, required this.subtitle});

  final AssetEntity asset;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF142034),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18D0B8).withValues(alpha: 0.07),
            blurRadius: 42,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ReviewPhoto(asset: asset),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.02),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(left: 12, top: 14, child: _AiDeleteBadge()),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _shortDateTimeLabel(asset.createDateTime),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewPhoto extends StatelessWidget {
  const _ReviewPhoto({required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(
        const ThumbnailSize(900, 1200),
        quality: 92,
      ),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const ColoredBox(
            color: Color(0xFF347E62),
            child: Center(
              child: Icon(
                LucideIcons.image,
                color: Color(0xFF9ED1C2),
                size: 42,
              ),
            ),
          );
        }

        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      },
    );
  }
}

class _AiDeleteBadge extends StatelessWidget {
  const _AiDeleteBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF18D0B8).withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(11),
      ),
      alignment: Alignment.center,
      child: const Text(
        'AI - SUGGESTS DELETE',
        style: TextStyle(
          color: Color(0xFF55F2D9),
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _KeepBadge extends StatelessWidget {
  const _KeepBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF18D0B8),
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: const Text(
        'KEEP',
        style: TextStyle(
          color: Color(0xFF062322),
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _AutoCleanBar extends StatelessWidget {
  const _AutoCleanBar({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        controller.autoSelectDuplicateExtras();
        if (controller.selectedIds.isEmpty) {
          Get.snackbar(
            'Nothing to clean',
            'No extra duplicate copies were found.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF111929),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return;
        }
        await confirmAndDeleteSelected(controller);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF18D0B8).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF18D0B8).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.wand2, color: Color(0xFF18D0B8), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-clean duplicates',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Removes extra copies, keeps one of each set',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Color(0xFF18D0B8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeActions extends StatelessWidget {
  const _SwipeActions({
    required this.isDeleting,
    required this.onDelete,
    required this.onKeep,
  });

  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundActionButton(
          color: const Color(0xFFFF7A5F),
          shadowColor: const Color(0xFFFF7A5F),
          icon: isDeleting ? null : LucideIcons.trash2,
          onTap: isDeleting ? null : onDelete,
          child: isDeleting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 22),
        _RoundActionButton(
          color: const Color(0xFFA8CDAF),
          shadowColor: const Color(0xFFA8CDAF),
          icon: LucideIcons.heart,
          onTap: isDeleting ? null : onKeep,
        ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.color,
    required this.shadowColor,
    required this.onTap,
    this.icon,
    this.child,
  });

  final Color color;
  final Color shadowColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 34,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.34),
              blurRadius: 24,
              offset: const Offset(0, 13),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child ?? Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E2A3D)),
        ),
        child: Icon(icon, color: const Color(0xFF697589), size: 14),
      ),
    );
  }
}

class _SwipeReviewStats extends StatelessWidget {
  const _SwipeReviewStats({
    required this.controller,
    required this.reviewed,
    required this.total,
  });

  final SimilarPhotosController controller;
  final int reviewed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text:
                '${_formatNumber(reviewed)} of ${_formatNumber(total)} reviewed - ',
          ),
          TextSpan(
            text: _formatSavedBytes(controller.swipeSavedBytes),
            style: const TextStyle(color: Color(0xFF18D0B8)),
          ),
          const TextSpan(text: ' saved'),
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final shown = controller.assets.length;
    final noun = controller.mode.isVideos
        ? 'videos'
        : controller.mode.isScreenshots
        ? 'screenshots'
        : controller.mode.isDuplicates
        ? 'duplicate photos'
        : controller.mode.isInvisible
        ? 'invisible photos'
        : controller.mode.isBlurred
        ? 'blurred photos'
        : controller.mode.isLargeFiles
        ? 'files'
        : 'photos';
    final sortNote = controller.mode.isVideos
        ? 'Largest videos shown first'
        : controller.mode.isScreenshots
        ? 'Gallery screenshots ready to review'
        : controller.mode.isDuplicates
        ? 'Likely duplicate pictures ready to review'
        : controller.mode.isInvisible
        ? 'Hidden and private albums ready to review'
        : controller.mode.isBlurred
        ? controller.blurScanTotal > 0
              ? '${controller.blurScanDone} of ${controller.blurScanTotal} scanned'
              : 'Blurriest pictures shown first'
        : controller.mode.isLargeFiles
        ? 'Sorted from largest to smallest'
        : 'Recent photos ready to review';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${controller.totalCount} $noun',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$shown loaded - $sortNote',
          style: TextStyle(
            color: AppColors.textMuted(context),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BlurScanState extends StatelessWidget {
  const _BlurScanState({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.blurScanTotal == 0
        ? 0.0
        : controller.blurScanDone / controller.blurScanTotal;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.focus, color: Color(0xFF18D0B8), size: 42),
            const SizedBox(height: 18),
            Text(
              'Scanning for blurred photos'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.blurScanDone} of ${controller.blurScanTotal} scanned',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 7,
                color: const Color(0xFF18D0B8),
                backgroundColor: const Color(0xFF172231),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessState extends StatelessWidget {
  const _AccessState({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: LucideIcons.image,
      title: 'Photo access needed'.tr,
      body: 'Allow access to show your ${_mediaName(controller.mode)} here.'.tr,
      primaryLabel: 'Open Settings',
      onPrimary: controller.openSettings,
      secondaryLabel: 'Try Again',
      onSecondary: controller.loadAssets,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: controller.mode.isVideos
          ? LucideIcons.video
          : controller.mode.isScreenshots
          ? LucideIcons.camera
          : controller.mode.isDuplicates
          ? LucideIcons.copy
          : controller.mode.isInvisible
          ? LucideIcons.eyeOff
          : controller.mode.isBlurred
          ? LucideIcons.focus
          : controller.mode.isLargeFiles
          ? LucideIcons.file
          : LucideIcons.image,
      title: controller.mode.emptyTitle,
      body: controller.mode.emptyBody,
      primaryLabel: 'Refresh',
      onPrimary: controller.loadAssets,
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF18D0B8), size: 42),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: onPrimary,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF18D0B8),
                foregroundColor: const Color(0xFF062322),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              child: Text(primaryLabel),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onSecondary,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF18D0B8),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.asset,
    required this.isVideo,
    required this.byteSize,
    required this.detailLabel,
    required this.selected,
    required this.onTap,
    this.keep = false,
  });

  final AssetEntity asset;
  final bool isVideo;
  final int? byteSize;
  final String detailLabel;
  final bool selected;
  final VoidCallback onTap;
  final bool keep;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF111929),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF18D0B8) : const Color(0xFF1E2A3D),
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Thumbnail(asset: asset),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
              ),
              if (isVideo)
                Positioned(
                  left: 7,
                  bottom: 7,
                  child: _Pill(
                    icon: LucideIcons.play,
                    label: _formatDuration(asset.videoDuration),
                  ),
                ),
              if (keep && !selected)
                const Positioned(left: 7, top: 7, child: _KeepBadge()),
              Positioned(
                right: 7,
                top: 7,
                child: _SelectionMark(selected: selected),
              ),
              Positioned(
                left: 7,
                right: 7,
                bottom: isVideo ? 32 : 8,
                child: Text(
                  detailLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(
        const ThumbnailSize(360, 460),
        quality: 82,
      ),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const ColoredBox(
            color: Color(0xFF172133),
            child: Center(
              child: Icon(
                LucideIcons.image,
                color: Color(0xFF687384),
                size: 24,
              ),
            ),
          );
        }

        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      },
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF18D0B8)
            : Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? const Color(0xFF18D0B8)
              : Colors.white.withValues(alpha: 0.65),
        ),
      ),
      child: selected
          ? const Icon(LucideIcons.check, size: 14, color: Color(0xFF062322))
          : null,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolHeader extends StatelessWidget {
  const _ToolHeader({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        controller.assets.isNotEmpty &&
        controller.selectedIds.length == controller.assets.length;

    return SiftTopAppBar(
      title: controller.mode.title,
      trailing: TextButton(
        onPressed: controller.assets.isEmpty
            ? null
            : controller.toggleSelectAll,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF18D0B8),
          disabledForegroundColor: const Color(0xFF4A5362),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: Text(allSelected ? 'clear'.tr : 'select_all'.tr),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final selectedCount = controller.selectedIds.length;
    final enabled = selectedCount > 0 && !controller.isDeleting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: TextButton.icon(
          onPressed: enabled ? () => confirmAndDeleteSelected(controller) : null,
          icon: controller.isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(LucideIcons.trash, size: 18),
          label: Text(
            controller.isDeleting
                ? 'Deleting...'
                : 'Delete selected ($selectedCount)',
          ),
          style: TextButton.styleFrom(
            disabledBackgroundColor: AppColors.isLight(context)
                ? AppColors.lightBorder
                : const Color(0xFF111929),
            disabledForegroundColor: const Color(0xFF586274),
            backgroundColor: const Color(0xFFFF7A5F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

}

Future<void> confirmAndDeleteSelected(SimilarPhotosController controller) async {
  final mediaName = _mediaName(controller.mode);
  final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF111929),
        title: const Text(
          'Delete selected?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'This will ask the device photo library to delete ${controller.selectedIds.length} $mediaName.',
          style: const TextStyle(color: Color(0xFFC2CAD6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF7A5F),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

  final deleted = await controller.deleteSelected();
  Get.snackbar(
    deleted == 0 ? 'Nothing deleted' : 'Deleted $deleted',
    deleted == 0
        ? 'The system did not remove any items.'
        : controller.mode.isDuplicates
        ? 'Extra copies removed. One copy of each set was kept.'
        : 'Your library has been updated.',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF111929),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
  );
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '${duration.inMinutes}:$seconds';
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (date.year < 2000) {
    return 'Recent';
  }
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _formatBytes(int? bytes) {
  if (bytes == null || bytes <= 0) {
    return 'Size unavailable';
  }

  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size = size / 1024;
    unitIndex++;
  }

  final decimals = size >= 10 || unitIndex == 0 ? 0 : 1;
  return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
}

String _mediaName(MediaCleanupMode mode) {
  if (mode.isVideos) {
    return 'videos';
  }
  if (mode.isScreenshots) {
    return 'screenshots';
  }
  if (mode.isDuplicates) {
    return 'duplicate photos';
  }
  if (mode.isInvisible) {
    return 'invisible photos';
  }
  if (mode.isLargeFiles) {
    return 'files';
  }
  return 'photos';
}

String _assetDetailLabel(
  SimilarPhotosController controller,
  AssetEntity asset,
) {
  if (controller.mode.isLargeFiles || controller.mode.isVideos) {
    return _formatBytes(controller.assetByteSizes[asset.id]);
  }
  if (controller.mode.isDuplicates) {
    final count = controller.duplicateGroupCounts[asset.id] ?? 2;
    return '$count duplicates - ${_formatBytes(controller.assetByteSizes[asset.id])}';
  }
  if (controller.mode.isBlurred) {
    final variance = controller.blurResults[asset.id]?.variance;
    if (variance == null) {
      return 'Blur detected';
    }
    return 'Blur score ${variance.toStringAsFixed(1)}';
  }
  return _formatDate(asset.createDateTime);
}

String _reviewDetailLabel(
  SimilarPhotosController controller,
  AssetEntity asset,
) {
  if (controller.mode.isDuplicates) {
    final count = controller.duplicateGroupCounts[asset.id] ?? 2;
    return 'Very similar to ${count - 1} others';
  }
  return 'Very similar to 3 others';
}

String _monthYearLabel(DateTime date) {
  if (date.year < 2000) {
    return 'RECENT';
  }
  return '${_monthName(date.month).toUpperCase()} ${date.year}';
}

String _shortDateTimeLabel(DateTime date) {
  if (date.year < 2000) {
    return 'Recent';
  }
  final hour = date.hour == 0
      ? 12
      : date.hour > 12
      ? date.hour - 12
      : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${_monthName(date.month)} ${date.day} - $hour:$minute $period';
}

String _monthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[(month - 1).clamp(0, 11)];
}

String _formatSavedBytes(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }
  return _formatBytes(bytes).replaceFirst('Size unavailable', '0 B');
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final fromEnd = text.length - i;
    buffer.write(text[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}
