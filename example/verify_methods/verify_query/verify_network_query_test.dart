import 'package:approval_tests/approval_tests.dart';

import '../../../test/queries/network_request_query.dart';

void main() async {
  final query = NetworkRequestQuery(
    Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
  );
  await Approvals.verifyQuery(
    query,
    options: const Options(deleteReceivedFile: true),
  );
}
