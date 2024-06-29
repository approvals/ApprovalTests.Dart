import 'package:flutter_test/flutter_test.dart';

/// Types of matchers used in 'expect'
enum MatcherTypes {
  findsNothing,
  findsOneWidget,
  findsWidgets,
  unknown,
}

extension MatcherTypesExtension on MatcherTypes {
  Matcher get matcher {
    switch (this) {
      case MatcherTypes.findsNothing:
        return findsNothing;
      case MatcherTypes.findsOneWidget:
        return findsOneWidget;
      case MatcherTypes.findsWidgets:
        return findsWidgets;
      default:
        return findsNothing;
    }
  }

  String get matcherName {
    switch (this) {
      case MatcherTypes.findsNothing:
        return 'findsNothing';
      case MatcherTypes.findsOneWidget:
        return 'findsOneWidget';
      case MatcherTypes.findsWidgets:
        return 'findsWidgets';
      case MatcherTypes.unknown:
      default:
        return '(Unknown)';
    }
  }
}
