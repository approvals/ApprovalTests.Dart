import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../../../test/queries/db_request_query.dart';

void main() async {
  const dbQuery = DatabaseRequestQuery("1");
  test('verify db query', () async {
    await Approvals.verifyQuery(
      dbQuery,
    );
  });
}
