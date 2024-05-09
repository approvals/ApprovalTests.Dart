import 'package:approval_tests/approval_tests.dart';

/// `DatabaseRequestQuery` is a class that represents a database query to fetch user details.
class DatabaseRequestQuery implements ExecutableQuery {
  final String userId;

  const DatabaseRequestQuery(this.userId);

  /// Simulate a database query to fetch user details
  @override
  String getQuery() => 'SELECT * FROM users WHERE id = $userId';

  /// Execute the database query
  @override
  Future<String> executeQuery(String query) async {
    // Simulate a database response
    await Future<dynamic>.delayed(
      const Duration(milliseconds: 400),
    ); // Simulate database latency
    // Mocked database response for the user details
    if (userId == "1") {
      return '{"id": "1", "name": "John Doe", "email": "john@example.com"}';
    } else {
      return 'Error: User not found';
    }
  }
}
