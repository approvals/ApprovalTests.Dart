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
