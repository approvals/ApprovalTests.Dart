import 'package:flutter_test/flutter_test.dart';

/// Types of matchers used in 'expect'
enum MatcherTypes {
  findsNothing,
  findsOneWidget,
  findsWidgets,
  unknown,
}

extension MatcherTypesExtension on MatcherTypes {
  Matcher get matcher => switch (this) {
        MatcherTypes.findsNothing => findsNothing,
        MatcherTypes.findsOneWidget => findsOneWidget,
        MatcherTypes.findsWidgets => findsWidgets,
        MatcherTypes.unknown => findsNothing,
      };

  String get matcherName => switch (this) {
        MatcherTypes.findsNothing => 'findsNothing',
        MatcherTypes.findsOneWidget => 'findsOneWidget',
        MatcherTypes.findsWidgets => 'findsWidgets',
        MatcherTypes.unknown => '(Unknown)',
      };
}
