part of '../../../approval_tests.dart';

enum _LogColorStyles { red, bgRed }

class _Colorize {
  static const String esc = "\u{1B}[";
  final String text;

  const _Colorize(this.text);

  _Colorize apply(_LogColorStyles style) {
    final appliedText =
        "$esc${style == _LogColorStyles.red ? '38;2;222;121;121' : '41'}m$text${esc}0m";
    return _Colorize(appliedText);
  }

  @override
  String toString() => text;
}
