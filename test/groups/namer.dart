import 'dart:io'; // For Platform.pathSeparator
import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() => registerNamerTests();

void registerNamerTests() {
  // Use the platform-specific path separator
  final String separator = Platform.pathSeparator;

  group('Namer Tests', () {
    setUpAll(() => ApprovalLogger.log("===== Group: Namer ====="));

    void testNamer(String description, String filePath, String expected) {
      test(description, () {
        final namer = Namer(filePath: filePath);
        print(namer.approved);
        expect(namer.approved, equals(expected));
      });
    }

    testNamer(
      'Path check',
      'test${separator}groups',
      'test${separator}groups.path_check.approved.txt',
    );
    testNamer(
      'Custom path check',
      'custom${separator}path',
      'custom${separator}path.custom_path_check.approved.txt',
    );
  });

  group('IndexedNamer Tests', () {
    setUpAll(() => ApprovalLogger.log("===== Group: IndexedNamer ====="));

    void testIndexedNamer(
        String description, String filePath, String expected, bool isApproved) {
      test(description, () {
        final namer = IndexedNamer(filePath: filePath);
        final result = isApproved ? namer.approved : namer.received;
        print(result);
        expect(result, equals(expected));
      });
    }

    testIndexedNamer(
      'Approved path check',
      'test${separator}groups',
      'test${separator}groups.approved_path_check.0.approved.txt',
      true,
    );
    testIndexedNamer(
      'Approved name check',
      'test${separator}groups',
      'test${separator}groups.approved_name_check.0.approved.txt',
      true,
    );
    testIndexedNamer(
      'Received path check',
      'test${separator}groups',
      'test${separator}groups.received_path_check.0.received.txt',
      false,
    );
    testIndexedNamer(
      'Received name check',
      'test${separator}groups',
      'test${separator}groups.received_name_check.0.received.txt',
      false,
    );
    testIndexedNamer(
      'Custom index path check',
      'custom${separator}path',
      'custom${separator}path.custom_index_path_check.0.approved.txt',
      true,
    );

    test('Incremented index check', () {
      final namer1 = IndexedNamer(filePath: 'test${separator}groups');
      final namer2 = IndexedNamer(filePath: 'test${separator}groups');
      expect(namer1.approved, isNot(equals(namer2.approved)));
    });

    test('Should create a new IndexedNamer object', () {
      final namer1 = IndexedNamer(filePath: 'test${separator}groups');
      final namer2 = namer1.copyWith();
      expect(namer1, isNot(same(namer2)));
    });

    test('Should create a new Namer object', () {
      final namer1 = Namer(filePath: 'test${separator}groups');
      final namer2 = namer1.copyWith();
      expect(namer1, isNot(same(namer2)));
    });

    test('IndexedNamer uses FileNamerOptions file names', () {
      const options = FileNamerOptions(
        folderPath: 'custom/folder',
        fileName: 'base',
        testName: 'test_case',
        description: 'details',
      );

      final namer = IndexedNamer(
        options: options,
        filePath: 'ignored${separator}value.dart',
        addTestName: false,
      );

      expect(namer.approvedFileName, equals(options.approvedFileName));
      expect(namer.receivedFileName, equals(options.receivedFileName));
      expect(namer.approved, equals(options.approved));
      expect(namer.received, equals(options.received));
    });

    test('IndexedNamer default approvedFileName uses counter', () {
      final tempDir =
          Directory.systemTemp.createTempSync('indexed_approved_counter');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final filePath = '${tempDir.path}${separator}sample.dart';
      final namer = IndexedNamer(
        filePath: filePath,
        addTestName: false,
      );

      expect(
        namer.approvedFileName,
        equals('sample.0.approved.txt'),
      );
    });

    test('resetCounters clears internal counter state', () {
      IndexedNamer.resetCounters();
      final before = IndexedNamer(
        filePath: 'test${separator}reset_check',
        addTestName: false,
      );
      expect(before.counter, equals(0));

      IndexedNamer.resetCounters();
      final after = IndexedNamer(
        filePath: 'test${separator}reset_check',
        addTestName: false,
      );
      expect(after.counter, equals(0));
    });

    test('IndexedNamer default receivedFileName uses counter', () {
      final tempDir =
          Directory.systemTemp.createTempSync('indexed_received_counter');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final filePath = '${tempDir.path}${separator}sample.dart';
      final first = IndexedNamer(
        filePath: filePath,
        addTestName: false,
      );
      final second = IndexedNamer(
        filePath: filePath,
        addTestName: false,
      );

      expect(first.receivedFileName, equals('sample.0.received.txt'));
      expect(second.receivedFileName, equals('sample.1.received.txt'));
    });
  });
}
