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

/// Reports through every configured reporter that is available here.
///
/// Reporters run one after another in declaration order rather than
/// concurrently, so console output from two reporters cannot interleave.
///
/// Unavailable reporters are skipped. Reporting through none of them — an
/// empty list, or every reporter unavailable — completes normally, because
/// notifying nobody is a vacuous success. Contrast with [FirstWorkingReporter],
/// which throws in that case since its job is to select exactly one.
///
/// Every reporter runs even when an earlier one fails. The first failure is
/// rethrown with its original stack trace once the remaining reporters have
/// run; later failures go to [exceptionLogger], so they stay observable
/// without masking the first.
final class MultiReporter implements Reporter, ReporterAvailability {
  /// Reporters to notify, in invocation order.
  final List<Reporter> reporters;

  final void Function(Object exception, {StackTrace? stackTrace})
      exceptionLogger;

  const MultiReporter(
    this.reporters, {
    this.exceptionLogger = ApprovalLogger.exception,
  });

  @override
  bool get isAvailable => reporters.any(ReporterAvailability.of);

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    Object? firstError;
    StackTrace? firstStackTrace;

    for (final reporter in reporters) {
      if (!ReporterAvailability.of(reporter)) {
        continue;
      }
      try {
        await reporter.report(approvedPath, receivedPath);
      } catch (e, st) {
        if (firstError == null) {
          firstError = e;
          firstStackTrace = st;
        } else {
          exceptionLogger(e, stackTrace: st);
        }
      }
    }

    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStackTrace!);
    }
  }
}
