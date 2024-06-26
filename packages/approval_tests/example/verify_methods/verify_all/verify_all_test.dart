import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('verify all items', () {
    const List<String> items = ['apple', 'banana', 'cherry'];

    Approvals.verifyAll(
      items,
      processor: (item) => 'Item: $item',
    );
  });
}
