import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:approval_tests/approval_tests.dart';
import 'package:approval_tests/src/writers/approval_file_replacer.dart';
import 'package:test/test.dart';

final class _TransientRenameFile implements File {
  final File _delegate;
  final int errorCode;
  int failuresRemaining;
  int renameAttempts = 0;

  _TransientRenameFile(
    this._delegate, {
    required this.failuresRemaining,
    this.errorCode = 5,
  });

  @override
  String get path => _delegate.path;

  @override
  File renameSync(String newPath) {
    renameAttempts++;
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw PathAccessException(
        path,
        OSError('Access is denied', errorCode),
        'Cannot rename file',
      );
    }
    return _delegate.renameSync(newPath);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _CleanupFailureOverrides extends IOOverrides {
  @override
  File createFile(String path) {
    final file = super.createFile(path);
    return path.endsWith('.tmp') ? _FailingTemporaryFile(file) : file;
  }
}

final class _FailingTemporaryFile implements File {
  final File _delegate;

  const _FailingTemporaryFile(this._delegate);

  @override
  String get path => _delegate.path;

  @override
  Directory get parent => _delegate.parent;

  @override
  void writeAsStringSync(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    _delegate.writeAsStringSync(
      contents,
      mode: mode,
      encoding: encoding,
      flush: flush,
    );
  }

  @override
  File renameSync(String newPath) {
    throw FileSystemException('replacement failed', path);
  }

  @override
  bool existsSync() => _delegate.existsSync();

  @override
  void deleteSync({bool recursive = false}) {
    throw FileSystemException('cleanup failed', path);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ApprovalFileReplacer', () {
    test('retries transient Windows access errors until replacement succeeds',
        () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_file_replacer',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final replaced = File(
        '${tempDir.path}${Platform.pathSeparator}approval.txt',
      )..writeAsStringSync('old');
      final replacement = _TransientRenameFile(
        File('${replaced.path}.tmp')..writeAsStringSync('new'),
        failuresRemaining: 2,
      );
      final waits = <Duration>[];
      final replacer = ApprovalFileReplacer(
        isWindows: true,
        wait: waits.add,
      );

      replacer.replace(replacement: replacement, replaced: replaced);

      expect(replacement.renameAttempts, 3);
      expect(waits, [
        ApprovalFileReplacer.windowsRetryDelay,
        ApprovalFileReplacer.windowsRetryDelay,
      ]);
      expect(replaced.readAsStringSync(), 'new');
    });

    test('does not retry access errors outside Windows', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_file_replacer_non_windows',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final replaced = File(
        '${tempDir.path}${Platform.pathSeparator}approval.txt',
      )..writeAsStringSync('old');
      final replacement = _TransientRenameFile(
        File('${replaced.path}.tmp')..writeAsStringSync('new'),
        failuresRemaining: 1,
      );
      final replacer = ApprovalFileReplacer(
        isWindows: false,
        wait: (_) => fail('must not wait'),
      );

