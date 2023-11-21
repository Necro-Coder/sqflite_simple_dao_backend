import 'package:logger/logger.dart';
import 'package:sqflite_simple_dao_backend/database/utilities/MyFilter.dart';

class PrintHandler {
  static final Logger warninLogger = Logger(
    filter: MyFilter(),
  );
  static final Logger infoLogger =
      Logger(filter: MyFilter(), level: Level.info, printer: PrettyPrinter());
  static final Logger successLogger =
      Logger(filter: MyFilter(), level: Level.all, printer: PrettyPrinter());
  static final Logger errorLogger =
      Logger(filter: MyFilter(), level: Level.error, printer: PrettyPrinter());
}
