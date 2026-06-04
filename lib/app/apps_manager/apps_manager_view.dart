import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/apps_manager/apps_manager_controller.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';

class AppsManagerView extends StatelessWidget {
  const AppsManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppsManagerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                SiftTopAppBar(title: 'apps_manager'.tr),
                Expanded(child: _AppsBody(controller: controller)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppsBody extends StatelessWidget {
  const _AppsBody({required this.controller});

  final AppsManagerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const ListShimmer();
    }

    if (controller.errorMessage != null) {
      return _CenteredState(
        icon: LucideIcons.smartphone,
        title: 'Apps unavailable',
        body: controller.errorMessage!,
        label: 'Try Again',
        onPressed: controller.loadApps,
      );
    }

    if (controller.apps.isEmpty) {
      return _CenteredState(
        icon: LucideIcons.packageSearch,
        title: 'No apps found',
        body: 'Installed apps will appear here when Android allows access.',
        label: 'Refresh',
        onPressed: controller.loadApps,
      );
    }

    final apps = controller.sortedApps;

    return RefreshIndicator(
      color: const Color(0xFF18D0B8),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF111929),
      onRefresh: controller.loadApps,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.apps.length} apps',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 25,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_formatBytes(controller.totalBytes)} total',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (!controller.hasUsageAccess) ...[
              const SizedBox(height: 14),
              _UsageAccessBanner(controller: controller),
            ],
            const SizedBox(height: 22),
            _SortTabs(controller: controller),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.surface(context)
                    : AppColors.surface(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Column(
                children: [for (final app in apps) _AppRow(data: app)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageAccessBanner extends StatelessWidget {
  const _UsageAccessBanner({required this.controller});

  final AppsManagerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.surface(context)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.clock3, color: Color(0xFFFFD34D), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Allow usage access to sort by real last-used time.',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 11,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: controller.openUsageAccessSettings,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF18D0B8),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }
}

class _SortTabs extends StatelessWidget {
  const _SortTabs({required this.controller});

  final AppsManagerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.surface(context)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          for (final mode in AppSortMode.values)
            Expanded(
              child: _SortChip(
                label: mode.label,
                active: controller.sortMode == mode,
                onTap: () => controller.setSortMode(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? (AppColors.isLight(context)
                    ? const Color(0xFFE6F5F2)
                    : const Color(0xFF394251))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? AppColors.textPrimary(context)
                : AppColors.textMuted(context),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.data});

  final ManagedApp data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.iconBytes == null
                  ? _appColor(data.name)
                  : const Color(0xFF0E1726),
              borderRadius: BorderRadius.circular(11),
            ),
            clipBehavior: Clip.antiAlias,
            child: data.iconBytes == null
                ? Text(
                    data.letter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : Image.memory(
                    data.iconBytes!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatBytes(data.sizeBytes)} - ${_formatLastUsed(data.lastUsed)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 10,
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

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.body,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final String label;
  final VoidCallback onPressed;

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
              onPressed: onPressed,
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
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

Color _appColor(String value) {
  const colors = [
    Color(0xFFE15345),
    Color(0xFFD04B58),
    Color(0xFFC83878),
    Color(0xFF48C35A),
    Color(0xFF2FB65E),
    Color(0xFF9A45D7),
    Color(0xFF4777C9),
  ];
  return colors[value.hashCode.abs() % colors.length];
}

String _formatBytes(int bytes) {
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

String _formatLastUsed(DateTime? value) {
  if (value == null) {
    return 'Last used unknown';
  }

  final now = DateTime.now();
  final difference = now.difference(value);
  if (difference.inDays <= 0) {
    return 'Today';
  }
  if (difference.inDays == 1) {
    return '1 day ago';
  }
  if (difference.inDays < 30) {
    return '${difference.inDays} days ago';
  }
  if (difference.inDays < 365) {
    final months = difference.inDays ~/ 30;
    return months == 1 ? '1 month ago' : '$months months ago';
  }
  final years = difference.inDays ~/ 365;
  return years == 1 ? '1 year ago' : '$years years ago';
}
