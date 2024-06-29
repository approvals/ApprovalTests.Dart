// ignore_for_file: avoid_print

import 'dart:io';

import 'package:approval_tests_flutter/src/common.dart';

void printGitDiffs(String testDescription, String differences) {
  print(topBar);
  print("Results of git diff during approvalTest('$testDescription'):");
  print(differences.trim());
  print(bottomBar);
}

/// return the diff of two files
String gitDiffFiles(File path0, FileSystemEntity path1) {
  final processResult = Process.runSync('git', ['diff', '--no-index', path0.path, path1.path]);

  final stdoutString = processResult.stdout as String;
  final stderrString = processResult.stderr as String;

  final processString = stdoutString.isNotEmpty || stderrString.isNotEmpty ? stdoutString : '';

  return _stripGitDiff(processString);
}

/// Format the git --diff if superfluous text
String _stripGitDiff(String multiLineString) {
  bool startsWithAny(String line, List<String> prefixes) => prefixes.any((prefix) => line.startsWith(prefix));

  final List<String> lines = multiLineString.split('\n');
  final List<String> filteredLines = lines.where((line) => !startsWithAny(line, ['diff', 'index', '@@'])).toList();

  final String result = filteredLines.join('\n');

  return result;
}
