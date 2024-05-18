part of '../../approval_tests.dart';

class FileNotFoundException implements Exception {
  final String message;

  final StackTrace? stackTrace;

  FileNotFoundException({
    required this.message,
    this.stackTrace,
  });
}
