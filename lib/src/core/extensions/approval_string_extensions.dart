part of '../../../approval_tests.dart';

/// Extension on `String` to add a method for replacing occurrences based on a regular expression.
/// This extension method is used by `ScrubWithRegEx` to perform the scrubbing.
extension StringExtensions on String {
  /// Replaces occurrences of the matching pattern in the string with the provided replacement function.
  /// Uses a regular expression to find matches and applies the replacement function to each match.
  String replacingOccurrences({
    required String matchingPattern,
    required String Function(String) replacementProvider,
  }) {
    final regExp = RegExp(matchingPattern);
    return replaceAllMapped(
      regExp,
      (match) => replacementProvider(match.group(0)!),
    );
  }
}
