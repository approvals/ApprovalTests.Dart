import 'dart:convert';

import 'package:approval_tests/approval_tests.dart';

/// `NetworkRequestQuery` simulates a GET request and can respond with stubbed JSON.
/// The class avoids real HTTP traffic by default so approval files remain deterministic.
class NetworkRequestQuery implements ExecutableQuery {
  final Uri endpoint;
  final Map<Uri, Map<String, dynamic>> stubbedResponses;
  final Duration simulatedLatency;

  const NetworkRequestQuery(
    this.endpoint, {
    this.stubbedResponses = const {},
    this.simulatedLatency = const Duration(milliseconds: 200),
  });

  @override
  String getQuery() => 'GET ${endpoint.toString()}';

  @override
  Future<String> executeQuery(String query) async {
    await Future<void>.delayed(simulatedLatency);
    final response = stubbedResponses[endpoint] ?? _defaultPayload(endpoint);
    return JsonEncoder.withIndent('  ').convert(response);
  }

  Map<String, dynamic> _defaultPayload(Uri target) {
    final trailingSegment =
        target.pathSegments.isNotEmpty ? target.pathSegments.last : '';
    return <String, dynamic>{
      'endpoint': target.toString(),
      'status': 'OK',
      'resource': trailingSegment,
      'cached': true,
    };
  }
}
