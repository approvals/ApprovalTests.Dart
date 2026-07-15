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

/// Replaces repeated regular-expression matches with stable indexed aliases.
final class ScrubWithAliases implements ApprovalScrubber {
  /// Regular-expression pattern whose complete matches are aliased.
  final String pattern;

  /// Label used in generated aliases such as `<value1>`.
  final String alias;

  /// Whether matching and alias identity distinguish letter case.
  final bool caseSensitive;

  /// Creates an alias-preserving regular-expression scrubber.
  ///
  /// Throws:
  /// - [FormatException] from [RegExp] when [pattern] is malformed.
  const ScrubWithAliases({
    required this.pattern,
    this.alias = 'value',
    this.caseSensitive = true,
  });

  @override
  String scrub(String input) {
    final aliases = <String, String>{};
    final expression = RegExp(pattern, caseSensitive: caseSensitive);
    return input.replaceAllMapped(expression, (match) {
      final value = match.group(0)!;
      final key = caseSensitive ? value : value.toLowerCase();
      return aliases.putIfAbsent(
        key,
        () => '<$alias${aliases.length + 1}>',
      );
    });
  }
}
