// Import Dart core libraries
import 'dart:io';

// Import third-party packages
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
    test('Verify string with approved result options', () {
      helper.verify('Hello World', 'verify', approveResult: true);
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

    // Not work
    test("Verify query result", () async {
      await helper.verifyQuery(dbQuery, 'verify_query');
    });

    // Work
    test("verify query", () async {
      await Approvals.verifyQuery(
        dbQuery,
        options: const Options(
          deleteReceivedFile: true,
          filesPath: 'test/approved_files/verify_query',
        ),
      );
    });
  });

  /// ================== Approvals: test for exceptions ==================
  group('Approvals: test for exceptions |', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Exception cases are starting $lines25",
      );
    });
    test('Method «verify» must throw PathNotFoundException', () {
      expect(
        () => helper.verify(
          'Hello World',
          'verify_exception',
          expectException: true,
        ),
        throwsA(isA<PathNotFoundException>()),
      );
      ApprovalLogger.success(
        "Test Passed: Method «verify» correctly throws PathNotFoundException as expected.",
      );
    });

    test('Method «verifyAll» must throw PathNotFoundException', () {
      expect(
        () => helper.verifyAll(
          ['Hello World', 'Hello World'],
          'verify_exception',
          expectException: true,
        ),
        throwsA(isA<PathNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Method «verifyAll» correctly throws PathNotFoundException as expected.",
      );
    });

    test('Method «verifyAsJson» must throw PathNotFoundException', () {
      expect(
        () => helper.verifyAsJson(
          {"message": "Hello World"},
          'verify_as_json_exception',
          expectException: true,
        ),
        throwsA(isA<PathNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Method «verifyAsJson» correctly throws PathNotFoundException as expected.",
      );
    });

    test('Method «verifyAllCombinations» must throw PathNotFoundException', () {
      expect(
        () => helper.verifyAllCombinations(
          [
            [1, 2],
            [3, 4],
          ],
          'verify_all_combinations_exception',
          expectException: true,
        ),
        throwsA(isA<PathNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Method «verifyAllCombinations» correctly throws PathNotFoundException as expected.",
      );
    });

    test("Method «verifySequence» must throw PathNotFoundException", () {
      expect(
        () => helper.verifySequence(
          [1, 2, 3],
          'verify_sequence_exception',
          expectException: true,
        ),
        throwsA(isA<PathNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Method «verifySequence» correctly throws PathNotFoundException as expected.",
      );
    });

    test("Method «verifyQuery» must throw PathNotFoundException", () async {
      expect(
        () => helper.verifyQuery(
          dbQuery,
          'verify_query_exception',
          expectException: true,
        ),
        throwsA(isA<PathNotFoundException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Method «verifyQuery» correctly throws PathNotFoundException as expected.",
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

    test("Method «verify» must throw DoesntMatchException with error handling",
        () {
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
    test('Verify method without initial path: PathNotFoundException', () {
      expect(
        () => helper.verify(
          'Hello World',
          'verify_exception',
          expectException: true,
          useDefaultPath: false,
        ),
        throwsA(isA<PathNotFoundException>()),
      );
      ApprovalLogger.success(
        "Test Passed: The method was successfully verified for absence of an initial path — PathNotFoundException was thrown.",
      );
    });
  });

  /// ================== Tear down ==================

  tearDownAll(() {
    ApprovalLogger.warning("$lines30 All tests are done $lines30");
  });
}
