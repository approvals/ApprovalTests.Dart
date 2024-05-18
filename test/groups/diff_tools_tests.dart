import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../approval_test.dart';

void main() {
  final isWindows = Platform.isWindows;
  final isLinux = Platform.isLinux;

  group('Approvals: test for Diff Tools', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Diff Tool tests are starting $lines25",
      );
    });

    test('Verify string with Android Studio DiffReporter on Windows', () {
      const reporter = DiffReporter(
        ide: ComparatorIDE.studio,
        platformWrapper: WindowsPlatformWrapper(),
      );

      // Setup: paths to existent files
      const existentApprovedPath = 'test/approved_files/approval_test.verify.approved.txt';
      const existentReceivedPath = 'test/approved_files/approval_test.verify.received.txt';

      // Expect an exception to be thrown
      expect(
        () => reporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        isWindows ? returnsNormally : throwsA(isA<ProcessException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled ${isWindows ? 'normal' : 'ProcessException'} for Android Studio DiffReporter on Windows.",
      );
    });

    test('verify string with Android Studio DiffReporter on Linux', () {
      const reporter = DiffReporter(
        ide: ComparatorIDE.studio,
        platformWrapper: LinuxPlatformWrapper(),
      );

      // Setup: paths to existent files
      const existentApprovedPath = 'test/approved_files/approval_test.verify.approved.txt';
      const existentReceivedPath = 'test/approved_files/approval_test.verify.received.txt';

      // Expect an exception to be thrown
      expect(
        () => reporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        isLinux ? returnsNormally : throwsA(isA<ProcessException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled ${isLinux ? 'normal' : 'ProcessException'} for Android Studio DiffReporter on Linux.",
      );
    });

    test('verify string with NoPlatformWrapper', () {
      const reporter = DiffReporter(
        ide: ComparatorIDE.studio,
        platformWrapper: NoPlatformWrapper(),
      );

      // Setup: paths to existent files
      const existentApprovedPath = 'test/approved_files/approval_test.verify.approved.txt';
      const existentReceivedPath = 'test/approved_files/approval_test.verify.received.txt';

      // Expect an exception to be thrown
      expect(
        () => reporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        throwsA(isA<NoDiffToolException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled NoDiffToolException.",
      );
    });
  });
}
