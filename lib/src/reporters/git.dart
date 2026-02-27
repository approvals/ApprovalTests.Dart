part of '../../approval_tests.dart';

/// `GitReporter` is a class for reporting the comparison results using the git.
class GitReporter implements Reporter {
  final DiffInfo? customDiffInfo;

  /// Process runner for async operations. Injected for testability.
  final Future<ProcessResult> Function(String command, List<String> arguments)
      _runProcess;

  /// Process runner for sync operations. Injected for testability.
  final ProcessResult Function(String command, List<String> arguments)
      _runProcessSync;

  const GitReporter({
    this.customDiffInfo,
    Future<ProcessResult> Function(String command, List<String> arguments)
        runProcess = _defaultRunProcess,
    ProcessResult Function(String command, List<String> arguments)
        runProcessSync = _defaultRunProcessSync,
  })  : _runProcess = runProcess,
        _runProcessSync = runProcessSync;

  @override
  Future<void> report(String approvedPath, String receivedPath) async {
    final DiffInfo diffInfo = customDiffInfo ??
        const DiffInfo(name: "Git", command: 'git', arg: 'diff --no-index');

    try {
      final args = ApprovalUtils.buildDiffArgs(
        approvedPath: approvedPath,
        receivedPath: receivedPath,
        diffInfo: diffInfo,
        context: 'GitReporter',
      );
      final result = await _runProcess(
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
        await ApprovalUtils.logCommandDiagnostics(
          command: diffInfo.command,
          messageBuilder: (commandPath) =>
              'Error during comparison via Git. Please make sure that Git is installed and available in the system path. Error: ${e.message}. Git path: $commandPath',
          stackTrace: st,
        );
      }
      rethrow;
    }
  }

  /// Returns the diff of two files.
  String gitDiffFiles(File path0, FileSystemEntity path1) {
    final args = ['diff', '--no-index', path0.path, path1.path];
    final processResult = _runProcessSync('git', args);

    if (processResult.exitCode > 1) {
      throw ProcessException(
        'git',
        args,
        processResult.stderr,
        processResult.exitCode,
      );
    }

    final processString = processResult.stdout as String? ?? '';

    return _stripGitDiff(processString);
  }

  static const _stripPrefixes = ['diff', 'index', '@@'];

  static String _stripGitDiff(String multiLineString) {
    return multiLineString
        .split('\n')
        .where(
            (line) => !_stripPrefixes.any((prefix) => line.startsWith(prefix)))
        .join('\n');
  }

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
}
