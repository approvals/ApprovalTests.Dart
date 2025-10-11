import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

import '../../../test/models/item.dart';

// begin-snippet: same_verify_as_json_test_with_model
void main() {
  const jsonItem = JsonItem(
    id: 1,
    name: "JsonItem",
    anotherItem: AnotherItem(id: 1, name: "AnotherItem"),
    subItem: SubItem(
      id: 1,
      name: "SubItem",
      anotherItems: [
        AnotherItem(id: 1, name: "AnotherItem 1"),
        AnotherItem(id: 2, name: "AnotherItem 2"),
      ],
    ),
  );

  test('verify model', () async {
    await Approvals.verifyAsJson(
      jsonItem,
      options: const Options(
        approveResult:
            true, // Approve the result automatically. You can remove this property after the approved file is created.
      ),
    );
  });
}
// end-snippet
