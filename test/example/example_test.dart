import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

// begin-snippet: sample_verify_as_json_test
void main() {
  test('test JSON object', () {
    final complexObject = {
      'name': 'JsonTest',
      'features': ['Testing', 'JSON'],
      'version': 0.1,
    };

    Approvals.verifyAsJson(
      complexObject,
      options: const Options(
        approveResult: true,
      ),
    );
  });
}
// end-snippet
