part of '../approval_test.dart';

void minorTests({
  required final ApprovalTestHelper helper,
  required final DateTime dateTime,
  required final String lines25,
}) {
  group('Approvals: test of other minor things |', () {
    setUpAll(() {
      ApprovalLogger.log("$lines25 Group: Minor tests are starting $lines25");
    });

    test('Simulate file not found error during comparison. Must throw PathNotFoundException.', () async {
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
        "Test Passed: Successfully handled a file not found error during comparison.",
      );
    });

    test('Simulate file not found error during comparison. Must throw IDEComparatorException.', () async {
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
        "Test Passed: Successfully handled a file not found error during comparison.",
      );
    });

    test('verify string with VS Code DiffReporter', () {
      expect(
        () => helper.verify(
          'Hello W0rld',
          'verify',
          deleteReceivedFile: false,
          reporter: const DiffReporter(),
        ),
        throwsA(isA<DoesntMatchException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a log mismatch. Method «verify» correctly throws DoesntMatchException as expected.",
      );
    });

    test('verify string with Android Studio DiffReporter', () {
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

    // if (Platform.isLinux) {
    test('Verify string with DiffReporter. Must throw IDEComparatorException.', () async {
      const reporter = DiffReporter(
        customDiffInfo: LinuxDiffTools.visualStudioCode,
      );

      // Setup: paths to non-existent files
      const existentApprovedPath = 'test/approved_files/approval_test.verify.approved.txt';
      const existentReceivedPath = 'test/approved_files/approval_test.verify.received.txt';

      // Expect an exception to be thrown
      expect(
        () => reporter.report(
          existentApprovedPath,
          existentReceivedPath,
        ),
        throwsA(isA<ProcessException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a file not found error during comparison.",
      );
    });
    // }

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

    test('returns correct file path', () {
      const fakeStackTraceFetcher = FakeStackTraceFetcher(
        'file:///path/to/file.dart:10:11\nother stack trace lines...',
      );

      const filePathExtractor = FilePathExtractor(stackTraceFetcher: fakeStackTraceFetcher);
      final filePath = filePathExtractor.filePath;

      expect(filePath, helper.testPath);
      ApprovalLogger.success(
        "Test Passed: Successfully extracted the file path from the stack trace.",
      );
    });

    test('throws FileNotFoundException when no file path in stack trace', () {
      const fakeStackTraceFetcher = FakeStackTraceFetcher(
        'no file path in this stack trace\nother stack trace lines...',
      );

      const filePathExtractor = FilePathExtractor(stackTraceFetcher: fakeStackTraceFetcher);

      expect(
        () => filePathExtractor.filePath,
        throwsA(isA<FileNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Successfully handled a file not found error during comparison.",
      );
    });

    test('verify without namer', () {
      Approvals.verify(
        'Hello World',
        options: const Options(
          deleteReceivedFile: true,
        ),
      );
    });
  });
}
