/*
   Copyright 2024 shodev.live

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       https://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

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
