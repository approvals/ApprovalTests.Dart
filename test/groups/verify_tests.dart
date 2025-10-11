import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../approval_test.dart';

void main() => registerVerifyTests();

void registerVerifyTests() {
  group('Approvals: verify methods |', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Main verify tests methods are starting $lines25",
      );
    });

    test('String with approved result options', () {
      helper.verify(
        'Hello World',
        'verify',
        approveResult: true,
      );
    });

    test('All strings in a list', () {
      helper.verifyAll(['Hello World', 'Hello World'], 'verify_all');
    });

    test('JSON data', () {
      helper.verifyAsJson({"message": "Hello World"}, 'verify_as_json');
    });

    test('JSON data: with model', () {
      helper.verifyAsJson(
        ApprovalTestHelper.jsonItem,
        'verify_as_model_json',
      );
    });

    test('All combinations', () {
      helper.verifyAllCombinations(
        [
          [1, 2],
          [3, 4],
        ],
        'verify_all_combinations',
      );
    });

    test("Sequence", () {
      helper.verifySequence([1, 2, 3], 'verify_sequence');
    });

    test("Query result", () async {
      await helper.verifyQuery(dbQuery, 'verify_query');
    });
  });
}
