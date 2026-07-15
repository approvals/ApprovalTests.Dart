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

/// Thrown when a value cannot be safely used as an approval filename segment.
final class InvalidApprovalNameException implements Exception {
  /// Name of the rejected naming component.
  final String component;

  /// Rejected component value.
  final String value;

  /// Actionable reason the value was rejected.
  final String reason;

  const InvalidApprovalNameException({
    required this.component,
    required this.value,
    required this.reason,
  });

  @override
  String toString() => 'Invalid approval $component: $reason';
}
