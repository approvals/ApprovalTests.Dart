import 'package:approval_tests/approval_tests.dart';
import 'package:dart_application/dart_example.dart';
import 'package:test/test.dart';

void main() {
  group('Fizz Buzz', () {
    test("verify combinations", () {
      Approvals.verifyAll(
        [3, 5, 15],
        options: const Options(
          reporter: DiffReporter(),
          deleteReceivedFile: false,
        ),
        processor: (items) => fizzBuzz(items).toString(),
      );
    });
  });
}
