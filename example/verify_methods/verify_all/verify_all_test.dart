import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('verify all items', () async {
    const List<String> items = ['apple', 'banana', 'cherry'];

    await Approvals.verifyAll(
      items,
      processor: (item) => 'Item: $item',
    );
  });
}
