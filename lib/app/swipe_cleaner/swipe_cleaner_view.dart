import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/swipe_cleaner/swipe_cleaner_controller.dart';
import 'package:sift/core/utils/formatters.dart';

class SwipeCleanerView extends StatelessWidget {
  const SwipeCleanerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SwipeCleanerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    _SwipeTopBar(controller: controller),
                    Expanded(child: _Body(controller: controller)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SwipeTopBar extends StatelessWidget {
  const _SwipeTopBar({required this.controller});

  final SwipeCleanerController controller;

  @override
  Widget build(BuildContext context) {
    final reviewing =
        controller.hasAccess && controller.total > 0 && !controller.isComplete;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Icon(
                LucideIcons.chevronLeft,
                size: 18,
                color: AppColors.textMuted(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Swipe Cleaner',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  reviewing
                      ? '${controller.reviewedCount} of ${controller.total} reviewed'
                      : 'Keep favorites · delete clutter',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (reviewing && controller.markedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.trash2, size: 13, color: AppColors.danger),
                  const SizedBox(width: 5),
                  Text(
                    '${controller.markedCount}',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});

  final SwipeCleanerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (!controller.hasAccess) {
      return _EmptyState(
        icon: LucideIcons.lock,
        title: 'Photo access needed',
        body: 'Allow photo access so Swipe Cleaner can show your library.',
        actionLabel: 'Open Settings',
        onAction: controller.openSettings,
      );
    }
    if (controller.total == 0) {
      return _EmptyState(
        icon: LucideIcons.imageOff,
        title: 'No photos to review',
        body: 'Photos from your library will appear here to swipe through.',
        actionLabel: 'Refresh',
        onAction: controller.load,
      );
    }
    if (controller.isComplete) {
      return _CompleteState(controller: controller);
    }
    return _SwipeArea(controller: controller);
  }
}

// ---------------------------------------------------------------------------
// Interactive swipe deck + action buttons. Holds the gesture/animation state;
// all decisions are delegated to the controller.
// ---------------------------------------------------------------------------
class _SwipeArea extends StatefulWidget {
  const _SwipeArea({required this.controller});

  final SwipeCleanerController controller;

  @override
  State<_SwipeArea> createState() => _SwipeAreaState();
}

class _SwipeAreaState extends State<_SwipeArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Offset _drag = Offset.zero;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  bool _keepDecision = true;
  bool _animatingOut = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    )
      ..addListener(_onTick)
      ..addStatusListener(_onStatus);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onTick() {
    setState(() {
      _drag = Offset.lerp(_from, _to, Curves.easeOut.transform(_anim.value))!;
    });
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    if (_animatingOut) {
      if (_keepDecision) {
        widget.controller.keep();
      } else {
        widget.controller.markForDeletion();
      }
    }
    _animatingOut = false;
    _drag = Offset.zero;
    _anim.reset();
    setState(() {});
  }

  void _flingOut(bool keep) {
    if (_anim.isAnimating) {
      return;
    }
    final width = MediaQuery.sizeOf(context).width;
    _keepDecision = keep;
    _animatingOut = true;
    _from = _drag;
    _to = Offset(keep ? width * 1.4 : -width * 1.4, _drag.dy);
    _anim.forward(from: 0);
  }

  void _settleBack() {
    _animatingOut = false;
    _from = _drag;
    _to = Offset.zero;
    _anim.forward(from: 0);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_anim.isAnimating) {
      return;
    }
    setState(() => _drag += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_anim.isAnimating) {
      return;
    }
    final threshold = MediaQuery.sizeOf(context).width * 0.22;
    if (_drag.dx.abs() > threshold) {
      _flingOut(_drag.dx > 0);
    } else {
      _settleBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final current = controller.current;
    final upNext = controller.upNext;
    final width = MediaQuery.sizeOf(context).width;
    final ratio = (_drag.dx / (width * 0.5)).clamp(-1.0, 1.0);
    final angle = ratio * 0.18;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (upNext != null)
                  Transform.scale(
                    scale: 0.94,
                    child: Transform.translate(
                      offset: const Offset(0, 14),
                      child: _PhotoCard(asset: upNext, interactive: false),
                    ),
                  ),
                if (current != null)
                  Transform.translate(
                    offset: _drag,
                    child: Transform.rotate(
                      angle: angle,
                      child: GestureDetector(
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: _PhotoCard(
                          asset: current,
                          interactive: true,
                          keepOpacity: ratio > 0 ? ratio : 0,
                          deleteOpacity: ratio < 0 ? -ratio : 0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _ActionBar(
          controller: controller,
          busy: _anim.isAnimating,
          onUndo: controller.canUndo
              ? () {
                  controller.undo();
                  setState(() => _drag = Offset.zero);
                }
              : null,
          onDelete: () => _flingOut(false),
          onKeep: () => _flingOut(true),
        ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.asset,
    required this.interactive,
    this.keepOpacity = 0,
    this.deleteOpacity = 0,
  });

  final AssetEntity asset;
  final bool interactive;
  final double keepOpacity;
  final double deleteOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetThumbnail(
            asset: asset,
            size: const ThumbnailSize(600, 800),
          ),
          // Bottom scrim for legible caption.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  shortDateTimeLabel(asset.createDateTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (interactive) ...[
            _DecisionStamp(
              label: 'KEEP',
              color: AppColors.accent,
              alignment: Alignment.topLeft,
              angle: -0.35,
              opacity: keepOpacity,
            ),
            _DecisionStamp(
              label: 'DELETE',
              color: AppColors.danger,
              alignment: Alignment.topRight,
              angle: 0.35,
              opacity: deleteOpacity,
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionStamp extends StatelessWidget {
  const _DecisionStamp({
    required this.label,
    required this.color,
    required this.alignment,
    required this.angle,
    required this.opacity,
  });

  final String label;
  final Color color;
  final Alignment alignment;
  final double angle;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Opacity(
          opacity: opacity.clamp(0, 1),
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 3),
                color: color.withValues(alpha: 0.18),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.controller,
    required this.busy,
    required this.onUndo,
    required this.onDelete,
    required this.onKeep,
  });

  final SwipeCleanerController controller;
  final bool busy;
  final VoidCallback? onUndo;
  final VoidCallback onDelete;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          if (controller.markedCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${controller.markedCount} marked · frees ~${formatBytes(controller.markedBytes)}',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundAction(
                icon: LucideIcons.undo2,
                color: AppColors.iconAmber,
                size: 52,
                onTap: busy ? null : onUndo,
              ),
              const SizedBox(width: 22),
              _RoundAction(
                icon: LucideIcons.x,
                color: AppColors.danger,
                size: 68,
                filled: true,
                onTap: busy ? null : onDelete,
              ),
              const SizedBox(width: 22),
              _RoundAction(
                icon: LucideIcons.heart,
                color: AppColors.accent,
                size: 68,
                filled: true,
                onTap: busy ? null : onKeep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: filled ? color : AppColors.surface(context),
            shape: BoxShape.circle,
            border: filled ? null : Border.all(color: color.withValues(alpha: 0.4)),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.32),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: filled ? Colors.white : color,
            size: size * 0.42,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Completion + empty states
// ---------------------------------------------------------------------------
class _CompleteState extends StatelessWidget {
  const _CompleteState({required this.controller});

  final SwipeCleanerController controller;

  Future<void> _commit(BuildContext context) async {
    final removed = await controller.commit();
    Get.snackbar(
      'Swipe Cleaner',
      removed > 0
          ? 'Moved $removed ${removed == 1 ? 'photo' : 'photos'} to the recycle bin.'
          : 'Nothing was removed.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final marked = controller.markedCount;
    final done = controller.didCommit;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintTeal,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? LucideIcons.check : LucideIcons.sparkles,
              size: 36,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            done ? 'All done!' : 'Review complete',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            done
                ? 'Cleaned-up photos are safe in the recycle bin for 30 days.'
                : '${controller.keptCount} kept · $marked marked for deletion.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          if (!done && marked > 0)
            _PrimaryButton(
              label: 'Delete $marked ${marked == 1 ? 'photo' : 'photos'}'
                  ' · frees ~${formatBytes(controller.markedBytes)}',
              color: AppColors.danger,
              icon: LucideIcons.trash2,
              busy: controller.isCommitting,
              onTap: () => _commit(context),
            ),
          if (!done && marked > 0) const SizedBox(height: 12),
          _PrimaryButton(
            label: 'Review again',
            gradient: true,
            icon: LucideIcons.refreshCw,
            onTap: controller.load,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Back to home',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.surfaceTint(context),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.textMuted(context)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _PrimaryButton(
              label: actionLabel,
              gradient: true,
              onTap: onAction,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.gradient = false,
    this.color,
    this.busy = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool gradient;
  final Color? color;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient ? AppColors.accentGradient : null,
        color: gradient ? null : color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton(
        onPressed: busy ? null : onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
