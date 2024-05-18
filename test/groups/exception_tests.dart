import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../approval_test.dart';

void main() {
  group('Approvals: test for exceptions |', () {
    setUpAll(() {
      ApprovalLogger.log(
        "$lines25 Group: Exception tests are starting $lines25",
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
}
