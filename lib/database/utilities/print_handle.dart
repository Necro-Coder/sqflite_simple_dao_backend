import 'package:ansicolor/ansicolor.dart';

class PrintHandler {
  static AnsiPen greenBold = AnsiPen()..green(bold: true);
  static AnsiPen redBold = AnsiPen()..red(bold: true);
  static AnsiPen blueBold = AnsiPen()..blue(bold: true);
  static AnsiPen yellowBold = AnsiPen()..yellow(bold: true);
  static AnsiPen green = AnsiPen()..green();
  static AnsiPen red= AnsiPen()..red();
  static AnsiPen blue = AnsiPen()..blue();
  static AnsiPen yellow = AnsiPen()..yellow();
}