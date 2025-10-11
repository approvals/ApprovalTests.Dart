import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('verify method', () async {
    const String response =
        '{"result": "success", "data": {"id": 1, "name": "Item"}}';

    await Approvals.verify(
      response,
    );
  });
}
