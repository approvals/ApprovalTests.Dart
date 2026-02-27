import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:approval_tests/src/core/enums/file_type.dart';
import 'package:test/test.dart';

/// Reporter that always fails, used to exercise the catchError handler.
class _FailingReporter implements Reporter {
  const _FailingReporter();

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    throw Exception('intentional reporter failure');
  }
}

void main() => registerApprovalsTests();

void registerApprovalsTests() {
  tearDown(() => Approvals.resetFileToNamerMap());

  group('Approvals.filePathForDeletion', () {
    test('returns approved path when namer provided', () {
      final Directory tempDir = Directory.systemTemp.createTempSync();
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final String dartPath = '${tempDir.path}/sample.dart';
      final ApprovalNamer namer = Namer(
        filePath: dartPath,
        addTestName: false,
      );

      final String resolvedPath = Approvals.filePathForDeletion(
        namer: namer,
        fileType: FileType.approved,
      );

      expect(resolvedPath, equals(namer.approved));
    });

    test('creates default namer when none provided', () {
      final String resolvedPath = Approvals.filePathForDeletion(
        namer: null,
        fileType: FileType.approved,
      );

      expect(resolvedPath, isNotEmpty);
      expect(resolvedPath, endsWith('.approved.txt'));
    });

    test('throws when file type unsupported', () {
      Approvals.fileToNamerMap.remove(FileType.received);

      expect(
        () => Approvals.filePathForDeletion(
          namer: null,
          fileType: FileType.received,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('Unsupported file type for deletion'),
          ),
        ),
      );
    });
  });

  group('Approvals.verify error handling', () {
    test('logs non-DoesntMatchException when logErrors is true', () {
      // Writing to a non-existent directory causes FileSystemException,
      // which is NOT a DoesntMatchException, so the logging branch fires.
      final options = Options(
        namer: Namer(
          filePath: '/nonexistent/dir/deep/path',
          addTestName: false,
        ),
        logErrors: true,
      );

      expect(
        () => Approvals.verify('content', options: options),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('catches reporter failure via catchError', () async {
      final tempDir = Directory.systemTemp.createTempSync('reporter_fail_test');
      final fileBase = '${tempDir.path}/reporter_fail';
      try {
        // Create an approved file with different content so files don't match.
        File('$fileBase.approved.txt').writeAsStringSync('approved');

        final options = Options(
          namer: Namer(filePath: fileBase, addTestName: false),
          reporter: const _FailingReporter(),
          logErrors: false,
        );

        expect(
          () => Approvals.verify('received', options: options),
          throwsA(isA<DoesntMatchException>()),
        );

        // Let the unawaited catchError handler execute.
        await Future<void>.delayed(Duration.zero);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
