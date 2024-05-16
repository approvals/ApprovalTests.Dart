part of '../../../approval_tests.dart';

/// `DiffInfo` is a class for storing information about a diff tool.
class DiffInfo {
  final String command;
  final List<String> args;
  final List<String> supportedExtensions;

  const DiffInfo({
    required this.command,
    required this.args,
    required this.supportedExtensions,
  });
}
