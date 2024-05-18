part of '../../approval_tests.dart';

/// A class named `ScrubDates` that extends `ScrubWithRegEx`.
/// `ScrubDates` uses a regular expression to scrub date strings in a specific format.
class ScrubDates extends ScrubWithRegEx {
  /// Constant pattern to match date strings
  static const String _datePattern =
      r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+';

  /// Creates a `ScrubDates` instance with a predefined pattern to match date strings.
  /// Replaces matched date strings with a fixed placeholder `<date>`.
  const ScrubDates();

  static int _index = 0;

  @override
  String scrub(String input) => input
      .replacingOccurrences(
        matchingPattern: _datePattern,
        replacementProvider: (match) {
          _index++;
          return '<date$_index>';
        },
      )
      .trim();
}
