import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../approval_test.dart';
import '../models/item.dart';

void main() {
  group('Approvals: test for exceptions |', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Exception tests are starting $lines25",
      );
    });

    test("Method «verify» must throw DoesntMatchException", () async {
      await expectLater(
        helper.verify(
          'Hello W0rld',
          'verify',
          expectException: true,
          deleteReceivedFile: false,
        ),
        throwsA(isA<DoesntMatchException>()),
      );

      ApprovalLogger.success(
        "Test Passed: Method «verify» correctly throws DoesntMatchException as expected.",
      );
    });

    test("Method «verify» must throw DoesntMatchException with error handling",
        () async {
      await expectLater(
        helper.verify(
          'Hello W0rld',
          'verify',
        ),
        throwsA(isA<DoesntMatchException>()),
      );
      ApprovalLogger.success(
        "Test Passed: Successfully handled a log mismatch. Method «verify» correctly throws DoesntMatchException as expected.",
      );
    });

    test('Verify model (not map). Must throw UnsupportedError exception.',
        () async {
      await expectLater(
        Approvals.verifyAsJson(
          const ErrorItem(
            id: 1,
            name: "JsonItem",
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
