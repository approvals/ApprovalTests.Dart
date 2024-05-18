part of '../approval_test.dart';

void verifyTests({
  required ApprovalTestHelper helper,
  required String lines25,
  required ExecutableQuery dbQuery,
}) {
  group('Approvals: verify methods |', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Main verify tests methods are starting $lines25",
      );
    });
    test('verify string with approved result options', () {
      helper.verify(
        'Hello World',
        'verify',
        approveResult: true,
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
}
