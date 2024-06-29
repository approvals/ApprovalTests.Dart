part of '../../approval_tests.dart';

/// `FileNotFoundException` is thrown when a file is not found.
class FileNotFoundException implements Exception {
  final String message;

  final StackTrace? stackTrace;

  FileNotFoundException({
    required this.message,
    this.stackTrace,
  });
}
