import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('Verify all combinations of input values', () {
    const List<List<int>> inputs = [
      [1, 2],
      [3, 4],
    ];

    Approvals.verifyAllCombinations(
      inputs,
      processor: (combination) => 'Combination: ${combination.join(", ")}',
      options: const Options(deleteReceivedFile: true),
    );
  });
}
