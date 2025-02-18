import 'dart:io';

import 'package:approval_tests/approval_tests.dart';

void main(List<String> args) async {
  final List<Future<void>> tasks = [];
  bool isProcessingTasks = false;

  void processUnapprovedFile(File receivedFile) {
    if (!receivedFile.existsSync()) {
      ApprovalLogger.exception(
        'Error: the file below does not exist for review comparison:',
      );
      ApprovalLogger.exception(receivedFile.path);
      return;
    }

    final approvedFileName =
        receivedFile.path.replaceAll('.received.txt', '.approved.txt');
    final approvedFile = File(approvedFileName);

    if (approvedFile.existsSync()) {
      tasks.add(processFile(approvedFile, receivedFile));
    } else {
      tasks.add(processFile(null, receivedFile));
    }
  }

  Future<List<File>> getUnapprovedFiles() async {
    final files = <File>[];
    final searchDirectory = Directory.current;

    await for (final file in searchDirectory.list(recursive: true)) {
      if (file.path.endsWith('.received.txt')) {
        files.add(file as File);
      }
    }

    return files;
  }

  /// If no args, then searching the whole project
  if (args.isEmpty || args[0].isEmpty) {
    for (final file in await getUnapprovedFiles()) {
      if (file.path.endsWith('.received.txt')) {
        isProcessingTasks = true;
        processUnapprovedFile(file);
      }
    }
  } else {
    /// If here, have args. If arg is an option...
    if (args[0][0] == '-') {
      if (args[0] == '--help') {
        ApprovalLogger.log('''
Manage your package:approval_tests files.

Common usage:

  dart run approval_tests:review 
    Reviews all project .received.txt files

  dart run approval_tests:review --list
    List project's .received.txt files

Usage: dart run approval_tests:review [arguments]

Arguments:
--help                      Print this usage information.
--list                      Print a list of project .received.txt files.
<index>                     Review an .received.txt file indexed by --list.
<path/to/.received.txt>   Review an .received.txt file.''');
      } else if (args[0] == '--list') {
        final unapprovedFiles = await getUnapprovedFiles();
        final fileCount = unapprovedFiles.length;
        for (int i = 0; i < fileCount; i++) {
          ApprovalLogger.log(
            '${i.toString().padLeft(3)} ${unapprovedFiles[i].path}',
          );
        }
        ApprovalLogger.log('Found $fileCount received files.');
        if (fileCount > 0) {
          ApprovalLogger.log(
            "\nTo review one, run: dart run approval_tests:review <index>\nTo review all, run: dart run approval_tests:review",
          );
        }

        writeUnapprovedFiles(unapprovedFiles);
      } else {
        ApprovalLogger.log(
          "Unknown option '${args[0]}'. See '--help' for more details.",
        );
      }
    } else {
      /// If here, arg is a path or an index in the list of paths
      File? unapprovedFile;
      final arg = args[0];
      final int? maybeIntValue = int.tryParse(arg);
      if (maybeIntValue == null) {
        unapprovedFile = File(arg);
      } else {
        final unapprovedFilePaths = readReceivedFiles();
        if (maybeIntValue >= 0 && maybeIntValue < unapprovedFilePaths.length) {
          unapprovedFile = File(unapprovedFilePaths[maybeIntValue]);
        } else {
          ApprovalLogger.log(
            'No received file with an index of $maybeIntValue',
          );
        }
      }
      if (unapprovedFile != null) {
        isProcessingTasks = true;
        processUnapprovedFile(unapprovedFile);
      }
    }
  }

  if (isProcessingTasks) {
    if (tasks.isEmpty) {
      ApprovalLogger.exception('No received test results to review!');
    } else {
      final tasksCount = tasks.length;
      await Future.wait(tasks);
      ApprovalLogger.success(
        'Review completed. $tasksCount test results reviewed.',
      );
    }
  }
}

void writeUnapprovedFiles(List<File>? unapprovedFiles) {
  final file = File(ApprovalTestsConstants.receivedFilesPath)
    ..createSync(recursive: true);
  if (unapprovedFiles == null) {
    file.writeAsStringSync('');
  } else {
    file.writeAsStringSync(unapprovedFiles.map((file) => file.path).join('\n'));
  }
}

List<String> readReceivedFiles() {
  List<String> result = <String>[];

  final file = File(ApprovalTestsConstants.receivedFilesPath);
  if (file.existsSync()) {
    final String fileContents = file.readAsStringSync();
    result = fileContents.split('\n');
  } else {
    result = [];
  }

  return result;
}

/// Check of the files are different using "git diff"
Future<void> processFile(File? approvedFile, File receivedFile) async {
  late String resultString;
  ComparatorIDE comparatorIDE = ComparatorIDE.vsCode;

  if (approvedFile == null) {
    final unapprovedText = receivedFile.readAsStringSync();
    resultString = "Data in '${receivedFile.path}':\n$unapprovedText";
  } else {
    final gitDiff = GitReporter.gitDiffFiles(approvedFile, receivedFile);
    resultString = gitDiff;
  }

  if (resultString.isNotEmpty) {
    GitReporter.printGitDiffs(receivedFile.path, resultString, showTip: false);

    String? firstCharacter;

    do {
      stdout.write('Accept changes? (y/N/[v]iew): ');
      final response = stdin.readLineSync()?.trim().toLowerCase();

      firstCharacter = null;
      if (response != null && response.isNotEmpty) {
        firstCharacter = response[0];
      }

      final receivedFilename = receivedFile.path;
      final approvedFilename = receivedFile.path
          .replaceAll(Namer.receivedExtension, Namer.approvedExtension);

      if (firstCharacter == 'y') {
        await approvedFile?.delete();
        await receivedFile.rename(approvedFilename);
        ApprovalLogger.success('Approval test approved');
      } else if (firstCharacter == 'v') {
        stdout.write('Enter diff tool (code, studio): ');
        final diffTool = stdin.readLineSync()?.trim().toLowerCase();
        if (diffTool == 'code') {
          comparatorIDE = ComparatorIDE.vsCode;
        } else if (diffTool == 'studio') {
          comparatorIDE = ComparatorIDE.studio;
        }
        final diffReporter = DiffReporter(ide: comparatorIDE);
        if (diffReporter.isReporterAvailable) {
          final approvedFilename = approvedFile?.path;

          ApprovalLogger.log(
            "Executing '${diffReporter.defaultDiffInfo.command} ${diffReporter.defaultDiffInfo.arg} $approvedFilename $receivedFilename'",
          );
          if (approvedFilename != null) {
            await diffReporter.report(approvedFilename, receivedFilename);
          } else {
            final processResult = Process.runSync('code', [receivedFilename]);
            ApprovalLogger.log(
              '______processResult: ${processResult.toString()}',
            );
          }
        } else {
          ApprovalLogger.warning(
            'No diff tool available: please check:\nName: ${diffReporter.defaultDiffInfo.name}\nPath:${diffReporter.defaultDiffInfo.command}',
          );
        }
      } else {
        ApprovalLogger.exception('Approval test rejected');
      }
    } while (firstCharacter == 'v');
  } else {
    ApprovalLogger.success('No differences found. Approval test approved.');
  }
}

bool isCodeCommandAvailable() {
  final result = Process.runSync('which', ['code']);

  return result.exitCode == 0;
}
