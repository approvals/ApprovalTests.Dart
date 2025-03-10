import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  group('Namer Tests', () {
    setUpAll(() => ApprovalLogger.log("===== Group: Namer ====="));

    void testNamer(String description, String filePath, String expected) {
      test(description, () {
        final namer = Namer(filePath: filePath);
        print(namer.approved);
        expect(namer.approved, contains(expected));
      });
    }

    testNamer(
        'Path check', 'test/groups', 'test/groups.path_check.approved.txt');
    testNamer('Custom path check', 'custom/path',
        'custom/path.custom_path_check.approved.txt');
  });

  group('IndexedNamer Tests', () {
    setUpAll(() => ApprovalLogger.log("===== Group: IndexedNamer ====="));

    void testIndexedNamer(
        String description, String filePath, String expected, bool isApproved) {
      test(description, () {
        final namer = IndexedNamer(filePath: filePath);
        final result = isApproved ? namer.approved : namer.received;
        print(result);
        expect(result, contains(expected));
      });
    }

    testIndexedNamer('Approved path check', 'test/groups',
        'test/groups.approved_path_check.0.approved.txt', true);
    testIndexedNamer('Approved name check', 'test/groups',
        'test/groups.approved_name_check.0.approved.txt', true);
    testIndexedNamer('Received path check', 'test/groups',
        'test/groups.received_path_check.0.received.txt', false);
    testIndexedNamer('Received name check', 'test/groups',
        'test/groups.received_name_check.0.received.txt', false);
    testIndexedNamer('Custom index path check', 'custom/path',
        'custom/path.custom_index_path_check.0.approved.txt', true);

    test('Incremented index check', () {
      final namer1 = IndexedNamer(filePath: 'test/groups');
      final namer2 = IndexedNamer(filePath: 'test/groups');
      expect(namer1.approved, isNot(equals(namer2.approved)));
    });

    test('Should create a new IndexedNamer object', () {
      final namer1 = IndexedNamer(filePath: 'test/groups');
      final namer2 = namer1.copyWith();
      expect(namer1, isNot(same(namer2)));
    });

    test('Should create a new Namer object', () {
      final namer1 = Namer(filePath: 'test/groups');
      final namer2 = namer1.copyWith();
      expect(namer1, isNot(same(namer2)));
    });
  });
}
