import 'dart:convert';
import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() => registerNamerTests();

void registerNamerTests() {
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

  group('Approval name safety', () {
    test('reports the rejected component without echoing its value', () {
      const exception = InvalidApprovalNameException(
        component: 'description',
        value: 'private/unsafe',
        reason: 'path separators are not allowed',
      );

      expect(
        exception.toString(),
        'Invalid approval description: path separators are not allowed',
      );
      expect(exception.toString(), isNot(contains('private/unsafe')));
    });

    test('rejects path separators in descriptions', () {
      final namer = Namer(
        filePath: 'test${separator}sample.dart',
        addTestName: false,
        description: 'group/name',
      );

      expect(
        () => namer.approvedFileName,
        throwsA(
          isA<InvalidApprovalNameException>()
              .having(
                (error) => error.component,
                'component',
                'description',
              )
              .having(
                (error) => error.value,
                'value',
                'group/name',
              ),
        ),
      );
    });

    test('rejects path separators in test and file name segments', () {
      const testNameOptions = FileNamerOptions(
        folderPath: 'test',
        fileName: 'sample',
        testName: r'group\case',
      );
      const fileNameOptions = FileNamerOptions(
        folderPath: 'test',
        fileName: 'nested/name',
        testName: 'case',
      );

      expect(
        () => testNameOptions.approvedFileName,
        throwsA(
          isA<InvalidApprovalNameException>().having(
            (error) => error.component,
            'component',
            'test name',
          ),
        ),
      );
      expect(
        () => fileNameOptions.approvedFileName,
        throwsA(
          isA<InvalidApprovalNameException>().having(
            (error) => error.component,
            'component',
            'file name',
          ),
        ),
      );
    });

    test('normalizes invalid and trailing characters consistently', () {
      const options = FileNamerOptions(
        folderPath: 'test',
        fileName: 'sample',
        testName: 'bad:name\u0001',
        description: 'tail. ',
      );

      expect(
        options.approvedFileName,
        'sample.bad_name_.tail__.approved.txt',
      );
    });

    test('prefixes platform-reserved segments', () {
      const options = FileNamerOptions(
        folderPath: 'test',
        fileName: 'CON',
        testName: 'case',
      );

      expect(options.approvedFileName, '_CON.case.approved.txt');
    });

    test('uses the normalized base segment in full paths', () {
      final namer = Namer(
        filePath: 'test${separator}CON.dart',
        addTestName: false,
      );

      expect(namer.approved, 'test${separator}_CON.approved.txt');
      expect(namer.approvedFileName, '_CON.approved.txt');
    });

    test('keeps existing valid names byte-for-byte compatible', () {
      const options = FileNamerOptions(
        folderPath: 'custom/folder',
        fileName: 'base',
        testName: 'test_case',
        description: 'details',
      );

      expect(options.approvedFileName, 'base.test_case.details.approved.txt');
      expect(options.receivedFileName, 'base.test_case.details.received.txt');
    });

    test('keeps a 255-byte filename unchanged', () {
      final base = List.filled(242, 'a').join();
      final namer = Namer(
        filePath: 'test${separator}$base.dart',
        addTestName: false,
      );

      expect(namer.approvedFileName, '$base.approved.txt');
      expect(namer.approvedFileName.codeUnits, hasLength(255));
    });

    test('shortens a filename above 255 UTF-8 bytes with a stable hash', () {
      final base = List.filled(243, 'a').join();
      final first = Namer(
        filePath: 'test${separator}$base.dart',
        addTestName: false,
      ).approvedFileName;
      final second = Namer(
        filePath: 'test${separator}$base.dart',
        addTestName: false,
      ).approvedFileName;

      expect(first, second);
      expect(first.codeUnits.length, lessThanOrEqualTo(255));
      expect(
        first,
        '${List.filled(225, 'a').join()}.'
        '3ff1ecf4916c4935.approved.txt',
      );
    });

    test('hash distinguishes long names with the same readable prefix', () {
      final sharedPrefix = List.filled(260, 'a').join();
      final first = Namer(
        filePath: 'test${separator}${sharedPrefix}x.dart',
        addTestName: false,
      ).approvedFileName;
      final second = Namer(
        filePath: 'test${separator}${sharedPrefix}y.dart',
        addTestName: false,
      ).approvedFileName;

      expect(first, isNot(second));
    });

    test('applies the length limit to UTF-8 bytes', () {
      final base = List.filled(130, 'é').join();
      final result = Namer(
        filePath: 'test${separator}$base.dart',
        addTestName: false,
      ).approvedFileName;

      expect(utf8.encode(result).length, lessThanOrEqualTo(255));
      expect(result, endsWith('.approved.txt'));
    });

    test('applies the length limit without changing the directory', () {
      final directory = p.join('root', List.filled(220, 'd').join());
      final base = List.filled(243, 'a').join();
      final result = Namer(
        filePath: p.join(directory, '$base.dart'),
        addTestName: false,
      ).approved;

      expect(p.dirname(result), directory);
      expect(utf8.encode(p.basename(result)).length, lessThanOrEqualTo(255));
    });
  });
}
