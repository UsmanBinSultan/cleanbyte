import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/photo_compressor/photo_compressor_controller.dart';
import 'package:sift/app/photo_compressor/widgets/compress_button.dart';
import 'package:sift/app/photo_compressor/widgets/compressor_body.dart';

/// Photo Compressor: pick photos and save smaller JPEG copies. Sub-widgets live
/// under `widgets/`.
class PhotoCompressorView extends StatelessWidget {
  const PhotoCompressorView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhotoCompressorController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                SiftTopAppBar(title: 'photo_compressor'.tr),
                Expanded(child: CompressorBody(controller: controller)),
                CompressButton(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}
