import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../approval_test.dart';

void main() => registerMinorTests();

void registerMinorTests() {
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

    test('FileComparator detects leading whitespace differences', () {
      final tempDir =
          Directory.systemTemp.createTempSync('approval_whitespace_test');
      try {
        final approvedFile = File('${tempDir.path}/sample.approved.txt')
          ..writeAsStringSync('Hello');
        final receivedFile = File('${tempDir.path}/sample.received.txt')
          ..writeAsStringSync(' Hello');

        const comparator = FileComparator();
        final isMatch = comparator.compare(
          approvedPath: approvedFile.path,
          receivedPath: receivedFile.path,
          isLogError: false,
        );

        expect(isMatch, isFalse);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Simulate file not found error during reporting.', () async {
      const reporter = DiffReporter();

      // Setup: paths to non-existent files
      const nonExistentApprovedPath = 'path/to/nonexistent/approved.txt';
      const nonExistentReceivedPath = 'path/to/nonexistent/received.txt';

      // Expect an exception to be thrown
      await expectLater(
        reporter.report(
          nonExistentApprovedPath,
          nonExistentReceivedPath,
        ),
        throwsA(isA<PathNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a file not found error during reporting. Method «report» correctly throws PathNotFoundException as expected.",
      );
    });

    test('verify string using VS Code DiffReporter', () async {
      await expectLater(
        helper.verify(
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

    test('verify string using Android Studio DiffReporter', () async {
      await expectLater(
        helper.verify(
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

      await expectLater(
        reporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        throwsA(isA<ProcessException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled ProcessException for not correct DiffInfo.",
      );
    });

    test('Verify string with scrubber', () async {
      await helper.verify(
        '  Hello    World  \t\n ',
        'verify_scrub',
        scrubber: const ScrubWithRegEx(),
      );
    });

    test('Verify string with custom scrubber', () async {
      await helper.verify(
        '  Hello    World  \t\n ',
        'verify_custom_scrub',
        scrubber: ScrubWithRegEx.custom(
          pattern: r'\s+',
          replacementFunction: (match) => '-',
        ),
      );
    });

    test('Verify string with date scrubber', () async {
      await helper.verifyAll(
        [dateTime, DateTime.now()],
        'verify_date_scrub',
        scrubber: const ScrubDates(),
        deleteReceivedFile: false,
      );
    });

    test('ScrubDates index resets for each call', () {
      const scrubber = ScrubDates();
      final resultOne = scrubber.scrub(
        '2024-10-01 10:10:10.123 + 2024-10-01 10:10:11.456',
      );
      final resultTwo = scrubber.scrub(
        '2025-11-02 11:11:11.789 + 2025-11-02 11:11:12.890',
      );

      expect(resultOne, contains('<date1>'));
      expect(resultOne, contains('<date2>'));
      expect(resultTwo, contains('<date1>'));
      expect(resultTwo, contains('<date2>'));
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

    test('Verify model without class name', () async {
      await helper.verifyAsJson(
        ApprovalTestHelper.jsonItem,
        'verify_without_class_name',
        includeClassNameDuringSerialization: false,
      );
    });

    test('Approvals.verify deletes received file when logResults is disabled',
        () async {
      final tempDir =
          Directory.systemTemp.createTempSync('approval_cleanup_test');
      final fileBase = '${tempDir.path}/cleanup_test.dart';
      try {
        final options = Options(
          namer: Namer(
            filePath: fileBase,
            addTestName: false,
          ),
          approveResult: true,
          deleteReceivedFile: true,
          logResults: false,
          logErrors: false,
        );

        Approvals.verify('value', options: options);

        final receivedFile = File(
          fileBase.replaceAll('.dart', '.received.txt'),
        );
        final approvedFile = File(
          fileBase.replaceAll('.dart', '.approved.txt'),
        );

        expect(receivedFile.existsSync(), isFalse);
        expect(approvedFile.existsSync(), isTrue);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
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

    test('Verify with description: with FileNamer', () async {
      await helper.verify(
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