      expect(
        () => replacer.replace(
          replacement: replacement,
          replaced: replaced,
        ),
        throwsA(isA<PathAccessException>()),
      );
      expect(replacement.renameAttempts, 1);
      expect(replaced.readAsStringSync(), 'old');
    });

    test('does not retry unrelated Windows access errors', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_file_replacer_other_error',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final replaced = File(
        '${tempDir.path}${Platform.pathSeparator}approval.txt',
      )..writeAsStringSync('old');
      final replacement = _TransientRenameFile(
        File('${replaced.path}.tmp')..writeAsStringSync('new'),
        failuresRemaining: 1,
        errorCode: 13,
      );
      final replacer = ApprovalFileReplacer(
        isWindows: true,
        wait: (_) => fail('must not wait'),
      );

      expect(
        () => replacer.replace(
          replacement: replacement,
          replaced: replaced,
        ),
        throwsA(isA<PathAccessException>()),
      );
      expect(replacement.renameAttempts, 1);
      expect(replaced.readAsStringSync(), 'old');
    });

    test('stops retrying Windows access errors at the attempt limit', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_file_replacer_limit',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final replaced = File(
        '${tempDir.path}${Platform.pathSeparator}approval.txt',
      )..writeAsStringSync('old');
      final replacement = _TransientRenameFile(
        File('${replaced.path}.tmp')..writeAsStringSync('new'),
        failuresRemaining: ApprovalFileReplacer.maxWindowsAttempts,
      );
      final replacer = ApprovalFileReplacer(
        isWindows: true,
        wait: (_) {},
      );

      expect(
        () => replacer.replace(
          replacement: replacement,
          replaced: replaced,
        ),
        throwsA(isA<PathAccessException>()),
      );
      expect(
        replacement.renameAttempts,
        ApprovalFileReplacer.maxWindowsAttempts,
      );
      expect(replaced.readAsStringSync(), 'old');
    });
  });

  group('ApprovalTextWriter', () {
    test('readers never observe a partial file during concurrent writes',
        () async {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_atomic_writer',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final path = '${tempDir.path}${Platform.pathSeparator}approval.txt';
      final firstContent = List.filled(1024 * 1024, 'a').join();
      final secondContent = List.filled(1024 * 1024, 'b').join();
      const initialContent = 'initial';
      const header = '${ApprovalTestsConstants.baseHeader}\n';
      final allowedContents = {
        '$header$initialContent',
        '$header$firstContent',
        '$header$secondContent',
      };

      const ApprovalTextWriter(initialContent).writeToFile(path);

      var writesCompleted = false;
      final writes = Isolate.run(() {
        for (var index = 0; index < 30; index++) {
          ApprovalTextWriter(
            index.isEven ? firstContent : secondContent,
          ).writeToFile(path);
        }
      }).whenComplete(() => writesCompleted = true);

      String? invalidObservation;
      while (!writesCompleted && invalidObservation == null) {
        try {
          final observed = File(path).readAsStringSync();
          if (!allowedContents.contains(observed)) {
            invalidObservation = 'partial file with ${observed.length} bytes';
          }
        } on FileSystemException catch (error) {
          // Windows may deny a read during replace while the path still exists.
          if (!File(path).existsSync()) {
            invalidObservation = 'missing file: ${error.message}';
          }
        }
        await Future<void>.delayed(Duration.zero);
      }
      await writes;

      expect(invalidObservation, isNull);
      expect(
        allowedContents,
        contains(File(path).readAsStringSync()),
      );
      expect(tempDir.listSync(), hasLength(1));
    });

    test('removes the temporary file when replacement fails', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_atomic_writer_failure',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final targetDirectory = Directory(
        '${tempDir.path}${Platform.pathSeparator}approval.txt',
      )..createSync();

      expect(
        () => const ApprovalTextWriter('content').writeToFile(
          targetDirectory.path,
        ),
        throwsA(isA<FileSystemException>()),
      );

      expect(targetDirectory.existsSync(), isTrue);
      final remainingEntries = tempDir.listSync();
      expect(remainingEntries, hasLength(1));
      expect(remainingEntries.single.path, targetDirectory.path);
    });

    test('preserves replacement failure when temporary cleanup also fails', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_atomic_writer_cleanup_failure',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final path = '${tempDir.path}${Platform.pathSeparator}approval.txt';

      expect(
        () => IOOverrides.runWithIOOverrides(
          () => const ApprovalTextWriter('content').writeToFile(path),
          _CleanupFailureOverrides(),
        ),
        throwsA(
          isA<FileSystemException>().having(
            (error) => error.message,
            'message',
            'replacement failed',
          ),
        ),
      );

      final remainingEntries = tempDir.listSync();
      expect(remainingEntries, hasLength(1));
      expect(remainingEntries.single.path, endsWith('.tmp'));
    });
  });
}
