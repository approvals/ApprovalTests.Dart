import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('verify method', () {
    const String response =
        '{"result": "success", "data": {"id": 1, "name": "Item"}}';

    Approvals.verify(
      response,
    );
  });
}
