part of '../../../approval_tests.dart';

/// A class that provides the current stack trace.
final class StackTraceFetcher implements IStackTraceFetcher {
  const StackTraceFetcher();

  @override
  String get currentStackTrace => StackTrace.current.toString();
}
