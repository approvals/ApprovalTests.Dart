part of '../approval_test.dart';

void diffToolsTests({
  required String lines25,
}) {
  group('Approvals: test for Diff Tools', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Diff Tool tests are starting $lines25",
      );
    });

    test('verify string with Android Studio DiffReporter on Windows', () {
      const reporter = DiffReporter(
        ide: ComparatorIDE.studio,
        platformWrapper: WindowsPlatformWrapper(),
      );

      // Setup: paths to existent files
      const existentApprovedPath =
          'test/approved_files/approval_test.verify.approved.txt';
      const existentReceivedPath =
          'test/approved_files/approval_test.verify.received.txt';

      // Expect an exception to be thrown
      expect(
        () => reporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        throwsA(isA<ProcessException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled ProcessException for Android Studio DiffReporter on Windows.",
      );
    });

    test('verify string with Android Studio DiffReporter on Linux', () {
      const reporter = DiffReporter(
        ide: ComparatorIDE.studio,
        platformWrapper: LinuxPlatformWrapper(),
      );

      // Setup: paths to existent files
      const existentApprovedPath =
          'test/approved_files/approval_test.verify.approved.txt';
      const existentReceivedPath =
          'test/approved_files/approval_test.verify.received.txt';

      // Expect an exception to be thrown
      expect(
        () => reporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        throwsA(isA<ProcessException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled ProcessException for Android Studio DiffReporter on Linux.",
      );
    });
  });
}
