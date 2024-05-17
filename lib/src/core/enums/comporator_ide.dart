part of '../../../approval_tests.dart';

enum ComparatorIDE {
  /// `ComparatorIDE` for `VS Code`.
  vsCode("Visual Studio Code"),

  /// `ComparatorIDE` for `Android Studio`.
  studio("Android Studio");

  final String name;

  const ComparatorIDE(this.name);
}
