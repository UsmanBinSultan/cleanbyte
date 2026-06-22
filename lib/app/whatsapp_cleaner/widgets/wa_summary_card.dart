import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// Green gradient hero card on the cleaner hub: total WhatsApp storage, a
/// per-type segment bar and a colour legend.
class WaSummaryCard extends StatelessWidget {
  const WaSummaryCard({super.key, required this.controller});

  final WhatsappCleanerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: controller.isLoadingSummary
                    ? const LoadingShimmer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SummaryBlock(width: 120, height: 14),
                            SizedBox(height: 10),
                            _SummaryBlock(width: 92, height: 34),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WHATSAPP IS USING',
                            style: TextStyle(
                              color: Color(0x8CFFFFFF),
                              fontSize: 11,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatBytes(controller.totalBytes),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              height: 1.1,
                              letterSpacing: -1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: 'Clean Byte can recover up to ',
                              children: [
                                TextSpan(
                                  text: formatBytes(controller.totalBytes),
                                  style: const TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(
                              color: Color(0x99FFFFFF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/icons/whatsapp.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF4ADE80),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _WaSegmentBar(controller: controller),
          const SizedBox(height: 8),
          Row(
            children: const [
              _LegendDot(color: Color(0xFFEF4444), label: 'Videos'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFF59E0B), label: 'Images'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFF8B5CF6), label: 'Voice'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFF3B82F6), label: 'Docs'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaSegmentBar extends StatelessWidget {
  const _WaSegmentBar({required this.controller});

  final WhatsappCleanerController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.totalBytes <= 0 ? 1 : controller.totalBytes;
    final colors = {
      WhatsappMediaType.videos: const Color(0xFFEF4444),
      WhatsappMediaType.images: const Color(0xFFF59E0B),
      WhatsappMediaType.voiceNotes: const Color(0xFF8B5CF6),
      WhatsappMediaType.documents: const Color(0xFF3B82F6),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Row(
        children: [
          for (final type in [
            WhatsappMediaType.videos,
            WhatsappMediaType.images,
            WhatsappMediaType.voiceNotes,
            WhatsappMediaType.documents,
          ])
            Expanded(
              flex: ((controller.bytesByType[type] ?? 0) / total * 100)
                  .round()
                  .clamp(4, 100),
              child: Container(height: 6, color: colors[type]),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0x8CFFFFFF), fontSize: 9),
        ),
      ],
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
