import 'package:approval_tests_flutter/src/widget_meta/widget_meta.dart';

/// Meta data for generating an expect() statement
class ExpectMeta {
  ExpectMeta({required this.widgetMeta});

  /// Keys found in string_en.json
  List<String>? intlKeys;

  /// The [WidgetMeta] instance associated with this instance (1-to-1)
  final WidgetMeta widgetMeta;

  /// True if entry in string_en.json found
  bool get isIntl => intlKeys != null;

  /// True if multiple entries in string_en.json found
  bool get hasMultipleIntlKeys => isIntl && intlKeys!.length > 1;
}
