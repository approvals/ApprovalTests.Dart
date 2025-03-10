import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../approval_test.dart';

void main() {
  final dateTime = DateTime(2021, 10, 10, 10, 10, 10);

  group('Approvals: test of other minor things |', () {
    setUpAll(() {
      ApprovalLogger.log("$lines25 Group: Minor tests are starting $lines25");
    });

    test('Simulate file not found error during comparison', () async {
      const comparator = FileComparator();

      // Setup: paths to non-existent files
      const nonExistentApprovedPath = 'path/to/nonexistent/approved.txt';
      const nonExistentReceivedPath = 'path/to/nonexistent/received.txt';

      // Expect an exception to be thrown
      expect(
        () => comparator.compare(
          approvedPath: nonExistentApprovedPath,
          receivedPath: nonExistentReceivedPath,
        ),
        throwsA(isA<PathNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a file not found error during comparison with FileComparator. Method «compare» correctly throws PathNotFoundException as expected.",
      );
    });

    test('Simulate file not found error during reporting.', () async {
      const reporter = DiffReporter();

      // Setup: paths to non-existent files
      const nonExistentApprovedPath = 'path/to/nonexistent/approved.txt';
      const nonExistentReceivedPath = 'path/to/nonexistent/received.txt';

      // Expect an exception to be thrown
      expect(
        () => reporter.report(
          nonExistentApprovedPath,
          nonExistentReceivedPath,
        ),
        throwsA(isA<PathNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a file not found error during reporting. Method «report» correctly throws PathNotFoundException as expected.",
      );
    });

    test('verify string using VS Code DiffReporter', () {
      expect(
        () => helper.verify(
          'Hello W0rld',
          'verify',
          deleteReceivedFile: false,
          reporter: const DiffReporter(
            ide: ComparatorIDE.studio, //  ComparatorIDE.vsCode
          ),
        ),
        throwsA(isA<DoesntMatchException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a log mismatch. Method «verify» correctly throws DoesntMatchException as expected.",
      );
    });

    test('verify string using Android Studio DiffReporter', () {
      expect(
        () => helper.verify(
          'Hello W0rld',
          'verify',
          deleteReceivedFile: false,
          reporter: const DiffReporter(
            ide: ComparatorIDE.studio,
          ),
        ),
        throwsA(isA<DoesntMatchException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a log mismatch. Method «verify» correctly throws DoesntMatchException as expected.",
      );
    });

    test('Verify string with not correct DiffInfo.', () async {
      const reporter = DiffReporter(
        customDiffInfo: DiffInfo(
          command: '/usr/bin/code',
          arg: '-d',
          name: 'code',
        ),
      );

      const existentApprovedPath =
          'test/approved_files/approval_test.verify.approved.txt';
      const existentReceivedPath =
          'test/approved_files/approval_test.verify.received.txt';

      expect(
        () => reporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        throwsA(isA<ProcessException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled ProcessException for not correct DiffInfo.",
      );
    });

    test('Verify string with scrubber', () {
      helper.verify(
        '  Hello    World  \t\n ',
        'verify_scrub',
        scrubber: const ScrubWithRegEx(),
      );
    });

    test('Verify string with custom scrubber', () {
      helper.verify(
        '  Hello    World  \t\n ',
        'verify_custom_scrub',
        scrubber: ScrubWithRegEx.custom(
          pattern: r'\s+',
          replacementFunction: (match) => '-',
        ),
      );
    });

    test('Verify string with date scrubber', () {
      helper.verifyAll(
        [dateTime, DateTime.now()],
        'verify_date_scrub',
        scrubber: const ScrubDates(),
        deleteReceivedFile: false,
      );
    });

    test('Returns correct file path', () {
      final fakeStackTraceFetcher = FakeStackTraceFetcher(
        helper.fakeStackTracePath,
      );

      final filePathExtractor =
          FilePathExtractor(stackTraceFetcher: fakeStackTraceFetcher);
      final filePath = filePathExtractor.filePath;

      expect(filePath, helper.testPath);
      ApprovalLogger.success(
        "Test Passed: Successfully extracted the file path from the stack trace.",
      );
    });

    test('Throws FileNotFoundException when no file path in stack trace', () {
      const fakeStackTraceFetcher = FakeStackTraceFetcher(
        'no file path in this stack trace\nother stack trace lines...',
      );

      const filePathExtractor =
          FilePathExtractor(stackTraceFetcher: fakeStackTraceFetcher);

      expect(
        () => filePathExtractor.filePath,
        throwsA(isA<FileNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a file not found error during comparison.",
      );
    });

    test('Verify model without class name', () {
      helper.verifyAsJson(
        ApprovalTestHelper.jsonItem,
        'verify_without_class_name',
        includeClassNameDuringSerialization: false,
      );
    });

    test('Should return correct directory path on linux/macOS/Windows', () {
      final fakeStackTraceFetcher = FakeStackTraceFetcher(
        helper.fakeStackTracePath,
      );

      final filePathExtractor =
          FilePathExtractor(stackTraceFetcher: fakeStackTraceFetcher);
      final directoryPath = filePathExtractor.directoryPath;

      expect(directoryPath, helper.testDirectoryPath);
      ApprovalLogger.success(
        "Test Passed: Successfully extracted the directory path from the stack trace.",
      );
    });

    test('Should throw FileNotFoundException when no match found', () {
      const fakeStackTraceFetcher = FakeStackTraceFetcher(
        'no file path in this stack trace\nother stack trace lines...',
      );

      const filePathExtractor =
          FilePathExtractor(stackTraceFetcher: fakeStackTraceFetcher);

      expect(
        () => filePathExtractor.directoryPath,
        throwsA(isA<FileNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a file not found error during getting directory path.",
      );
    });

    test('Verify with description: with FileNamer', () {
      helper.verify(
        'Hello World',
        'description_with_filenamer',
        description: 'test description',
      );
    });

    test('description with Namer', () {
      Approvals.verify(
        'Hello World',
        options: const Options(
          namer: Namer(
            description: 'test description',
          ),
        ),
      );
    });

    test('Should create a new options object', () {
      final options1 = Options();
      final options2 = options1.copyWith();

      expect(options1, isNot(same(options2)));
    });
  });
}
