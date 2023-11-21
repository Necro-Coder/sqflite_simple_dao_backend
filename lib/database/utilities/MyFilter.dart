import 'package:logger/logger.dart';
import 'package:sqflite_simple_dao_backend/database/params/log_params.dart';

class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (LogParams.shouldLog) {
      return true;
    }
    return false;
  }
}
