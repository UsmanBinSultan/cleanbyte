import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/app/photos/widgets/swipe_actions.dart';
import 'package:sift/app/photos/widgets/swipe_hints.dart';
import 'package:sift/app/photos/widgets/swipe_photo_card.dart';
import 'package:sift/app/photos/widgets/swipe_review_header.dart';

/// Full-screen Tinder-style review pane for the photos mode — drag the card
/// left to delete, right to keep, with matching action buttons.
class SwipeReviewPane extends StatefulWidget {
  const SwipeReviewPane({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  State<SwipeReviewPane> createState() => _SwipeReviewPaneState();
}

class _SwipeReviewPaneState extends State<SwipeReviewPane> {
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
    final width = MediaQuery.sizeOf(context).width;
    final ratio = (_dragDx / (width * 0.5)).clamp(-1.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Column(
        children: [
          SwipeReviewHeader(
            asset: asset,
            reviewed: reviewed,
            total: total,
            progress: progress.clamp(0.0, 1.0),
            savedBytes: controller.swipeSavedBytes,
            onBack: controller.closeAssetReview,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() => _dragDx += details.delta.dx);
              },
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (_dragDx < -86 || velocity < -420) {
                  _deleteCurrent();
                } else if (_dragDx > 86 || velocity > 420) {
                  controller.keepReviewAsset();
                  setState(() => _dragDx = 0);
                } else {
                  setState(() => _dragDx = 0);
                }
              },
              child: Transform.translate(
                offset: Offset(_dragDx, 0),
                child: Transform.rotate(
                  angle: ratio * 0.12,
                  child: SwipePhotoCard(
                    asset: asset,
                    subtitle: controller.reviewDetailLabel(asset),
                    keepOpacity: ratio > 0 ? ratio : 0,
                    deleteOpacity: ratio < 0 ? -ratio : 0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SwipeHints(),
          const SizedBox(height: 14),
          SwipeActions(
            isDeleting: controller.isDeleting,
            onDelete: _deleteCurrent,
            onSkip: () {
              controller.skipReviewAsset();
              setState(() => _dragDx = 0);
            },
            onKeep: () {
              controller.keepReviewAsset();
              setState(() => _dragDx = 0);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCurrent() async {
    if (controller.isDeleting) {
      return;
    }
    final deleted = await controller.deleteReviewAsset();
    if (mounted) {
      setState(() => _dragDx = 0);
    }
    if (!deleted) {
      Get.snackbar(
        'Nothing deleted'.tr,
        'The system did not remove this photo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
