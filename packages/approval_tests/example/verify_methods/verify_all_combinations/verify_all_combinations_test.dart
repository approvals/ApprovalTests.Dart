import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('verify combinations', () {
    const List<List<int>> inputs = [
      [1, 2],
      [3, 4],
    ];

    Approvals.verifyAllCombinations(
      inputs,
      processor: (combination) => 'Combination: ${combination.join(", ")}',
    );
  });
}
