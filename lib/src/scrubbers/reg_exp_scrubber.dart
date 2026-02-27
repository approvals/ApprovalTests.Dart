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

/// A class named `ScrubWithRegEx` that implements the `Scrubber` interface.
/// `ScrubWithRegEx` is a scrubber that uses a regular expression to scrub strings.
class ScrubWithRegEx implements ApprovalScrubber {
  final String pattern;
  final String Function(String)? replacementFunction;

  static final Map<String, RegExp> _regExpCache = {};

  /// Creates a `ScrubWithRegEx` with an optional custom regular expression pattern.
  /// If no pattern is provided, a default pattern that matches whitespace is used.
  const ScrubWithRegEx({String? pattern})
      : pattern = pattern ?? defaultPattern,
        replacementFunction = null;

  /// Creates a `ScrubWithRegEx` with a custom regular expression pattern and replacement function.
  const ScrubWithRegEx.custom({
    required this.pattern,
    required this.replacementFunction,
  });

  @override
  String scrub(String input) {
    final regExp = _regExpCache.putIfAbsent(pattern, () => RegExp(pattern));
    final provider = replacementFunction ?? (String _) => ' ';
    return input
        .replaceAllMapped(regExp, (match) => provider(match.group(0)!))
        .trim();
  }

  static const defaultPattern = r'\s+';
}
