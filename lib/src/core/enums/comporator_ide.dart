part of '../../../approval_tests.dart';

/// `ComparatorIDE` is an enum for comparing files using an `IDE`.
enum ComparatorIDE {
  visualStudioCode('code', 'Visual Studio Code', '--diff'),
  intelliJ('idea', 'IntelliJ IDEA', 'diff'),
  androidStudio('studio', 'Android Studio', 'diff'),
  ;

  final String command;
  final String name;
  final String argument;

  const ComparatorIDE(this.command, this.name, this.argument);
}
