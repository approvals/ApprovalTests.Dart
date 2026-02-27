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

/// A scrubber that replaces date strings with indexed placeholders.
/// Uses a regular expression to match date strings in `yyyy-MM-dd HH:mm:ss.SSS` format.
class ScrubDates implements ApprovalScrubber {
  /// Constant pattern to match date strings
  static const String _datePattern =
      r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+';

  /// Creates a `ScrubDates` instance with a predefined pattern to match date strings.
  /// Replaces matched date strings with a fixed placeholder `<date>`.
  const ScrubDates();

  @override
  String scrub(String input) {
    var index = 0;
    return input
        .replacingOccurrences(
          matchingPattern: _datePattern,
          replacementProvider: (_) {
            index++;
            return '<date$index>';
          },
        )
        .trim();
  }
}
