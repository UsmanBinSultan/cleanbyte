import 'package:flutter/material.dart';
import 'package:sift/app/swipe_cleaner/swipe_cleaner_controller.dart';
import 'package:sift/app/swipe_cleaner/widgets/swipe_action_bar.dart';
import 'package:sift/app/swipe_cleaner/widgets/swipe_photo_card.dart';

/// Interactive swipe deck plus its action bar. Holds the gesture/animation
/// state; all keep/delete decisions are delegated to the controller.
class SwipeArea extends StatefulWidget {
  const SwipeArea({super.key, required this.controller});

  final SwipeCleanerController controller;

  @override
  State<SwipeArea> createState() => _SwipeAreaState();
}

class _SwipeAreaState extends State<SwipeArea>
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
    _anim =
        AnimationController(
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
                      child: SwipePhotoCard(asset: upNext, interactive: false),
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
                        child: SwipePhotoCard(
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
        SwipeActionBar(
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
