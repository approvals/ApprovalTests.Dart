import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:approval_tests/src/core/enums/file_type.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Reporter that always fails, used to exercise the catchError handler.
class _FailingReporter implements Reporter {
  const _FailingReporter();

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    throw Exception('intentional reporter failure');
  }
}

final class _RecordingReporter implements Reporter {
  var callCount = 0;

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    callCount++;
  }
}

final class _FixedApprovalNamer implements ApprovalNamer {
  @override
  final String filePath;
  @override
  final String approved;
  @override
  final String received;
  @override
  final String? description;

  const _FixedApprovalNamer({
    required this.filePath,
    required this.approved,
    required this.received,
    this.description,
  });

  @override
  bool get addTestName => false;

  @override
  String get approvedFileName => _fileNameOf(approved);

  @override
  String get currentTestName => '';

  @override
  FileNamerOptions? get options => null;

  @override
  String get receivedFileName => _fileNameOf(received);

  @override
  bool get useSubfolder => false;

  @override
  _FixedApprovalNamer copyWith({
    String? filePath,
    FileNamerOptions? options,
    bool? addTestName,
    String? description,
    bool? useSubfolder,
  }) =>
      _FixedApprovalNamer(
        filePath: filePath ?? this.filePath,
        approved: approved,
        received: received,
        description: description ?? this.description,
      );

  static String _fileNameOf(String path) =>
      path.substring(path.lastIndexOf(Platform.pathSeparator) + 1);
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
      // Create a regular file, then attempt to write inside it as if it
      // were a directory. This reliably triggers FileSystemException on
      // every platform (you cannot create a subdirectory inside a file).
      final tempDir = Directory.systemTemp.createTempSync('approval_blocker');
      final blocker = File('${tempDir.path}${Platform.pathSeparator}not_a_dir')
        ..createSync();
      addTearDown(() {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      });

