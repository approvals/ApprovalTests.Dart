part of '../../../approval_tests.dart';

/// `ComparatorIDE` is an enum for comparing files using an `IDE`.
enum ComparatorIDE {
  visualStudioCode('/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code', 'Visual Studio Code', '-d'),
  androidStudio('/Applications/Android Studio.app/Contents/MacOS/studio', 'Android Studio', 'diff');

  final String command;
  final String name;
  final String argument;

  const ComparatorIDE(this.command, this.name, this.argument);
}
