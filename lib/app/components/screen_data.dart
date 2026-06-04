// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:sift/app/components/app_colors.dart';
// import 'package:sift/app/components/cleaner_screen_scaffold.dart';
// import 'package:sift/app/routes/app_routes.dart';

// class ScreenData {
//   static final Map<String, CleanerScreenConfig> configs = {
//     AppRoutes.splash: CleanerScreenConfig(
//       title: 'Cleaner.',
//       kicker: '01 - BRAND REVEAL',
//       subtitle:
//           'A premium phone cleaner built around trust, calm controls, and real storage savings.',
//       icon: LucideIcons.sparkles,
//       route: AppRoutes.splash,
//       nextRoute: AppRoutes.problemFraming,
//       accent: AppColors.accent,
//       showBack: false,
//       stats: const [
//         MetricTile('Library', '124 GB', AppColors.fg),
//         MetricTile('Recoverable', '18.6 GB', AppColors.accent),
//         MetricTile('Privacy', 'On device', AppColors.sage),
//         MetricTile('Pricing', 'Honest', AppColors.amber),
//       ],
//       items: const [
//         FeatureRow(
//           'No fake boosts',
//           'Only real files and clear recommendations.',
//           LucideIcons.shield,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'Apple-native craft',
//           'Dark, compact, scan-friendly mobile UI.',
//           LucideIcons.smartphone,
//           AppColors.sage,
//         ),
//         FeatureRow(
//           'Transparent Pro',
//           'No countdowns, traps, or hidden renewal copy.',
//           LucideIcons.heart,
//           AppColors.coral,
//         ),
//       ],
//     ),
//     AppRoutes.problemFraming: CleanerScreenConfig(
//       title: 'Your storage is full of almost-duplicates.',
//       kicker: '02 - ONBOARDING',
//       subtitle:
//           'Cleaner groups similar photos, large videos, screenshots, and forgotten files before you decide what goes.',
//       icon: LucideIcons.image,
//       route: AppRoutes.problemFraming,
//       nextRoute: AppRoutes.privacyPromise,
//       accent: AppColors.amber,
//       stats: const [
//         MetricTile('Similar', '1,247', AppColors.amber),
//         MetricTile('Videos', '89', AppColors.coral),
//         MetricTile('Screenshots', '432', AppColors.accent),
//         MetricTile('Space', '18.6 GB', AppColors.fg),
//       ],
//       items: const [
//         FeatureRow(
//           'Smart clusters',
//           'Keep the best shot and review the rest fast.',
//           LucideIcons.grid,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'Large files first',
//           'Sorts cleanup by real space impact.',
//           LucideIcons.video,
//           AppColors.coral,
//         ),
//         FeatureRow(
//           'Never automatic',
//           'You approve every delete action.',
//           LucideIcons.check,
//           AppColors.sage,
//         ),
//       ],
//     ),
//     AppRoutes.privacyPromise: CleanerScreenConfig(
//       title: 'Private by default.',
//       kicker: '03 - PRIVACY PROMISE',
//       subtitle:
//           'The prototype emphasizes on-device analysis and plain-language permission copy instead of fear tactics.',
//       icon: LucideIcons.lock,
//       route: AppRoutes.privacyPromise,
//       nextRoute: AppRoutes.permissionRationale,
//       accent: AppColors.sage,
//       stats: const [
//         MetricTile('Upload', '0 files', AppColors.sage),
//         MetricTile('AI', 'Local', AppColors.accent),
//         MetricTile('Ads', 'None', AppColors.fg),
//         MetricTile('Tracking', 'Off', AppColors.coral),
//       ],
//       items: const [
//         FeatureRow(
//           'Photos stay yours',
//           'Analysis happens on the phone whenever possible.',
//           LucideIcons.image,
//           AppColors.sage,
//         ),
//         FeatureRow(
//           'Clear receipts',
//           'Every action is reviewable before cleanup.',
//           LucideIcons.fileText,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'No dark patterns',
//           'The trust wedge is part of the product.',
//           LucideIcons.heart,
//           AppColors.coral,
//         ),
//       ],
//     ),
//     AppRoutes.permissionRationale: CleanerScreenConfig(
//       title: 'Cleaner needs photo access to find clutter.',
//       kicker: '04 - PERMISSIONS',
//       subtitle:
//           'The app explains why access matters before showing the system prompt.',
//       icon: LucideIcons.camera,
//       route: AppRoutes.permissionRationale,
//       nextRoute: AppRoutes.initialScan,
//       accent: AppColors.accent,
//       stats: const [
//         MetricTile('Photos', 'Needed', AppColors.accent),
//         MetricTile('Contacts', 'Never', AppColors.sage),
//         MetricTile('Location', 'Never', AppColors.sage),
//         MetricTile('Microphone', 'Never', AppColors.sage),
//       ],
//       items: const [
//         FeatureRow(
//           'Find duplicates',
//           'Groups near-identical images into review stacks.',
//           LucideIcons.image,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'Detect blur',
//           'Flags low-quality shots without judging memories.',
//           LucideIcons.eye,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'Keep control',
//           'You can limit access later in Settings.',
//           LucideIcons.settings,
//           AppColors.fgMuted,
//         ),
//       ],
//     ),
//     AppRoutes.initialScan: CleanerScreenConfig(
//       title: 'Analyzing your library...',
//       kicker: '05 - INITIAL SCAN',
//       subtitle:
//           'A calm scan state surfaces progress, found categories, and expected savings.',
//       icon: LucideIcons.scanLine,
//       route: AppRoutes.initialScan,
//       nextRoute: AppRoutes.paywall,
//       accent: AppColors.accent,
//       primaryAction: 'See cleanup plan',
//       stats: const [
//         MetricTile('Progress', '72%', AppColors.accent),
//         MetricTile('Found', '1,768', AppColors.fg),
//         MetricTile('Savings', '18.6 GB', AppColors.sage),
//         MetricTile('Time left', '24s', AppColors.amber),
//       ],
//       items: const [
//         FeatureRow(
//           'Similar photos',
//           '1,247 candidates grouped by scene.',
//           LucideIcons.image,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'Large videos',
//           '89 files sorted by size.',
//           LucideIcons.video,
//           AppColors.coral,
//         ),
//         FeatureRow(
//           'Screenshots',
//           '432 low-risk items ready to review.',
//           LucideIcons.image,
//           AppColors.amber,
//         ),
//       ],
//     ),
//     AppRoutes.paywall: CleanerScreenConfig(
//       title: 'Unlock Clean Byte Pro.',
//       kicker: '06 - CONVERSION',
//       subtitle:
//           'Three clear plans, yearly math, and transparent renewal language. No fake timers.',
//       icon: LucideIcons.crown,
//       route: AppRoutes.paywall,
//       nextRoute: AppRoutes.homeDashboard,
//       accent: AppColors.amber,
//       primaryAction: 'Start Pro',
//       stats: const [
//         MetricTile('Weekly', '\$3.99', AppColors.fg),
//         MetricTile('Monthly', '\$9.99', AppColors.accent),
//         MetricTile('Yearly', '\$34.99', AppColors.amber),
//         MetricTile('Trial', '3 days', AppColors.sage),
//       ],
//       items: const [
//         FeatureRow(
//           'Unlimited cleanup',
//           'Review every category without limits.',
//           LucideIcons.sparkles,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'AI categories',
//           'Pets, travel, receipts, food, and more.',
//           LucideIcons.cpu,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'Cancel any time',
//           'A real subscription screen is included.',
//           LucideIcons.undo2,
//           AppColors.sage,
//         ),
//       ],
//     ),
//     AppRoutes.homeDashboard: CleanerScreenConfig(
//       title: '18.6 GB can be cleaned.',
//       kicker: '07 - HOME DASHBOARD',
//       subtitle:
//           'The main hub prioritizes high-impact cleanup and gives every tool a clear next step.',
//       icon: LucideIcons.home,
//       route: AppRoutes.homeDashboard,
//       nextRoute: AppRoutes.similarPhotos,
//       accent: AppColors.accent,
//       primaryAction: 'Review similar photos',
//       showBack: false,
//       stats: const [
//         MetricTile('Photos', '8.4 GB', AppColors.accent),
//         MetricTile('Videos', '6.1 GB', AppColors.coral),
//         MetricTile('Apps', '2.8 GB', AppColors.amber),
//         MetricTile('Other', '1.3 GB', AppColors.sage),
//       ],
//       items: const [
//         FeatureRow(
//           'Similar photos',
//           'Best first pass for quick wins.',
//           LucideIcons.image,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'Swipe cleaner',
//           'Fast yes/no review for duplicate stacks.',
//           LucideIcons.heart,
//           AppColors.coral,
//         ),
//         FeatureRow(
//           'AI categories',
//           'Browse memories by meaningful themes.',
//           LucideIcons.sparkles,
//           AppColors.amber,
//         ),
//       ],
//     ),
//     AppRoutes.similarPhotos: CleanerScreenConfig(
//       title: 'Similar photos grouped by moment.',
//       kicker: '08 - PHOTO GRID',
//       subtitle:
//           'Dense cards, selection counts, and strong visual hierarchy keep review fast.',
//       icon: LucideIcons.grid,
//       route: AppRoutes.similarPhotos,
//       nextRoute: AppRoutes.swipeCleaner,
//       accent: AppColors.accent,
//       stats: const [
//         MetricTile('Groups', '284', AppColors.accent),
//         MetricTile('Selected', '963', AppColors.amber),
//         MetricTile('Keepers', '284', AppColors.sage),
//         MetricTile('Savings', '8.4 GB', AppColors.fg),
//       ],
//       items: const [
//         FeatureRow(
//           'Best shot pinned',
//           'Cleaner suggests one keeper per group.',
//           LucideIcons.star,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'Manual control',
//           'Tap any item to keep or remove.',
//           LucideIcons.check,
//           AppColors.sage,
//         ),
//         FeatureRow(
//           'Preview before delete',
//           'No silent cleanup actions.',
//           LucideIcons.eye,
//           AppColors.accent,
//         ),
//       ],
//     ),
//     AppRoutes.swipeCleaner: CleanerScreenConfig(
//       title: 'Swipe through clutter.',
//       kicker: '09 - SWIPE CLEANER',
//       subtitle:
//           'A viral review mode for quick decisions: keep favorites, delete obvious clutter, undo mistakes.',
//       icon: LucideIcons.heart,
//       route: AppRoutes.swipeCleaner,
//       nextRoute: AppRoutes.aiCategories,
//       accent: AppColors.coral,
//       stats: const [
//         MetricTile('Stack', '42', AppColors.coral),
//         MetricTile('Keep', '18', AppColors.sage),
//         MetricTile('Delete', '24', AppColors.amber),
//         MetricTile('Saved', '1.2 GB', AppColors.accent),
//       ],
//       items: const [
//         FeatureRow(
//           'Swipe left',
//           'Send weak duplicates to cleanup.',
//           LucideIcons.trash,
//           AppColors.coral,
//         ),
//         FeatureRow(
//           'Swipe right',
//           'Protect the photo as a keeper.',
//           LucideIcons.heart,
//           AppColors.sage,
//         ),
//         FeatureRow(
//           'Undo',
//           'Recover the last decision instantly.',
//           LucideIcons.undo2,
//           AppColors.amber,
//         ),
//       ],
//     ),
//     AppRoutes.aiCategories: CleanerScreenConfig(
//       title: 'AI categories that feel human.',
//       kicker: '10 - AI CATEGORIES',
//       subtitle:
//           'Cleaner organizes photos by themes like pets, food, travel, screenshots, and receipts.',
//       icon: LucideIcons.sparkles,
//       route: AppRoutes.aiCategories,
//       nextRoute: AppRoutes.processManager,
//       accent: AppColors.amber,
//       stats: const [
//         MetricTile('Pets', '482', AppColors.amber),
//         MetricTile('Travel', '916', AppColors.accent),
//         MetricTile('Food', '138', AppColors.coral),
//         MetricTile('Receipts', '77', AppColors.sage),
//       ],
//       items: const [
//         FeatureRow(
//           'Readable labels',
//           'No mysterious AI jargon in the UI.',
//           LucideIcons.tag,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'Theme cleanup',
//           'Delete screenshots or receipts in one focused pass.',
//           LucideIcons.fileText,
//           AppColors.sage,
//         ),
//         FeatureRow(
//           'Private analysis',
//           'Category detection remains privacy-forward.',
//           LucideIcons.lock,
//           AppColors.accent,
//         ),
//       ],
//     ),
//     AppRoutes.processManager: CleanerScreenConfig(
//       title: 'Process manager.',
//       kicker: '11 - TOOLS',
//       subtitle:
//           'A careful utility screen that explains what can be stopped and why.',
//       icon: LucideIcons.cpu,
//       route: AppRoutes.processManager,
//       nextRoute: AppRoutes.whatsappCleaner,
//       accent: AppColors.sage,
//       stats: const [
//         MetricTile('Running', '18', AppColors.fg),
//         MetricTile('Idle', '7', AppColors.amber),
//         MetricTile('Memory', '1.9 GB', AppColors.accent),
//         MetricTile('Risk', 'Low', AppColors.sage),
//       ],
//       items: const [
//         FeatureRow(
//           'Background helpers',
//           'Review low-priority processes.',
//           LucideIcons.circle,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'Memory view',
//           'See estimated memory pressure.',
//           LucideIcons.activity,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'No fake speed claims',
//           'The screen stays honest about limits.',
//           LucideIcons.shield,
//           AppColors.sage,
//         ),
//       ],
//     ),
//     AppRoutes.whatsappCleaner: CleanerScreenConfig(
//       title: 'WhatsApp media cleaner.',
//       kicker: '12 - WA CLEANER',
//       subtitle:
//           'Find forwarded videos, voice notes, documents, and old media without breaking conversations.',
//       icon: LucideIcons.messageCircle,
//       route: AppRoutes.whatsappCleaner,
//       nextRoute: AppRoutes.appsManager,
//       accent: AppColors.accent,
//       stats: const [
//         MetricTile('Videos', '3.8 GB', AppColors.coral),
//         MetricTile('Images', '1.4 GB', AppColors.accent),
//         MetricTile('Voice', '620 MB', AppColors.amber),
//         MetricTile('Docs', '410 MB', AppColors.sage),
//       ],
//       items: const [
//         FeatureRow(
//           'Forwarded media',
//           'Sort the biggest repeat offenders first.',
//           LucideIcons.video,
//           AppColors.coral,
//         ),
//         FeatureRow(
//           'Voice notes',
//           'Group old audio by size and date.',
//           LucideIcons.mic,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'Documents',
//           'Review files without touching chats.',
//           LucideIcons.fileText,
//           AppColors.sage,
//         ),
//       ],
//     ),
//     AppRoutes.appsManager: CleanerScreenConfig(
//       title: 'Installed apps by storage impact.',
//       kicker: '13 - APPS MANAGER',
//       subtitle:
//           'A clear app list highlights size, last used date, and cache-heavy candidates.',
//       icon: LucideIcons.layoutGrid,
//       route: AppRoutes.appsManager,
//       nextRoute: AppRoutes.photoCompressor,
//       accent: AppColors.amber,
//       stats: const [
//         MetricTile('Apps', '87', AppColors.fg),
//         MetricTile('Unused', '14', AppColors.amber),
//         MetricTile('Largest', '2.1 GB', AppColors.coral),
//         MetricTile('Cache', '2.8 GB', AppColors.accent),
//       ],
//       items: const [
//         FeatureRow(
//           'Unused apps',
//           'Surface things untouched for months.',
//           LucideIcons.clock,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'Cache-heavy',
//           'Separate documents from temporary storage.',
//           LucideIcons.archive,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'Open settings',
//           'Use platform-safe app management.',
//           LucideIcons.externalLink,
//           AppColors.sage,
//         ),
//       ],
//     ),
//     AppRoutes.photoCompressor: CleanerScreenConfig(
//       title: 'Compress without wrecking photos.',
//       kicker: '14 - COMPRESSOR',
//       subtitle:
//           'A smart compression tool previews quality tradeoffs and projected savings.',
//       icon: LucideIcons.minimize2,
//       route: AppRoutes.photoCompressor,
//       nextRoute: AppRoutes.batteryManager,
//       accent: AppColors.coral,
//       stats: const [
//         MetricTile('Original', '4.2 GB', AppColors.fg),
//         MetricTile('After', '1.8 GB', AppColors.accent),
//         MetricTile('Saved', '2.4 GB', AppColors.sage),
//         MetricTile('Quality', '92%', AppColors.amber),
//       ],
//       items: const [
//         FeatureRow(
//           'Quality preview',
//           'Compare before and after before applying.',
//           LucideIcons.eye,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'Batch rules',
//           'Compress screenshots harder than memories.',
//           LucideIcons.slidersHorizontal,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'Keep originals',
//           'Optional backup before replacing files.',
//           LucideIcons.copy,
//           AppColors.sage,
//         ),
//       ],
//     ),
//     AppRoutes.batteryManager: CleanerScreenConfig(
//       title: 'Battery health and optimizations.',
//       kicker: '15 - BATTERY',
//       subtitle:
//           'Shows useful tips and simple toggles without pretending to magically repair hardware.',
//       icon: LucideIcons.battery,
//       route: AppRoutes.batteryManager,
//       nextRoute: AppRoutes.subscription,
//       accent: AppColors.sage,
//       stats: const [
//         MetricTile('Health', '87%', AppColors.sage),
//         MetricTile('Capacity', '3274 mAh', AppColors.fg),
//         MetricTile('Cycles', '147', AppColors.accent),
//         MetricTile('Temp', '28C', AppColors.amber),
//       ],
//       items: const [
//         FeatureRow(
//           'Brightness',
//           'Reduce screen brightness at peak times.',
//           LucideIcons.sun,
//           AppColors.amber,
//         ),
//         FeatureRow(
//           'Background data',
//           'Limit non-essential refresh.',
//           LucideIcons.wifi,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'Location',
//           'Use while using where possible.',
//           LucideIcons.mapPin,
//           AppColors.coral,
//         ),
//       ],
//     ),
//     AppRoutes.subscription: CleanerScreenConfig(
//       title: 'No tricks, no traps.',
//       kicker: '16 - SUBSCRIPTION',
//       subtitle:
//           'A trust-first subscription screen with real manage, cancel, refund, and receipt areas.',
//       icon: LucideIcons.crown,
//       route: AppRoutes.subscription,
//       nextRoute: null,
//       accent: AppColors.accent,
//       primaryAction: 'Back to dashboard',
//       stats: const [
//         MetricTile('Plan', 'Pro', AppColors.accent),
//         MetricTile('Yearly', '\$34.99', AppColors.amber),
//         MetricTile('Renewal', 'Mar 2027', AppColors.fg),
//         MetricTile('Status', 'Active', AppColors.sage),
//       ],
//       items: const [
//         FeatureRow(
//           'Manage subscription',
//           'Opens platform subscriptions.',
//           LucideIcons.settings,
//           AppColors.accent,
//         ),
//         FeatureRow(
//           'Cancel subscription',
//           'One tap. No retention popup.',
//           LucideIcons.x,
//           AppColors.coral,
//         ),
//         FeatureRow(
//           'Request refund',
//           'In-app form with clear expectations.',
//           LucideIcons.undo2,
//           AppColors.sage,
//         ),
//       ],
//     ),
//   };
// }
