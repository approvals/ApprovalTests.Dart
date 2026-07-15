import 'dart:io';
import 'dart:async';

import 'package:approval_tests/approval_tests.dart';
import 'package:approval_tests/src/cli/review_cli.dart';
import 'package:test/test.dart';

void main() {
  group('ReviewCli discovery', () {
    test('sorts received files by normalized relative path', () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));

      final nestedDirectory = Directory('${tempDirectory.path}/nested');
      await nestedDirectory.create();
      await File('${tempDirectory.path}/z.received.txt').writeAsString('z');
      await File('${nestedDirectory.path}/b.received.txt').writeAsString('b');
      await File('${nestedDirectory.path}/a.received.txt').writeAsString('a');
      await File('${tempDirectory.path}/ignored.approved.txt')
          .writeAsString('ignored');

      final files = await ReviewCli(
        workingDirectory: tempDirectory,
      ).findReceivedFiles();

      expect(
        files.map((file) => file.path.substring(tempDirectory.path.length + 1)),
        equals([
          'nested/a.received.txt',
          'nested/b.received.txt',
          'z.received.txt',
        ]),
      );
    });
  });

  group('ReviewCli artifact validation', () {
    test('derives an approved path only for a received artifact', () {
      final cli = ReviewCli(workingDirectory: Directory.current);

      expect(
        cli.approvedFileFor(File('/tmp/sample.received.txt')).path,
        '/tmp/sample.approved.txt',
      );
      expect(
        () => cli.approvedFileFor(File('/tmp/received.txt.backup')),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => cli.approvedFileFor(File('/tmp/notreceived.txt')),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => cli.approvedFileFor(File('/tmp/.received.txt/sample.txt')),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('DiffReporterReviewTool', () {
    test('exposes availability and command description', () {
      final tool = DiffReporterReviewTool(
        DiffReporter(
          customDiffInfo: DiffInfo(
            name: 'Dart',
            command: Platform.resolvedExecutable,
            arg: '--version',
          ),
        ),
      );

      expect(tool.isAvailable, isTrue);
      expect(
        tool.commandDescription,
        '${Platform.resolvedExecutable} --version',
      );
    });
  });

  group('ReviewCli processing', () {
    test('waits for each review before starting the next one', () async {
      final firstReviewCompleted = Completer<void>();
      final startedReviews = <String>[];
      final cli = ReviewCli(workingDirectory: Directory.current);

      final reviewsCompleted = cli.reviewFiles(
        [
          File('/tmp/first.received.txt'),
          File('/tmp/second.received.txt'),
        ],
        (file) async {
          startedReviews.add(file.path);
          if (file.path.contains('first')) {
            await firstReviewCompleted.future;
          }
        },
      );
      await Future<void>.delayed(Duration.zero);

      expect(startedReviews, ['/tmp/first.received.txt']);

      firstReviewCompleted.complete();
      await reviewsCompleted;

      expect(
        startedReviews,
        ['/tmp/first.received.txt', '/tmp/second.received.txt'],
      );
    });

    test('waits for the selected diff tool before reading another choice',
        () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final receivedFile = File('${tempDirectory.path}/sample.received.txt');
      final approvedFile = File('${tempDirectory.path}/sample.approved.txt');
      await receivedFile.writeAsString('received');
      await approvedFile.writeAsString('approved');

      final console = _FakeReviewConsole(['v', 'code', 'n']);
      final diffTool = _CompletingDiffTool();
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
        diffFiles: (_, __) => 'difference',
        diffToolFactory: (_) => diffTool,
      );

      var reviewCompleted = false;
      final review = cli.reviewFile(receivedFile).then((_) {
        reviewCompleted = true;
      });
      await diffTool.reportStarted;

      expect(reviewCompleted, isFalse);
      expect(console.remainingLines, 1);

      diffTool.completeReport();
      await review;

      expect(reviewCompleted, isTrue);
      expect(console.remainingLines, 0);
    });

    test('surfaces a selected diff tool failure', () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final receivedFile = File('${tempDirectory.path}/sample.received.txt');
      final approvedFile = File('${tempDirectory.path}/sample.approved.txt');
      await receivedFile.writeAsString('received');
      await approvedFile.writeAsString('approved');
      final console = _FakeReviewConsole(['v', 'code']);
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
        diffFiles: (_, __) => 'difference',
        diffToolFactory: (_) => const _FailingDiffTool(),
      );

      await expectLater(
        cli.reviewFile(receivedFile),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'diff failed',
          ),
        ),
      );
    });

    test('rejects an existing path that is not a received artifact', () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final unsupportedFile = File('${tempDirectory.path}/sample.txt');
      await unsupportedFile.writeAsString('keep');
      final console = _FakeReviewConsole(const []);
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
      );

      await cli.run([unsupportedFile.path]);

      expect(await unsupportedFile.readAsString(), 'keep');
      expect(
        console.logs,
        contains(
          predicate<(ReviewMessageLevel, String)>(
            (entry) =>
                entry.$1 == ReviewMessageLevel.error &&
                entry.$2.contains('Expected a .received.txt artifact'),
          ),
        ),
      );
    });

    test('run reviews every discovered file and reports the count', () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      await File('${tempDirectory.path}/b.received.txt').writeAsString('b');
      await File('${tempDirectory.path}/a.received.txt').writeAsString('a');
      final console = _FakeReviewConsole(['n', 'n']);
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
      );

      await cli.run(const []);

      expect(console.remainingLines, 0);
      expect(
        console.logs,
        contains(
          (
            ReviewMessageLevel.success,
            'Review completed. 2 test results reviewed.',
          ),
        ),
      );
    });

    test('--list persists sorted paths that can be reviewed by index',
        () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final firstFile = File('${tempDirectory.path}/a.received.txt');
      final secondFile = File('${tempDirectory.path}/b.received.txt');
      await secondFile.writeAsString('b');
      await firstFile.writeAsString('a');
      final console = _FakeReviewConsole(['n']);
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
      );

      await cli.run(const ['--list']);

      expect(
        await cli.readReceivedFiles(),
        [firstFile.path, secondFile.path],
      );

      await cli.run(const ['0']);

      expect(console.remainingLines, 0);
      expect(
        console.logs,
        contains(
          predicate<(ReviewMessageLevel, String)>(
            (entry) =>
                entry.$1 == ReviewMessageLevel.info &&
                entry.$2.contains(firstFile.path),
          ),
        ),
      );
    });

    test('reports help, unknown options, and an unavailable index', () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final console = _FakeReviewConsole(const []);
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
      );

      await cli.run(const ['--help']);
      await cli.run(const ['--unknown']);
      await cli.run(const ['0']);

      expect(
        console.logs.map((entry) => entry.$2),
        containsAll([
          contains('Manage your package:approval_tests files.'),
          contains("Unknown option '--unknown'"),
          contains('No received file with an index of 0'),
        ]),
      );
    });

    test('reports an empty project and a missing relative artifact', () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final console = _FakeReviewConsole(const []);
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
      );

      await cli.run(const []);
      await cli.run(const ['missing.received.txt']);

      expect(
        console.logs.map((entry) => entry.$2),
        containsAll([
          'No received test results to review!',
          contains('File does not exist:'),
        ]),
      );
    });

    test('approves a changed received artifact', () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final receivedFile = File('${tempDirectory.path}/sample.received.txt');
      final approvedFile = File('${tempDirectory.path}/sample.approved.txt');
      await receivedFile.writeAsString('new');
      await approvedFile.writeAsString('old');
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: _FakeReviewConsole(['y']),
        diffFiles: (_, __) => 'difference',
      );

      await cli.reviewFile(receivedFile);

      expect(await receivedFile.exists(), isFalse);
      expect(await approvedFile.readAsString(), 'new');
    });

    test('does not prompt when approved and received artifacts match',
        () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final receivedFile = File('${tempDirectory.path}/sample.received.txt');
      final approvedFile = File('${tempDirectory.path}/sample.approved.txt');
      await receivedFile.writeAsString('same');
      await approvedFile.writeAsString('same');
      final console = _FakeReviewConsole(const []);
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
        diffFiles: (_, __) => '',
      );

      expect(await cli.reviewFile(receivedFile), isTrue);
      expect(
        console.logs,
        contains(
          (
            ReviewMessageLevel.success,
            'No differences found. Approval test approved.',
          ),
        ),
      );
    });

    test('opens a received artifact when no approved artifact exists',
        () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final receivedFile = File('${tempDirectory.path}/sample.received.txt');
      await receivedFile.writeAsString('received');
      final console = _FakeReviewConsole(['v', 'studio', 'n']);
      final diffTool = _RecordingDiffTool();
      ComparatorIDE? selectedIde;
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
        diffToolFactory: (ide) {
          selectedIde = ide;
          return diffTool;
        },
      );

      await cli.reviewFile(receivedFile);

      expect(selectedIde, ComparatorIDE.studio);
      expect(diffTool.openedPaths, [receivedFile.path]);
    });

    test('warns when the selected diff tool is unavailable', () async {
      final tempDirectory =
          await Directory.systemTemp.createTemp('approval_review_cli_');
      addTearDown(() => tempDirectory.delete(recursive: true));
      final receivedFile = File('${tempDirectory.path}/sample.received.txt');
      final approvedFile = File('${tempDirectory.path}/sample.approved.txt');
      await receivedFile.writeAsString('received');
      await approvedFile.writeAsString('approved');
      final console = _FakeReviewConsole(['v', 'code', 'n']);
      final cli = ReviewCli(
        workingDirectory: tempDirectory,
        console: console,
        diffFiles: (_, __) => 'difference',
        diffToolFactory: (_) => const _UnavailableDiffTool(),
      );

      await cli.reviewFile(receivedFile);

      expect(
        console.logs,
        contains(
          (
            ReviewMessageLevel.warning,
            'No diff tool available: unavailable diff',
          ),
        ),
      );
    });
  });
}

