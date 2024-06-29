part of '../../approval_tests.dart';

/// `GitReporter` is a class for reporting the comparison results using the git.
class GitReporter implements Reporter {
  const GitReporter();

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    const DiffInfo diffInfo =
        DiffInfo(name: "Git", command: 'git', arg: 'diff --no-index');

    try {
      await Future.wait([
        _checkFileExists(approvedPath),
        _checkFileExists(receivedPath),
      ]);

      await Process.run(
        diffInfo.command,
        [diffInfo.arg, approvedPath, receivedPath],
      );
    } catch (e, st) {
      if (e is PathNotFoundException) {
        ApprovalLogger.exception(e, stackTrace: st);
        rethrow;
      }
      if (e is ProcessException) {
        final ProcessResult result =
            await Process.run(ApprovalUtils.commandWhere, [diffInfo.command]);
        ApprovalLogger.exception(
          'Error during comparison via Git. Please make sure that Git is installed and available in the system path. Error: ${e.message}. Git path: ${result.stdout}',
          stackTrace: st,
        );
      }
      rethrow;
    }
  }

  Future<void> _checkFileExists(String path) async {
    if (!ApprovalUtils.isFileExists(path)) {
      throw PathNotFoundException(
        path,
        const OSError('File not found'),
        'From GitReporter: File not found at path: [$path]. Please check the path and try again.',
      );
    }
  }

  /// return the diff of two files
  static String gitDiffFiles(File path0, FileSystemEntity path1) {
    final processResult =
        Process.runSync('git', ['diff', '--no-index', path0.path, path1.path]);

    final stdoutString = processResult.stdout as String;
    final stderrString = processResult.stderr as String;

    final processString =
        stdoutString.isNotEmpty || stderrString.isNotEmpty ? stdoutString : '';

    return _stripGitDiff(processString);
  }

  static String _stripGitDiff(String multiLineString) {
    bool startsWithAny(String line, List<String> prefixes) =>
        prefixes.any((prefix) => line.startsWith(prefix));

    final List<String> lines = multiLineString.split('\n');
    final List<String> filteredLines = lines
        .where((line) => !startsWithAny(line, ['diff', 'index', '@@']))
        .toList();

    final String result = filteredLines.join('\n');

    return result;
  }

  static void printGitDiffs(String testDescription, String differences) {
    ApprovalLogger.log(
      "Results of git diff during approvalTest('$testDescription'):",
    );
    ApprovalLogger.log(differences.trim());
  }
}
