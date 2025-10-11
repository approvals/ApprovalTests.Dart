import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('verify sequence', () async {
    const List<int> sequence = [1, 2, 3, 4, 5];

    await Approvals.verifySequence(
      sequence,
    );
  });
}
