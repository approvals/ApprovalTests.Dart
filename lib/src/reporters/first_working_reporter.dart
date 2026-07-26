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

/// Reports through the first reporter that is available here.
///
/// Reporters are consulted in declaration order, so selection is deterministic.
/// A reporter that is available but then fails is **not** skipped: its error
/// propagates, because a fallback must never hide a real execution failure.
///
/// The usual recipe puts a local diff tool first and a terminal-safe reporter
/// last, so the same [Options] work locally and on headless CI:
///
/// ```dart
/// const Options(
///   reporter: FirstWorkingReporter([
///     DiffReporter(),
///     CommandLineReporter(),
///   ]),
/// );
/// ```
///
/// Throws [NoAvailableReporterException] when no configured reporter is
/// available, so a misconfigured chain is distinguishable from a successful
/// report. Contrast with [MultiReporter], which reports nothing in that case.
final class FirstWorkingReporter implements Reporter, ReporterAvailability {
  /// Candidate reporters in selection order.
  final List<Reporter> reporters;

  const FirstWorkingReporter(this.reporters);

  @override
  bool get isAvailable => reporters.any(ReporterAvailability.of);

  // `async` so a missing reporter surfaces as a failed Future rather than a
  // synchronous throw: callers such as Approvals attach `.catchError` to the
  // returned Future, and a synchronous throw would escape it and mask the
  // mismatch the reporter was invoked for.
  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    for (final reporter in reporters) {
      if (ReporterAvailability.of(reporter)) {
        return reporter.report(approvedPath, receivedPath);
      }
    }
    throw NoAvailableReporterException(reporters: reporters);
  }
}
