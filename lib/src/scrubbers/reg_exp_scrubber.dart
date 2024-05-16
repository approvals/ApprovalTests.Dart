part of '../../approval_tests.dart';

/// A class named `ScrubWithRegEx` that implements the `Scrubber` interface.
/// `ScrubWithRegEx` is a scrubber that uses a regular expression to scrub strings.
class ScrubWithRegEx implements ApprovalScrubber {
  final String pattern;
  final String Function(String)? replacementFunction;

  /// Creates a `ScrubWithRegEx` with an optional custom regular expression pattern.
  /// If no pattern is provided, a default pattern that matches whitespace is used.
  const ScrubWithRegEx({String? pattern})
      : pattern = pattern ?? defaultPattern,
        replacementFunction = null;

  /// Creates a `ScrubWithRegEx` with a custom regular expression pattern and replacement function.
  const ScrubWithRegEx.custom({required this.pattern, required this.replacementFunction});

  @override
  String scrub(String input) => input
      .replacingOccurrences(
        matchingPattern: pattern,
        replacementProvider: replacementFunction ?? (match) => ' ',
      )
      .trim();

  static const defaultPattern = r'\s+';
}
