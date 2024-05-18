part of '../../../../approval_tests.dart';

/// `DiffInfo` is a class for storing information about a diff tool.
class DiffInfo {
  final String command;
  final String arg;
  final String name;

  const DiffInfo({
    required this.command,
    required this.arg,
    required this.name,
  });
}
