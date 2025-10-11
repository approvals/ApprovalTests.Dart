import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('can do stuff', () {
    final stuff1 = {'id': 1, 'name': 'First'};
    final stuff2 = {'id': 2, 'name': 'Second'};

    Approvals.verifyAsJson(
      stuff1,
      options: Options(
        namer: IndexedNamer(
          useSubfolder: true,
        ),
      ),
    );

    Approvals.verifyAsJson(
      stuff2,
      options: Options(
        namer: IndexedNamer(
          useSubfolder: true,
        ),
      ),
    );
  });
}
