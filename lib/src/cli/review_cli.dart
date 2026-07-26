import 'dart:io';

import 'package:approval_tests/approval_tests.dart';
import 'package:path/path.dart' as path;

enum ReviewMessageLevel { info, success, warning, error }

abstract interface class ReviewConsole {
  String? readLine();

  void write(String message);

  void log(ReviewMessageLevel level, String message);
}

final class SystemReviewConsole implements ReviewConsole {
  const SystemReviewConsole();

  @override
  String? readLine() => stdin.readLineSync();

  @override
  void write(String message) => stdout.write(message);

  @override
  void log(ReviewMessageLevel level, String message) {
    switch (level) {
      case ReviewMessageLevel.info:
        ApprovalLogger.log(message);
      case ReviewMessageLevel.success:
        ApprovalLogger.success(message);
      case ReviewMessageLevel.warning:
        ApprovalLogger.warning(message);
      case ReviewMessageLevel.error:
        ApprovalLogger.exception(message);
    }
  }
}

abstract interface class ReviewDiffTool {
  bool get isAvailable;

  String get commandDescription;

  Future<void> report(String approvedPath, String receivedPath);

  Future<void> open(String receivedPath);
}

final class DiffReporterReviewTool implements ReviewDiffTool {
  DiffReporterReviewTool(this.reporter);

  final DiffReporter reporter;

  @override
  bool get isAvailable => reporter.isAvailable;

  @override
  String get commandDescription {
    final diffInfo = reporter.defaultDiffInfo;
    return '${diffInfo.command} ${diffInfo.arg}'.trim();
  }

  @override
  Future<void> report(String approvedPath, String receivedPath) =>
      reporter.report(approvedPath, receivedPath);

  @override
  Future<void> open(String receivedPath) async {
    final diffInfo = reporter.defaultDiffInfo;
    final result = await Process.run(diffInfo.command, [receivedPath]);
    if (result.exitCode != 0) {
      throw ProcessException(
        diffInfo.command,
        [receivedPath],
        result.stderr.toString(),
        result.exitCode,
      );
    }
  }
}

typedef ReviewDiffFiles = String Function(File approvedFile, File receivedFile);
typedef ReviewDiffToolFactory = ReviewDiffTool Function(ComparatorIDE ide);

final class ReviewCli {
  static const _receivedSuffix = '.${BaseNamer.receivedExtension}';
  static const _approvedSuffix = '.${BaseNamer.approvedExtension}';

  ReviewCli({
    Directory? workingDirectory,
    this.console = const SystemReviewConsole(),
    File? receivedFilesIndex,
    ReviewDiffFiles? diffFiles,
    ReviewDiffToolFactory? diffToolFactory,
  })  : workingDirectory = workingDirectory ?? Directory.current,
        receivedFilesIndex = receivedFilesIndex ??
            File(
              path.join(
                (workingDirectory ?? Directory.current).path,
                ApprovalTestsConstants.receivedFilesPath,
              ),
            ),
        _diffFiles = diffFiles ?? _defaultDiffFiles,
        _diffToolFactory = diffToolFactory ?? _defaultDiffToolFactory;

  final Directory workingDirectory;
  final File receivedFilesIndex;
  final ReviewConsole console;
  final ReviewDiffFiles _diffFiles;
  final ReviewDiffToolFactory _diffToolFactory;

  Future<void> run(List<String> arguments) async {
    if (arguments.isEmpty || arguments.first.isEmpty) {
      await _reviewReceivedFiles(await findReceivedFiles());
      return;
    }

    final argument = arguments.first;
    if (argument.startsWith('-')) {
      await _runOption(argument);
      return;
    }

    final index = int.tryParse(argument);
    if (index == null) {
      await _reviewReceivedFiles([_fileFromArgument(argument)]);
      return;
    }

    final receivedPaths = await readReceivedFiles();
    if (index < 0 || index >= receivedPaths.length) {
      console.log(
        ReviewMessageLevel.error,
        'No received file with an index of $index',
      );
      return;
    }
    await _reviewReceivedFiles([File(receivedPaths[index])]);
  }

  Future<List<File>> findReceivedFiles() async {
    final files = <File>[];

    await for (final entity in workingDirectory.list(recursive: true)) {
      if (entity is File &&
          path.basename(entity.path).endsWith(_receivedSuffix)) {
        files.add(entity);
      }
    }

    files.sort(
      (left, right) => _normalizedRelativePath(left)
          .compareTo(_normalizedRelativePath(right)),
    );
    return files;
  }

  File approvedFileFor(File receivedFile) {
    final receivedPath = receivedFile.path;
    if (!path.basename(receivedPath).endsWith(_receivedSuffix)) {
      throw ArgumentError.value(
        receivedPath,
        'receivedFile',
        'Expected a $_receivedSuffix artifact',
      );
    }

    final basePath = receivedPath.substring(
      0,
      receivedPath.length - _receivedSuffix.length,
    );
    return File('$basePath$_approvedSuffix');
  }

  Future<void> reviewFiles(
    Iterable<File> receivedFiles,
    Future<void> Function(File receivedFile) review,
  ) async {
    for (final receivedFile in receivedFiles) {
      await review(receivedFile);
    }
  }

