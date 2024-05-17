part of '../../approval_tests.dart';

/// A class named `ScrubDates` that extends `ScrubWithRegEx`.
/// `ScrubDates` uses a regular expression to scrub date strings in a specific format.
class ScrubDates extends ScrubWithRegEx {
  static int _index = 0;

  /// Creates a `ScrubDates` instance with a predefined pattern to match date strings.
  /// Replaces matched date strings with a placeholder containing a unique index.
  ScrubDates()
      : super.custom(
          pattern: r'\d{4}-\d{1,2}-\d{1,2}T\d{1,2}:\d{2}:\d{2}Z',
          replacementFunction: (match) {
            _index++;
            return '<date$_index>';
          },
        );
}
