import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('verify sequence', () {
    const List<int> sequence = [1, 2, 3, 4, 5];

    Approvals.verifySequence(
      sequence,
    );
  });
}
