import 'dart:convert';
import 'dart:io';

import 'package:approval_tests/approval_tests.dart';

/// `NetworkRequestQuery` is a class that represents a network request query to fetch data. It is only example. In tests, you should use a mock server.
class NetworkRequestQuery implements ExecutableQuery {
  final Uri endpoint;

  const NetworkRequestQuery(this.endpoint);

  @override
  String getQuery() => 'GET ${endpoint.toString()}';

  @override
  Future<String> executeQuery(String query) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(endpoint);
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        return responseBody;
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Exception: $e';
    } finally {
      client.close();
    }
  }
}
