/// Shared, pure presentation formatters used across feature views.
///
/// These were previously copy-pasted into each `*_view.dart` file (notably a
/// byte formatter duplicated in five places). Centralising them removes that
/// duplication and keeps formatting logic out of the widget tree.
library;

const List<String> _months = [
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

/// Human-readable byte size, e.g. `1.4 GB`, `820 KB`, `0 B`.
///
/// Behaviour matches the formatter that was duplicated across the feature
/// views: values < 10 (above the base unit) keep one decimal, everything else
/// is rounded. Pass [emptyLabel] to override the text shown for null/zero
/// sizes (the similar-photos grid used `"Size unavailable"`).
String formatBytes(int? bytes, {String? emptyLabel}) {
  if (bytes == null || bytes <= 0) {
    return emptyLabel ?? '0 B';
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

/// `Mar 5, 2024`. When [recentBefore2000] is true, pre-2000 dates (a common
/// "missing metadata" sentinel) render as `Recent`.
String formatShortDate(DateTime date, {bool recentBefore2000 = false}) {
  if (recentBefore2000 && date.year < 2000) {
    return 'Recent';
  }
  return '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

/// `1:23:45` for video durations, or `4:05` when under an hour.
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '${duration.inMinutes}:$seconds';
}

/// Abbreviated month name (`Jan`..`Dec`); clamps out-of-range input.
String monthName(int month) => _months[(month - 1).clamp(0, 11)];

/// `MAR 2024`, or `RECENT` for pre-2000 dates.
String monthYearLabel(DateTime date) {
  if (date.year < 2000) {
    return 'RECENT';
  }
  return '${monthName(date.month).toUpperCase()} ${date.year}';
}

/// `Mar 5 - 3:07 PM`, or `Recent` for pre-2000 dates.
String shortDateTimeLabel(DateTime date) {
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
  return '${monthName(date.month)} ${date.day} - $hour:$minute $period';
}

/// Groups digits with commas: `1234567` -> `1,234,567`.
String formatThousands(int value) {
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

/// Relative "last used" label, e.g. `Today`, `3 days ago`, `2 months ago`.
/// [now] is injectable for testing; defaults to [DateTime.now].
String formatLastUsed(DateTime? value, {DateTime? now}) {
  if (value == null) {
    return 'Last used unknown';
  }

  final reference = now ?? DateTime.now();
  final difference = reference.difference(value);
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
