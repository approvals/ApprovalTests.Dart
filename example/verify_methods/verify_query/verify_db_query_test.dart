import 'package:approval_tests/approval_tests.dart';

import '../../../test/queries/db_request_query.dart';

void main() async {
  const dbQuery = DatabaseRequestQuery("1");
  await Approvals.verifyQuery(
    dbQuery,
    options: const Options(deleteReceivedFile: true),
  );
}
