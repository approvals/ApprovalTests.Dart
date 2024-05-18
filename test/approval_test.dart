// Import third-party packages
import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

// Import project-specific dependencies
import 'models/item.dart';
import 'queries/db_request_query.dart';

part 'utils/helper.dart';
part 'constants/lines.dart';

void main() {
  /// ================== Init fields ==================

  const helper = ApprovalTestHelper();
  const dbQuery = DatabaseRequestQuery("1");
  const lines25 = _Lines.lines25;
  const lines30 = _Lines.lines30;
  final dateTime = DateTime(2021, 10, 10, 10, 10, 10);

  /// ================== Set up ==================

  setUpAll(() {
    ApprovalLogger.warning("$lines30 Tests are starting $lines30");
  });

  /// ================== Approvals: verify methods ==================

  group('Approvals: verify methods |', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Test verify methods are starting $lines25",
      );
    });
    test('verify string with approved result options', () {
      helper.verify(
        'Hello World',
        'verify',
      );
    });

    test('Verify all strings in a list', () {
      helper.verifyAll(['Hello World', 'Hello World'], 'verify_all');
    });

    test('Verify JSON data', () {
      helper.verifyAsJson({"message": "Hello World"}, 'verify_as_json');
    });

    test('Verify JSON data: with model', () {
      helper.verifyAsJson(ApprovalTestHelper.jsonItem, 'verify_as_model_json');
    });

    test('Verify all combinations', () {
      helper.verifyAllCombinations(
        [
          [1, 2],
          [3, 4],
        ],
        'verify_all_combinations',
      );
    });

    test("Verify sequence", () {
      helper.verifySequence([1, 2, 3], 'verify_sequence');
    });

    test("Verify query result", () async {
      await helper.verifyQuery(dbQuery, 'verify_query');
    });
  });

  /// ================== Approvals: test for exceptions ==================
  group('Approvals: test for exceptions |', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Exception cases are starting $lines25",
      );
    });

    test("Method «verify» must throw DoesntMatchException", () {
      expect(
        () => helper.verify(
          'Hello W0rld',
          'verify',
          expectException: true,
        ),
        throwsA(isA<DoesntMatchException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Method «verify» correctly throws DoesntMatchException as expected.",
      );
    });

    test("Method «verify» must throw DoesntMatchException with error handling", () {
      expect(
        () => helper.verify(
          'Hello W0rld',
          'verify',
        ),
        throwsA(isA<DoesntMatchException>()),
      );
      ApprovalLogger.success(
        "Test Passed: Successfully handled a log mismatch. Method «verify» correctly throws DoesntMatchException as expected.",
      );
    });
  });

  /// ================== Approvals: test for exceptions ==================

  group('Approvals: test of other minor things |', () {
    setUpAll(() {
      ApprovalLogger.log("$lines25 Group: Minor cases are starting $lines25");
    });

    test('Simulate file not found error during comparison. Must throw CommandLineComparatorException.', () async {
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

    test('verify string with DiffReporter', () {
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

    // if (Platform.isLinux) {
    test('Verify string with DiffReporter. Must throw IDEComparatorException.', () async {
      const reporter = DiffReporter(
        customDiffInfo: LinuxDiffTools.visualStudioCode,
      );

      // Setup: paths to non-existent files
      const nonExistentApprovedPath = 'test/approved_files/approval_test.verify.approved.txt';
      const nonExistentReceivedPath = 'test/approved_files/approval_test.verify.received.txt';

      // Expect an exception to be thrown
      expect(
        () => reporter.report(
          nonExistentApprovedPath,
          nonExistentReceivedPath,
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
  });

  /// ================== Tear down ==================

  tearDownAll(() {
    ApprovalLogger.warning("$lines30 All tests are done $lines30");
  });
}
