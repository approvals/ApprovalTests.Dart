part of '../../approval_tests.dart';

/// `NoDiffToolException` is thrown when a diff tool is not found.
class NoDiffToolException implements Exception {
  final String message;

  final StackTrace? stackTrace;

  NoDiffToolException({
    required this.message,
    this.stackTrace,
  });
}
