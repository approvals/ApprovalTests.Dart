import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() {
  group('GitReporter custom command handling', () {
    test('reports successfully with expanded arguments', () async {
      final tempDir =
          Directory.systemTemp.createTempSync('git_reporter_success');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final approved = File('${tempDir.path}/approved.txt')
        ..writeAsStringSync('approved');
      final received = File('${tempDir.path}/received.txt')
        ..writeAsStringSync('received');
      final logFile = File('${tempDir.path}/git_args.log');

      final scriptPath = _writeArgumentCaptureScript(
        directory: tempDir,
        fileName: 'git_capture.dart',
      );

      final reporter = GitReporter(
        customDiffInfo: DiffInfo(
          name: 'capture',
          command: Platform.resolvedExecutable,
          arg: '$scriptPath --output ${logFile.path}',
        ),
      );

      await reporter.report(approved.path, received.path);

      final lines = logFile.readAsLinesSync();
      expect(lines.contains(approved.path), isTrue);
      expect(lines.contains(received.path), isTrue);
    });

    test('throws ProcessException when command exits with code > 1', () async {
      final tempDir = Directory.systemTemp.createTempSync('git_reporter_fail');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final approved = File('${tempDir.path}/approved.txt')
        ..writeAsStringSync('approved');
      final received = File('${tempDir.path}/received.txt')
        ..writeAsStringSync('received');

      final failingScript = _writeExitScript(
        directory: tempDir,
        fileName: 'git_exit.dart',
        exitCode: 2,
      );

      final reporter = GitReporter(
        customDiffInfo: DiffInfo(
          name: 'fail',
          command: Platform.resolvedExecutable,
          arg: failingScript,
        ),
      );

      await expectLater(
        reporter.report(approved.path, received.path),
        throwsA(isA<ProcessException>()),
      );
    });

    test('gitDiffFiles returns diff output when files differ', () {
      final tempDir =
          Directory.systemTemp.createTempSync('git_reporter_diff_files');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final approved = File('${tempDir.path}/approved.txt')
        ..writeAsStringSync('hello');
      final received = File('${tempDir.path}/received.txt')
        ..writeAsStringSync('hello world');

      final diffOutput = GitReporter.gitDiffFiles(approved, received);

      expect(diffOutput.contains('-hello'), isTrue);
      expect(diffOutput.contains('+hello world'), isTrue);
    });
  });

  group('DiffReporter custom command handling', () {
    test('reports successfully with expanded arguments', () async {
      final tempDir =
          Directory.systemTemp.createTempSync('diff_reporter_success');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final approved = File('${tempDir.path}/approved.txt')
        ..writeAsStringSync('approved');
      final received = File('${tempDir.path}/received.txt')
        ..writeAsStringSync('received');
      final logFile = File('${tempDir.path}/diff_args.log');

      final scriptPath = _writeArgumentCaptureScript(
        directory: tempDir,
        fileName: 'diff_capture.dart',
      );

      final reporter = DiffReporter(
        customDiffInfo: DiffInfo(
          name: 'capture',
          command: Platform.resolvedExecutable,
          arg: '$scriptPath --output ${logFile.path}',
        ),
      );

      await reporter.report(approved.path, received.path);

      final lines = logFile.readAsLinesSync();
      expect(lines.first, equals(approved.path));
      expect(lines.last, equals(received.path));
    });

    test('isReporterAvailable returns true for custom command file', () {
      final tempDir =
          Directory.systemTemp.createTempSync('diff_reporter_available');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final scriptPath = _writeArgumentCaptureScript(
        directory: tempDir,
        fileName: 'diff_available.dart',
      );

      final reporter = DiffReporter(
        customDiffInfo: DiffInfo(
          name: 'available',
          command: scriptPath,
          arg: '',
        ),
      );

      expect(reporter.isReporterAvailable, isTrue);
    });
  });
}

String _writeArgumentCaptureScript({
  required Directory directory,
  required String fileName,
}) {
  final script = File('${directory.path}/$fileName')
    ..writeAsStringSync(
      '''
import 'dart:io';

void main(List<String> args) {
  final outputIndex = args.indexOf('--output');
  if (outputIndex == -1 || outputIndex + 1 >= args.length) {
    stderr.writeln('Missing --output argument');
    exit(2);
  }
  final outputPath = args[outputIndex + 1];
  final filtered = <String>[];
  for (var i = 0; i < args.length; i++) {
    if (i == outputIndex || i == outputIndex + 1) {
      continue;
    }
    filtered.add(args[i]);
  }
  File(outputPath).writeAsStringSync(filtered.join('\\n'));
}
''',
    );
  return script.path;
}

String _writeExitScript({
  required Directory directory,
  required String fileName,
  required int exitCode,
}) {
  final script = File('${directory.path}/$fileName')
    ..writeAsStringSync(
      '''
import 'dart:io';

void main(List<String> args) {
  stderr.writeln('Intentional exit code $exitCode');
  exit($exitCode);
}
''',
    );
  return script.path;
}
