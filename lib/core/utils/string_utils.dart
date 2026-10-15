abstract class StringUtils {
  /// Truncates string to [maxLength], appending [ellipsis] if truncated.
  /// If [maxLength] is less than or equal to [ellipsis.length], it truncates directly without ellipsis.
  static String truncate(
    String text,
    int maxLength, {
    String ellipsis = '...',
  }) {
    if (maxLength <= 0) return '';
    if (text.length <= maxLength) return text;
    if (maxLength <= ellipsis.length) {
      return text.substring(0, maxLength);
    }
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Capitalizes the first character of [text].
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    if (text.length == 1) return text.toUpperCase();
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Generates 1-2 character uppercase initials from a name (e.g., "John Doe" -> "JD").
  static String initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words.first[0].toUpperCase()}${words.last[0].toUpperCase()}';
  }

  /// Formats singular or plural string according to [count].
  /// By default includes [count] in the output (e.g. "3 tasks", "1 task").
  /// If [showCount] is false, only returns the noun ("tasks", "task").
  static String pluralize(
    int count,
    String singular, {
    String? plural,
    bool showCount = true,
  }) {
    final word = (count.abs() == 1) ? singular : (plural ?? '${singular}s');
    return showCount ? '$count $word' : word;
  }
}