final class _FakeReviewConsole implements ReviewConsole {
  _FakeReviewConsole(Iterable<String> lines) : _lines = List.of(lines);

  final List<String> _lines;
  final logs = <(ReviewMessageLevel, String)>[];

  int get remainingLines => _lines.length;

  @override
  String? readLine() => _lines.isEmpty ? null : _lines.removeAt(0);

  @override
  void write(String message) {}

  @override
  void log(ReviewMessageLevel level, String message) {
    logs.add((level, message));
  }
}

final class _CompletingDiffTool implements ReviewDiffTool {
  final Completer<void> _reportStarted = Completer<void>();
  final Completer<void> _reportCompleted = Completer<void>();

  Future<void> get reportStarted => _reportStarted.future;

  @override
  bool get isAvailable => true;

  @override
  String get commandDescription => 'fake diff';

  @override
  Future<void> open(String receivedPath) async {}

  @override
  Future<void> report(String approvedPath, String receivedPath) {
    _reportStarted.complete();
    return _reportCompleted.future;
  }

  void completeReport() => _reportCompleted.complete();
}

final class _FailingDiffTool implements ReviewDiffTool {
  const _FailingDiffTool();

  @override
  String get commandDescription => 'failing diff';

  @override
  bool get isAvailable => true;

  @override
  Future<void> open(String receivedPath) async {
    throw StateError('diff failed');
  }

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    throw StateError('diff failed');
  }
}

final class _RecordingDiffTool implements ReviewDiffTool {
  final openedPaths = <String>[];

  @override
  String get commandDescription => 'recording diff';

  @override
  bool get isAvailable => true;

  @override
  Future<void> open(String receivedPath) async {
    openedPaths.add(receivedPath);
  }

  @override
  Future<void> report(String approvedPath, String receivedPath) async {}
}

final class _UnavailableDiffTool implements ReviewDiffTool {
  const _UnavailableDiffTool();

  @override
  String get commandDescription => 'unavailable diff';

  @override
  bool get isAvailable => false;

  @override
  Future<void> open(String receivedPath) async {}

  @override
  Future<void> report(String approvedPath, String receivedPath) async {}
}
