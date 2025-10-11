import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

void main() => registerGitReporterTests();

void registerGitReporterTests() {
  group('GitReporter behavior', () {
    setUp(() {
      GitReporter.resetProcessRunners();
    });

    tearDown(GitReporter.resetProcessRunners);

    test('report throws ProcessException when process exit code > 1', () {
      final tempDir =
          Directory.systemTemp.createTempSync('git_reporter_failure');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final approved = File('${tempDir.path}/approved.txt')
        ..writeAsStringSync('approved');
      final received = File('${tempDir.path}/received.txt')
        ..writeAsStringSync('received');

      GitReporter.runProcessSync = (command, arguments) {
        return ProcessResult(0, 2, '', 'error');
      };

      final reporter = GitReporter(
        customDiffInfo: const DiffInfo(
          name: 'custom',
          command: 'git',
          arg: '--flag',
        ),
      );

      expect(
        () => reporter.report(approved.path, received.path),
        throwsA(isA<ProcessException>()),
      );
    });

    test('printGitDiffs logs tip when showTip true', () {
      GitReporter.printGitDiffs('path/to/file', 'diff output', showTip: true);
      GitReporter.printGitDiffs('path/to/file', 'diff output', showTip: false);
    });

    test('gitDiffFiles throws ProcessException for failing command sync', () {
      GitReporter.runProcessSync = (command, arguments) {
        return ProcessResult(0, 5, '', 'error');
      };

      expect(
        () => GitReporter.gitDiffFiles(
          File('/path/approved'),
          File('/path/received'),
        ),
        throwsA(isA<ProcessException>()),
      );
    });

    test('report handles empty arg expansion', () {
      final tempDir =
          Directory.systemTemp.createTempSync('git_reporter_empty_args');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final approved = File('${tempDir.path}/approved.txt')
        ..writeAsStringSync('approved');
      final received = File('${tempDir.path}/received.txt')
        ..writeAsStringSync('received');

      final captured = <List<String>>[];
      GitReporter.runProcessSync = (command, arguments) {
        captured.add(arguments);
        return ProcessResult(0, 0, '', '');
      };

      final reporter = GitReporter(
        customDiffInfo: const DiffInfo(
          name: 'capture',
          command: 'git',
          arg: '   ',
        ),
      );

      reporter.report(approved.path, received.path);

      expect(captured.single, equals([approved.path, received.path]));
    });
  });
}