  Future<bool> reviewFile(File receivedFile) async {
    if (!await receivedFile.exists()) {
      console.log(
        ReviewMessageLevel.error,
        'File does not exist: ${receivedFile.path}',
      );
      return false;
    }

    late final File approvedFile;
    try {
      approvedFile = approvedFileFor(receivedFile);
    } on ArgumentError catch (error) {
      console.log(ReviewMessageLevel.error, error.message.toString());
      return false;
    }

    final approvedExists = await approvedFile.exists();
    final difference = approvedExists
        ? _diffFiles(approvedFile, receivedFile)
        : "Data in '${receivedFile.path}':\n"
            '${await receivedFile.readAsString()}';

    if (difference.isEmpty) {
      console.log(
        ReviewMessageLevel.success,
        'No differences found. Approval test approved.',
      );
      return true;
    }

    console.log(
      ReviewMessageLevel.info,
      'Results of git diff:\n${difference.trim()}',
    );

    String? choice;
    do {
      console.write('Accept changes? (y/N/[v]iew): ');
      choice = _firstCharacter(console.readLine());

      if (choice == 'y') {
        if (approvedExists) {
          await approvedFile.delete();
        }
        await receivedFile.rename(approvedFile.path);
        console.log(
          ReviewMessageLevel.success,
          'Approval test approved',
        );
      } else if (choice == 'v') {
        await _showDifference(
          approvedFile: approvedExists ? approvedFile : null,
          receivedFile: receivedFile,
        );
      } else {
        console.log(
          ReviewMessageLevel.error,
          'Approval test rejected',
        );
      }
    } while (choice == 'v');
    return true;
  }

  Future<void> _runOption(String option) async {
    if (option == '--help') {
      console.log(ReviewMessageLevel.info, _help);
      return;
    }
    if (option == '--list') {
      final receivedFiles = await findReceivedFiles();
      for (var index = 0; index < receivedFiles.length; index++) {
        console.log(
          ReviewMessageLevel.info,
          '${index.toString().padLeft(3)} ${receivedFiles[index].path}',
        );
      }
      console.log(
        ReviewMessageLevel.info,
        'Found ${receivedFiles.length} received files.',
      );
      if (receivedFiles.isNotEmpty) {
        console.log(
          ReviewMessageLevel.info,
          '\nTo review one, run: dart run approval_tests:review <index>'
          '\nTo review all, run: dart run approval_tests:review',
        );
      }
      await writeReceivedFiles(receivedFiles);
      return;
    }

    console.log(
      ReviewMessageLevel.error,
      "Unknown option '$option'. See '--help' for more details.",
    );
  }

  Future<void> _reviewReceivedFiles(Iterable<File> receivedFiles) async {
    final files = List<File>.of(receivedFiles);
    if (files.isEmpty) {
      console.log(
        ReviewMessageLevel.error,
        'No received test results to review!',
      );
      return;
    }

    var reviewedCount = 0;
    await reviewFiles(files, (receivedFile) async {
      if (await reviewFile(receivedFile)) {
        reviewedCount++;
      }
    });
    if (reviewedCount > 0) {
      console.log(
        ReviewMessageLevel.success,
        'Review completed. $reviewedCount test results reviewed.',
      );
    }
  }

  Future<void> writeReceivedFiles(List<File> receivedFiles) async {
    await receivedFilesIndex.parent.create(recursive: true);
    await receivedFilesIndex.writeAsString(
      receivedFiles.map((file) => file.path).join('\n'),
    );
  }

  Future<List<String>> readReceivedFiles() async {
    if (!await receivedFilesIndex.exists()) {
      return const [];
    }

    return (await receivedFilesIndex.readAsString())
        .split('\n')
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  File _fileFromArgument(String argument) {
    if (path.isAbsolute(argument)) {
      return File(argument);
    }
    return File(path.join(workingDirectory.path, argument));
  }

  Future<void> _showDifference({
    required File? approvedFile,
    required File receivedFile,
  }) async {
    console.write('Enter diff tool (code, studio): ');
    final toolName = console.readLine()?.trim().toLowerCase();
    final ide =
        toolName == 'studio' ? ComparatorIDE.studio : ComparatorIDE.vsCode;
    final diffTool = _diffToolFactory(ide);

    if (!diffTool.isAvailable) {
      console.log(
        ReviewMessageLevel.warning,
        'No diff tool available: ${diffTool.commandDescription}',
      );
      return;
    }

    console.log(
      ReviewMessageLevel.info,
      "Executing '${diffTool.commandDescription}'",
    );
    if (approvedFile == null) {
      await diffTool.open(receivedFile.path);
    } else {
      await diffTool.report(approvedFile.path, receivedFile.path);
    }
  }

  String? _firstCharacter(String? input) {
    final normalized = input?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized[0];
  }

  String _normalizedRelativePath(File file) {
    final relativePath = path.relative(
      file.path,
      from: workingDirectory.path,
    );
    return path.posix.joinAll(path.split(path.normalize(relativePath)));
  }
}

String _defaultDiffFiles(File approvedFile, File receivedFile) =>
    const GitReporter().gitDiffFiles(approvedFile, receivedFile);

ReviewDiffTool _defaultDiffToolFactory(ComparatorIDE ide) =>
    DiffReporterReviewTool(DiffReporter(ide: ide));

const _help = '''
Manage your package:approval_tests files.

Common usage:

  dart run approval_tests:review
    Reviews all project .received.txt files

  dart run approval_tests:review --list
    List project's .received.txt files

Usage: dart run approval_tests:review [arguments]

Arguments:
--help                    Print this usage information.
--list                    Print a list of project .received.txt files.
<index>                   Review a .received.txt file indexed by --list.
<path/to/.received.txt>   Review a .received.txt file.''';
