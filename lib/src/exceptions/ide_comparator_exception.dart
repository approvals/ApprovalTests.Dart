part of '../../approval_tests.dart';

/// Exception thrown when an error occurs during comparison via IDE.
final class IDEComparatorException implements Exception {
  final String message;
  final Object? exception;
  final StackTrace? stackTrace;

  const IDEComparatorException({
    required this.message,
    required this.exception,
    required this.stackTrace,
  });
}
