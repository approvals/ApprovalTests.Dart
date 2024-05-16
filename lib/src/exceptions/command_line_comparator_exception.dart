part of '../../approval_tests.dart';

/// Exception thrown when an error occurs during comparison via Command Line.
final class CommandLineComparatorException implements Exception {
  final String message;
  final Object? exception;
  final StackTrace? stackTrace;

  const CommandLineComparatorException({
    required this.message,
    required this.exception,
    required this.stackTrace,
  });
}
