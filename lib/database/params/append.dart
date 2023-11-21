import 'package:ansicolor/ansicolor.dart';
import 'package:meta/meta.dart';
import 'package:sqflite_simple_dao_backend/database/params/db_parameters.dart';
import 'package:sqflite_simple_dao_backend/database/utilities/print_handle.dart';
import 'package:sqflite_simple_dao_backend/database/params/constants.dart';

/// These methods ensure the safe usage of maps in the Constants class.
/// For reliable operation, it's crucial to use these methods when implementing
/// various functionalities.
class Append {
  /* region: Public method */

  /// This static method allows adding constant values to specific maps in the Constants class.
  ///
  /// Parameters:
  /// - [key] (required): The name of the value in the map. This parameter is required.
  /// - [value] (required): The value to be appended to the map with the specified key. This parameter is required.
  /// - [override] (optional): A boolean value indicating whether to override the existing value if the key already exists. Default value is false.
  /// - [type] (optional): The type of the constant. It can be 'varchar', 'decimal', or 'custom'. If not specified or if the specified type is not recognized, the value will be added to the 'custom' map. Default value is ''.
  ///
  /// Depending on the 'type' parameter, the method adds the key-value pair to the appropriate map in the Constants class. If the key already exists in the map and the 'override' parameter is set to true, the method updates the existing value. If the 'override' parameter is false, the method skips the addition.
  ///
  /// After each operation, the method prints a message indicating the action taken.
  static void constant(
      {@required required String key,
      @required required String value,
      bool override = false,
      String type = ''}) {
    ansiColorDisabled = false;
    switch (type.toLowerCase()) {
      case ('varchar'):
        _change(Constants.varchar, 'varchar', key, value, override);
        break;
      case ('decimal'):
        _change(Constants.decimal, 'decimal', key, value, override);
        break;
      case ('custom'):
        _change(Constants.custom, 'custom', key, value, override);
        break;
      default:
        _change(Constants.custom, 'custom', key, value, override);
        break;
    }
  }

  /// This static method updates the database parameters based on the provided arguments.
  ///
  /// The [param] argument is a required string that specifies the database parameter to be updated. It should be one of the following: 'name', 'tables', or 'version'.
  ///
  /// The [value] argument is a dynamic object that specifies the new value for the database parameter.
  ///
  /// The [update] argument is an optional boolean that defaults to false. If set to true and the [param] argument is 'tables', the [value] will be added to the existing list of tables.
  ///
  /// If the [param] argument is 'name' and the [value] argument is a string, the database name will be updated.
  ///
  /// If the [param] argument is 'tables' and the [value] argument is a list, the list of tables will be updated. If the [value] argument is a type and the [update] argument is true, the [value] will be added to the list of tables.
  ///
  /// If the [param] argument is 'version' and the [value] argument is an integer, the database version will be updated.
  static void dbParameters(
      {@required required String param, @required required dynamic value, update = false}) {
    ansiColorDisabled = false;
    switch (param.toLowerCase()) {
      case 'name':
        if ('${value.runtimeType}'.toLowerCase().contains('string')) {
          DbParameters.dbName = value;
          print(PrintHandler.greenBold(
              'sqflite_simple_dao_backend: The value for the database name is now $value. 💫'));
        } else {
          print(PrintHandler.redBold(
              'sqflite_simple_dao_backend: Unfortunately, the value is ${value.runtimeType} and it should be String, skiping... 😭'));
        }
        break;
      case 'tables':
        if ('${value.runtimeType}'.toLowerCase().contains('list')) {
          DbParameters.tables = value;
          print(PrintHandler.greenBold(
              'sqflite_simple_dao_backend: The value for the tables list just updated with ${DbParameters.tables.length} elements.✨'));
        } else if ('${value.runtimeType}'.toLowerCase().contains('type') &&
            update) {
          DbParameters.tables.add(value);
          print(PrintHandler.greenBold(
              'sqflite_simple_dao_backend: You already insert ${value.toString()} to the tables list.😋'));
        } else {
          print(PrintHandler.redBold(
              'sqflite_simple_dao_backend: Unfortunately, the value is ${value.runtimeType} and it should be List<Type>, skiping... 😭'));
          print(PrintHandler.yellowBold(
              'sqflite_simple_dao_backend: In case you want to update the list, just set update = true. 😉'));
        }
      case 'version':
        if ('${value.runtimeType}'.toLowerCase().contains('int')) {
          DbParameters.dbVersion = value;
          print(PrintHandler.greenBold(
              'sqflite_simple_dao_backend: The value for the database version is now $value. 💫'));
        } else {
          print(PrintHandler.redBold(
              'sqflite_simple_dao_backend: Unfortunately, the value is ${value.runtimeType} and it should be int, skiping... 😭'));
        }
    }
  }

  /* endregion */

  /* region: Useful private method */
  static void _change(Map<String, String> map, String name, String key,
      String value, bool override) {
    Iterable checkList = map.keys;
    if (!checkList.contains(key)) {
      map.addAll({key: value});
      print(PrintHandler.greenBold(
          'sqflite_simple_dao_backend: New value {$key: $value} added to $name constant value list 👏'));
    } else if (checkList.contains(key) && map[key] != value && override) {
      map[key] = value;
      print(PrintHandler.yellowBold(
          'sqflite_simple_dao_backend: The value {$key: $value} was already in $name constant value list. Updating...💱'));
    } else {
      print(PrintHandler.yellowBold(
          'sqflite_simple_dao_backend: The value {$key: $value} was already in $name constant value list. Skipping...🪜'));
    }
  }
/* endregion */
}
