import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  test('can do stuff', () async {
    final stuff1 = {'id': 1, 'name': 'First'};
    final stuff2 = {'id': 2, 'name': 'Second'};

    await Approvals.verifyAsJson(
      stuff1,
      options: Options(
        namer: IndexedNamer(
          useSubfolder: true,
        ),
      ),
    );

    await Approvals.verifyAsJson(
      stuff2,
      options: Options(
        namer: IndexedNamer(
          useSubfolder: true,
        ),
      ),
    );
  });
}
