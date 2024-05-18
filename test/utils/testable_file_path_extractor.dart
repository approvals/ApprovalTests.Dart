part of '../approval_test.dart';

/// `FakeStackTraceFetcher` is a fake implementation of [IStackTraceFetcher] that needs to be used in tests.
class FakeStackTraceFetcher implements IStackTraceFetcher {
  final String stackTrace;

  const FakeStackTraceFetcher(this.stackTrace);

  @override
  String get currentStackTrace => stackTrace;
}
