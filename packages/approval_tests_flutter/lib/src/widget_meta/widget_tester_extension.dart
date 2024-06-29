import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Holds the value of the class that has members that are strings. Typically, this is the S class in i18n.dart
/// of the intl package. However, it can by any class of the structure:
///
///     class MyTextHolder {
///       static String title => 'The Book of Avocados';
///       static String body => 'Once upon a time there was an avocado....
///     }
///
dynamic _s;

extension WidgetTesterExtension on WidgetTester {
  /// Set a class that has members that are strings (see [_s] for more detail)
  static set s(dynamic value) => _s = value;

  /// Get the class that has members that are strings (see [_s] for more detail)
  static dynamic get s => _s;

  String _getStringFromFinder(
    Finder finder,
    String Function(dynamic s) intl,
  ) =>
      intl(_s);

  /// Returns a [Finder] for Widgets that match one or more parameters
  ///
  /// [intl] receives the `intl` package `S` object and returns the String to find.
  /// [text] is a String to find.
  /// [widgetType] is the Type of widget to find.
  /// [key] is the key to find.
  ///
  /// You can pass no String, [intl], or [text], but not both.
  /// If [key] and [widgetType] are BOTH null, [widgetType] is assumed to be Text
  Finder findBy({
    String Function(dynamic s)? intl,
    String? text,
    Type? widgetType,
    Key? key,
  }) {
    assert(intl == null || text == null);

    final Type? soughtType =
        key == null && widgetType == null ? Text : widgetType;

    late Finder finder;

    if (key != null) {
      finder = find.byKey(key);
      if (soughtType == Text && (intl != null || text != null)) {
        final String widgetText = text ?? _getStringFromFinder(finder, intl!);
        expect(find.text(widgetText).evaluate(), finder.evaluate());
      }
    } else {
      finder = find.byType(soughtType!);
      if (intl != null || text != null) {
        final String widgetText = text ?? _getStringFromFinder(finder, intl!);
        if (soughtType == Text) {
          finder = find.text(widgetText);
        }
      }
    }

    return finder;
  }

  /// See [findBy] for param descriptions.
  ///
  /// Usage:
  ///
  ///    expectWidget(intl: (s) => s.someText, key: MyWidgetKeys.someText)
  ///
  void expectWidget({
    String Function(dynamic s)? intl,
    String? text,
    Type? widgetType,
    Key? key,
    Matcher matcher = findsOneWidget,
  }) {
    final Finder finder =
        findBy(intl: intl, text: text, widgetType: widgetType, key: key);
    expect(finder, matcher);
  }

  /// See [findBy] for param descriptions.
  Future<void> tapWidget({
    required String Function(dynamic s) intl,
    String? text,
    Type? widgetType,
    Key? key,
    bool shouldPumpAndSettle = true,
  }) async {
    final Finder finder =
        findBy(intl: intl, text: text, widgetType: widgetType, key: key);
    expect(finder, findsOneWidget);
    await tap(finder);
    if (shouldPumpAndSettle) {
      await pumpAndSettle();
    }
  }
}
