part of '../../approval_tests.dart';

/// `GitReporter` is a class for reporting the comparison results using the git.
class GitReporter implements Reporter {
  final DiffInfo? customDiffInfo;

  static Future<ProcessResult> Function(
          String command, List<String> arguments)
      runProcess = _defaultRunProcess;
  static ProcessResult Function(String command, List<String> arguments)
      runProcessSync = _defaultRunProcessSync;

  const GitReporter({
    this.customDiffInfo,
  });

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    final DiffInfo diffInfo = customDiffInfo ??
        const DiffInfo(name: "Git", command: 'git', arg: 'diff --no-index');

    try {
      await Future.wait([
        _checkFileExists(approvedPath),
        _checkFileExists(receivedPath),
      ]);

      final args = _expandArgs(diffInfo.arg)
        ..addAll([approvedPath, receivedPath]);
      final result = await runProcess(
        diffInfo.command,
        args,
      );

      if (result.exitCode > 1) {
        throw ProcessException(
          diffInfo.command,
          args,
          result.stderr,
          result.exitCode,
        );
      }
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
    final args = ['diff', '--no-index', path0.path, path1.path];
    final processResult = runProcessSync('git', args);

    if (processResult.exitCode > 1) {
      throw ProcessException(
        'git',
        args,
        processResult.stderr,
        processResult.exitCode,
      );
    }

    final stdoutString = processResult.stdout as String? ?? '';
    final stderrString = processResult.stderr as String? ?? '';

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

  // static void printGitDiffs(String testDescription, String differences) {
  //   ApprovalLogger.log(
  //     "Results of git diff during approvalTest('$testDescription'):",
  //   );
  //   ApprovalLogger.log(differences.trim());
  // }

  static void printGitDiffs(
    String unapprovedFullPath,
    String differences, {
    bool showTip = true,
  }) {
    ApprovalLogger.log("Results of git diff:\n${differences.trim()}");
    if (showTip) {
      ApprovalLogger.log(
        "To review, run: dart run approved:review '$unapprovedFullPath'",
      );
      ApprovalLogger.log("To review all, run: dart run approved:review");
    }
  }

  static List<String> _expandArgs(String arg) {
    final trimmed = arg.trim();
    if (trimmed.isEmpty) {
      return <String>[];
    }
    return trimmed.split(RegExp(r'\s+'));
  }

  static Future<ProcessResult> _defaultRunProcess(
    String command,
    List<String> arguments,
  ) =>
      Process.run(command, arguments);

  static ProcessResult _defaultRunProcessSync(
    String command,
    List<String> arguments,
  ) =>
      Process.runSync(command, arguments);

  static void resetProcessRunners() {
    runProcess = _defaultRunProcess;
    runProcessSync = _defaultRunProcessSync;
  }
}
