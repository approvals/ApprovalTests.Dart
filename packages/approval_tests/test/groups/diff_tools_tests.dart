import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../approval_test.dart';

void main() {
  final isWindows = Platform.isWindows;
  final isLinux = Platform.isLinux;
  const gitReporter = GitReporter();

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
        isLinux ? returnsNormally : throwsA(isA<ProcessException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled ${isLinux ? 'normal' : 'ProcessException'} for Android Studio DiffReporter on Linux.",
      );
    });

    test('verify reporter availability on Linux', () {
      const reporter = DiffReporter(
        ide: ComparatorIDE.studio,
        platformWrapper: LinuxPlatformWrapper(),
      );

      // Expect an exception to be thrown
      expect(
        reporter.isReporterAvailable,
        isLinux ? returnsNormally : false,
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled availability: ${isLinux ? 'normal' : 'false'} for Android Studio DiffReporter on Linux.",
      );
    });

    test('verify string with NoPlatformWrapper', () {
      const reporter = DiffReporter(
        ide: ComparatorIDE.studio,
        platformWrapper: NoPlatformWrapper(),
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
        throwsA(isA<NoDiffToolException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled NoDiffToolException.",
      );
    });

    test('verify string with Git reporter', () {
      // Setup: paths to existent files
      const existentApprovedPath =
          'test/approved_files/approval_test.verify.approved.txt';
      const existentReceivedPath =
          'test/approved_files/approval_test.verify.received.txt';

      // Expect an exception to be thrown
      expect(
        () => gitReporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        returnsNormally,
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled 'normal' for Git reporter.",
      );
    });

    test('Should throw PathNotFoundException when file does not exist', () {
      const String approvedPath = "/path/to/nonexisting/approved/file";
      const String receivedPath = "/path/to/nonexisting/received/file";

      expect(
        () async => gitReporter.report(approvedPath, receivedPath),
        throwsA(isA<PathNotFoundException>()),
      );
    });

    test(
        'gitDiffFiles should return an empty string if no differences for valid files',
        () {
      final File path0 = File('/path/to/existing/file0');
      final FileSystemEntity path1 = File('/path/to/existing/file1');

      final diffResult = GitReporter.gitDiffFiles(path0, path1);

      expect(diffResult, equals(''));
    });

    test('GitReporter with not correct custom diff info', () {
      const DiffInfo customDiffInfo =
          DiffInfo(name: "G1t", command: 'g1t', arg: 'diff --no-index');

      const gitReporter = GitReporter(customDiffInfo: customDiffInfo);

      const existentApprovedPath =
          'test/approved_files/approval_test.verify.approved.txt';
      const existentReceivedPath =
          'test/approved_files/approval_test.verify.received.txt';

      // Expect an exception to be thrown
      expect(
        () => gitReporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        throwsA(isA<ProcessException>()),
      );
    });
  });
}
