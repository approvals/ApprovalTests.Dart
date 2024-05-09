part of '../../../approval_tests.dart';

/// `ExecutableQuery` is an abstract class for executing queries.
abstract interface class ExecutableQuery {
  const ExecutableQuery._();

  /// A method named `getQuery` for getting a query.
  String getQuery();

  /// A method named `executeQuery` for executing a query.
  Future<String> executeQuery(String query);
}