      final options = Options(
        namer: Namer(
          filePath: '${blocker.path}${Platform.pathSeparator}impossible.dart',
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

  group('Approvals.verify missing-approved policy', () {
    test('creates approved file and passes by default', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_missing_compatibility',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final fileBase = '${tempDir.path}/compatibility';

      Approvals.verify(
        'received content',
        options: Options(
          namer: Namer(filePath: fileBase, addTestName: false),
          logResults: false,
        ),
      );

      expect(File('$fileBase.approved.txt').existsSync(), isTrue);
      expect(File('$fileBase.received.txt').existsSync(), isFalse);
    });

    test('strict mode leaves received file and throws typed mismatch', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_missing_strict',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final fileBase = '${tempDir.path}/strict';
      final reporter = _RecordingReporter();

      expect(
        () => Approvals.verify(
          'received content',
          options: Options(
            namer: Namer(filePath: fileBase, addTestName: false),
            missingApprovedPolicy: MissingApprovedPolicy.writeReceivedAndFail,
            reporter: reporter,
            logErrors: false,
          ),
        ),
        throwsA(
          isA<DoesntMatchException>().having(
            (error) => error.kind,
            'kind',
            ApprovalMismatchKind.missingApproved,
          ),
        ),
      );

      expect(File('$fileBase.approved.txt').existsSync(), isFalse);
      final receivedContent = File('$fileBase.received.txt').readAsStringSync();
      expect(receivedContent, contains('received content'));
      expect(reporter.callCount, isZero);
    });

    test('strict mode does not let approveResult create approved file', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_missing_strict_approve',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final fileBase = '${tempDir.path}/strict_approve';

      expect(
        () => Approvals.verify(
          'received content',
          options: Options(
            namer: Namer(filePath: fileBase, addTestName: false),
            approveResult: true,
            missingApprovedPolicy: MissingApprovedPolicy.writeReceivedAndFail,
            logErrors: false,
          ),
        ),
        throwsA(
          isA<DoesntMatchException>().having(
            (error) => error.kind,
            'kind',
            ApprovalMismatchKind.missingApproved,
          ),
        ),
      );

      expect(File('$fileBase.approved.txt').existsSync(), isFalse);
    });

    test('strict mode does not let approveResult mutate approved file', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_existing_strict_approve',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final fileBase = '${tempDir.path}/strict_approve';
      final approvedFile = File('$fileBase.approved.txt')
        ..writeAsStringSync('existing approved content');

      expect(
        () => Approvals.verify(
          'new received content',
          options: Options(
            namer: Namer(filePath: fileBase, addTestName: false),
            approveResult: true,
            missingApprovedPolicy: MissingApprovedPolicy.writeReceivedAndFail,
            logErrors: false,
          ),
        ),
        throwsA(
          isA<DoesntMatchException>().having(
            (error) => error.kind,
            'kind',
            ApprovalMismatchKind.contentMismatch,
          ),
        ),
      );

      expect(approvedFile.readAsStringSync(), 'existing approved content');
    });
  });

  group('Approvals.verify path collisions', () {
    test('collision message identifies both verifications', () {
      const exception = ApprovalPathCollisionException(
        path: '/tmp/shared.approved.txt',
        firstVerification: 'first verification',
        secondVerification: 'second verification',
      );

      expect(
        exception.toString(),
        'Approval path collision at [/tmp/shared.approved.txt].\n'
        'First verification: first verification\n'
        'Second verification: second verification',
      );
    });

    test('fails before two logical approvals write the same path', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_path_collision',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final fileBase = p.join(tempDir.path, 'shared');
      final options = Options(
        namer: Namer(filePath: fileBase, addTestName: false),
        logErrors: false,
        logResults: false,
      );

      Approvals.verify('first', options: options);

      expect(
        () => Approvals.verify('first', options: options),
        throwsA(
          isA<ApprovalPathCollisionException>()
              .having(
                (error) => error.path,
                'path',
                File('$fileBase.approved.txt').absolute.path,
              )
              .having(
                (error) => error.firstVerification,
                'firstVerification',
                allOf(
                  contains('fails before two logical approvals'),
                  contains('(approved)'),
                ),
              )
              .having(
                (error) => error.secondVerification,
                'secondVerification',
                allOf(
                  contains('fails before two logical approvals'),
                  contains('(approved)'),
                ),
              ),
        ),
      );
      expect(
        File('$fileBase.approved.txt').readAsStringSync(),
        contains('first'),
      );
    });

    test('validates final paths returned by custom namers', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_custom_namer_validation',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final separator = Platform.pathSeparator;
      final approved = '${tempDir.path}${separator}unsafe:name.approved.txt';
      final received = '${tempDir.path}${separator}safe.received.txt';
      final options = Options(
        namer: _FixedApprovalNamer(
          filePath: '${tempDir.path}${separator}source.dart',
          approved: approved,
          received: received,
        ),
        logErrors: false,
      );

      expect(
        () => Approvals.verify('content', options: options),
        throwsA(
          isA<InvalidApprovalNameException>().having(
            (error) => error.component,
            'component',
            'approved artifact name',
          ),
        ),
      );
      expect(File(received).existsSync(), isFalse);
    });

    test('rejects custom artifact names above 255 UTF-8 bytes before writing',
        () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_custom_namer_length',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final separator = Platform.pathSeparator;
      final oversizedName = '${List.filled(128, 'é').join()}.approved.txt';
      final approved = '${tempDir.path}$separator$oversizedName';
      final received = '${tempDir.path}${separator}safe.received.txt';

      expect(
        () => Approvals.verify(
          'content',
          options: Options(
            namer: _FixedApprovalNamer(
              filePath: '${tempDir.path}${separator}source.dart',
              approved: approved,
              received: received,
            ),
            logErrors: false,
          ),
        ),
        throwsA(
          isA<InvalidApprovalNameException>()
              .having(
                (error) => error.component,
                'component',
                'approved artifact name',
              )
              .having(
                (error) => error.reason,
                'reason',
                contains('exceeds 255 UTF-8 bytes'),
              ),
        ),
      );
      expect(tempDir.listSync(), isEmpty);
    });

    test('does not claim either path when pair validation fails', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'approval_atomic_path_claim',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final separator = Platform.pathSeparator;
      final approved = '${tempDir.path}${separator}safe.approved.txt';
      final invalidReceived =
          '${tempDir.path}${separator}unsafe:name.received.txt';
      final validReceived = '${tempDir.path}${separator}safe.received.txt';

      expect(
        () => Approvals.verify(
          'content',
          options: Options(
            namer: _FixedApprovalNamer(
              filePath: '${tempDir.path}${separator}source.dart',
              approved: approved,
              received: invalidReceived,
            ),
            logErrors: false,
          ),
        ),
        throwsA(isA<InvalidApprovalNameException>()),
      );

      expect(
        () => Approvals.verify(
          'content',
          options: Options(
            namer: _FixedApprovalNamer(
              filePath: '${tempDir.path}${separator}source.dart',
              approved: approved,
              received: validReceived,
            ),
            approveResult: true,
            logErrors: false,
            logResults: false,
          ),
        ),
        returnsNormally,
      );
    });
  });
}
