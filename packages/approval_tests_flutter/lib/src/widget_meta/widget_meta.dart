import 'package:approval_tests_flutter/src/widget_meta/collect_widgets_meta_data.dart';
import 'package:approval_tests_flutter/src/widget_meta/matcher_types.dart';
import 'package:approval_tests_flutter/src/widget_meta/register_types.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Meta data for widget selected for inclusion in tests
class WidgetMeta {
  WidgetMeta({
    required this.widget,
  }) {
    _updateWidgetKey();
    widgetType = widget.runtimeType;
    isWidgetTypeRegistered = registeredTypes.contains(widgetType) ||
        registeredNames.contains(widgetType.toString());
    _updateWidgetText();
    _updateMatcher();

    assert(
      keyString.isNotEmpty || isWidgetTypeRegistered || widgetText.isNotEmpty,
      'WidgetMeta widget is invalid',
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is WidgetMeta) {
      return keyString == other.keyString &&
          widgetText == other.widgetText &&
          widgetType == other.widgetType;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => widget.hashCode;

  final Widget widget;
  late KeyType keyType;

  /// These fields are used repeatedly so their values are cached
  late MatcherTypes matcherType;

  /// Text value of the key scraped from the widget tree and trimmed
  late final String keyString;

  /// Text value of the widget if a Text widget or similar. E.g., Text(<widgetText>);
  late final String widgetText;

  /// The type of widget
  late final Type widgetType;

  /// True if user registered this widget type
  late final bool isWidgetTypeRegistered;

  /// If widget has text, get it
  void _updateWidgetText() {
    if (widget is Text) {
      final text = widget as Text;
      widgetText = text.data ?? '';
    } else if (widget is TextSpan) {
      final text = widget as TextSpan;
      widgetText = text.text ?? '';
    } else {
      widgetText = '';
    }
  }

  bool get hasText => isTextEnabled(widget);

  static bool isTextEnabled(Widget widget) {
    final runtimeType = widget.runtimeType;
    return runtimeType == Text || runtimeType == TextSpan;
  }

  /// Perform a test on the widget and store its result
  void _updateMatcher() {
    matcherType = MatcherTypes.unknown;

    for (final currentMatcherType in MatcherTypes.values) {
      try {
        expect(
          find.byWidgetPredicate(
            (w) =>
                (keyString.isEmpty || w.key == widget.key!) &&
                (widgetText.isEmpty || w is Text && w.data == widgetText) &&
                (!isWidgetTypeRegistered || w.runtimeType == widgetType),
          ),
          currentMatcherType.matcher,
        );

        // if here, expect didn't throw, so we have our matcher type
        matcherType = currentMatcherType;
        break;
      } catch (e) {
        // Do nothing. Ignore tests that fail
      }
    }
  }

  /// Parse the string key back into its keysClass.keyName format
  ///
  /// If there is 1 word in the widgetKey, it's a an enum key (MyEnum.keyName).
  /// If there are 2 words in the widgetKey, it's a field key (keyClass.keyName).
  /// If there are 3 words, it's a function name (keyClass.keyName(index)).
  ///
  /// Widget keys without the Enzo '__' delimiter return an empty string.
  ///
  /// Note that flutter adds a prefix ('[<') and suffix ('>]') to keys that must be removed.
  void _updateWidgetKey() {
    if (widget.key == null) {
      keyString = '';
    } else {
      final originalWidgetKey = widget.key.toString();
      if (_isWidgetKeyProperlyFormatted(originalWidgetKey)) {
        final strippedWidgetKey = originalWidgetKey.replaceAll("'", '');
        final startIndex = strippedWidgetKey.indexOf('[<');
        final endIndex = strippedWidgetKey.indexOf('>]');
        final trimmedWidgetKey =
            strippedWidgetKey.substring(startIndex + 2, endIndex);
        final words = trimmedWidgetKey.split(RegExp("__|_"));
        words.removeWhere((word) => word == '');

        if (words.length == 1) {
          final word = words[0];
          if (word.contains('.')) {
            keyType = KeyType.enumValue;
            keyString = word;
          } else {
            keyType = KeyType.stringValueKey;
            keyString = "'$word'";
          }
        } else if (words.length == 2) {
          keyType = KeyType.stringValueKey;
          keyString = '${words[0]}.${words[1]}';
        } else if (words.length == 3) {
          keyType = KeyType.functionValueKey;
          keyString = '${words[0]}.${words[1]}(${words[2]})';
        } else {
          /// If here, must be an unsupported key. Do nothing
          keyType = KeyType.unknown;
          keyString = '';
        }
      } else {
        keyString = '<Unknown key type>';
      }
    }
  }

  bool _isWidgetKeyProperlyFormatted(String originalWidgetKey) =>
      (originalWidgetKey.isCustomString ||
          originalWidgetKey.isEnumString ||
          originalWidgetKey.isValueKeyString) &&
      originalWidgetKey.contains('[<') &&
      originalWidgetKey.contains('>]');
}

extension KeyString on String {
  bool get isCustomString => this.contains('__');
  bool get isEnumString =>
      this.contains('_') == false && this.contains('.') == true;
  bool get isValueKeyString => this.startsWith('[<') && this.endsWith('>]');
}

enum KeyType {
  enumValue, // String represents an enum, NOT a ValueKey(<enum value>)
  stringValueKey, // String represents a ValueKey(<string value>)
  functionValueKey, // String represents a ValueKey(<function value>)
  unknown;
}
