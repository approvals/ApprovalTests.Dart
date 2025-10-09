import 'dart:convert';

import 'package:approval_tests/approval_tests.dart';
import 'package:test/test.dart';

class _SampleModel {
  const _SampleModel(this.name, this.count);

  final String name;
  final int count;

  Map<String, dynamic> toJson() => {
        'name': name,
        'count': count,
      };
}

void main() {
  group('ApprovalConverter', () {
    test('encodeReflectively escapes map keys correctly', () {
      final encoded = ApprovalConverter.encodeReflectively({
        'bad"key': 'value',
        'list': ['entry', 2],
      });

      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      expect(decoded['bad"key'], equals('value'));
      expect(decoded['list'], equals(['entry', 2]));
    });

    test('encodeReflectively includes class wrapper when requested', () {
      const model = _SampleModel('Sample', 3);
      final encoded = ApprovalConverter.encodeReflectively(
        model,
        includeClassName: true,
      );

      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      expect(decoded.keys.length, equals(1));
      final wrapperKey = decoded.keys.first;
      expect(wrapperKey, equals('sampleModel'));

      final wrapped = decoded[wrapperKey] as Map<String, dynamic>;
      expect(wrapped['name'], equals('Sample'));
      expect(wrapped['count'], equals(3));
    });
  });
}
