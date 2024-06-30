// ignore_for_file: avoid_print

import 'dart:io';

import 'package:approval_tests/approval_tests.dart';

void main() async {
  final searchDirectory = Directory.current;

  final List<Future<void>> tasks = [];

  /// Recursively search for current files
  await for (final file in searchDirectory.list(recursive: true)) {
    if (file.path.endsWith('.received.txt')) {
      final reviewFile = file;
      final approvedFileName =
          file.path.replaceAll('.received.txt', '.approved.txt');
      final approvedFile = File(approvedFileName);

      if (approvedFile.existsSync()) {
        tasks.add(processFile(approvedFile, reviewFile));
      }
    }
  }

  await Future.wait(tasks);

  ApprovalLogger.success(
    'Review process completed: ${tasks.length} files reviewed.',
  );
}

/// Check of the files are different using "git diff"
Future<void> processFile(File approvedFile, FileSystemEntity reviewFile) async {
  final resultString = GitReporter.gitDiffFiles(approvedFile, reviewFile);

  ComparatorIDE comparatorIDE = ComparatorIDE.vsCode;

  if (resultString.isNotEmpty || resultString.isNotEmpty) {
    // final String fileNameWithoutExtension =
    //     approvedFile.path.split('/').last.split('.').first;
    // GitReporter.printGitDiffs(fileNameWithoutExtension, resultString);
    const CommandLineReporter().report(approvedFile.path, reviewFile.path);

    String? firstCharacter;

    do {
      stdout.write('Accept changes? (y/N/[v]iew): ');
      final response = stdin.readLineSync()?.trim().toLowerCase();

      if (response == null || response.isEmpty) {
        firstCharacter = null;
      } else {
        firstCharacter = response[0];
      }

      if (firstCharacter == 'y') {
        await approvedFile.delete();
        await reviewFile.rename(approvedFile.path);
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
          final approvedFilename = approvedFile.path;
          final reviewFilename = reviewFile.path;
          ApprovalLogger.log(
            "Executing '${diffReporter.defaultDiffInfo.command} ${diffReporter.defaultDiffInfo.arg} $approvedFilename $reviewFilename'",
          );
          await diffReporter.report(approvedFilename, reviewFilename);
        } else {
          ApprovalLogger.warning(
            'No diff tool available: please check:\nName: ${diffReporter.defaultDiffInfo.name}\nPath:${diffReporter.defaultDiffInfo.command}',
          );
        }
      } else {
        ApprovalLogger.exception('Approval test rejected');
      }
    } while (firstCharacter == 'v');
  }
}
