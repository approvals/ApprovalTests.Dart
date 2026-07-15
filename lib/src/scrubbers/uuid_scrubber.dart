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

/// Replaces canonical UUIDs with stable aliases such as `<uuid1>`.
final class ScrubUuids implements ApprovalScrubber {
  /// Creates a case-insensitive UUID scrubber.
  const ScrubUuids();

  static const ScrubWithAliases _delegate = ScrubWithAliases(
    pattern:
        r'\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b',
    alias: 'uuid',
    caseSensitive: false,
  );

  @override
  String scrub(String input) => _delegate.scrub(input);
}
