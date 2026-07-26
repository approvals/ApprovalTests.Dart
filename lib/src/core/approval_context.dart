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

/// Explicit identity of the code under verification.
///
/// Without a context, approval naming infers the source file by parsing
/// `StackTrace.current` and the test name from `package:test`'s internals.
/// Both work under `dart test` but cannot be supplied by a custom runner, a
/// generated harness, or a transformed stack trace. Passing a context makes
/// naming explicit instead:
///
/// ```dart
/// Approvals.verify(
///   report,
///   options: Options(
///     namer: Namer(
///       context: ApprovalContext(
///         sourcePath: 'test/billing/invoice_test.dart',
///         testName: 'renders a paid invoice',
///       ),
///     ),
///   ),
/// );
/// ```
///
/// The context belongs to the namer rather than to [Options] because
/// [IndexedNamer] allocates its counter while it is being constructed, before
/// [Options] reaches [Approvals]. A context supplied later would name files
/// after one test while numbering them after another.
///
/// Inference stays the 1.x fallback: omit a field, or the whole context, and
/// the previous behavior applies unchanged.
final class ApprovalContext {
  /// Path of the source file that owns the approval.
  ///
  /// Artifacts are named after this file and written next to it. A `.dart`
  /// extension is stripped, matching the inferred path.
  final String sourcePath;

  /// Test name included in generated artifact names.
  ///
  /// When null, the ambient test name is used. Supplying a name that differs
  /// from the ambient one is a supported override, not an error.
  final String? testName;

  const ApprovalContext({
    required this.sourcePath,
    this.testName,
  }) : assert(
          sourcePath != '',
          'ApprovalContext.sourcePath must not be empty',
        );

  @override
  String toString() =>
      'ApprovalContext(sourcePath: $sourcePath, testName: $testName)';
}

/// Contract for namers that carry an explicit [ApprovalContext].
///
/// This is a separate capability rather than a member on [ApprovalNamer]
/// because adding one there would break every existing
/// `implements ApprovalNamer`. [Approvals] narrows to this interface and falls
/// back to inference for namers that do not implement it.
abstract interface class ContextAwareNamer implements ApprovalNamer {
  /// Explicit verification context, or null when naming is inferred.
  ApprovalContext? get context;
}
