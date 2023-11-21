/// This class provides utilities for handling sqflite data types when creating models.
///
/// - For variable character length, use the `varchar` map. Specify the length as a string key.
///     - Example: `Constants.varchar['10']` will output `'VARCHAR(10)'`.
///
/// - For decimal numbers, use the `decimal` map. Specify the precision and scale as a string key in the format 'p,s'.
///     - Example: `Constants.decimal['9,2']` will output `'DECIMAL(9,2)'`.
///
/// - For data types that are always the same, use the corresponding constant value.
///     - Example: `Constants.integer` will output `'INTEGER'`.
///
/// - For custom data types, use the `custom` map. You can add any custom data types you want.
class Constants {
  static const String coma = ',';
  static const Map<String, String> varchar = {
    '1': 'VARCHAR(1)',
    '2': 'VARCHAR(2)',
    '4': 'VARCHAR(4)',
    '5': 'VARCHAR(5)',
    '8': 'VARCHAR(8)',
    '20': 'VARCHAR(20)',
    '10': 'VARCHAR(10)',
    '35': 'VARCHAR(35)',
    '30': 'VARCHAR(30)',
    '50': 'VARCHAR(50)',
    '16': 'VARCHAR(16)',
    '100': 'VARCHAR(100)',
    '150': 'VARCHAR(150)',
    '255': 'VARCHAR(255)',
  };
  static const Map<String, String> decimal = {
    '9,2': 'DECIMAL(9,2)',
    '18,2': 'DECIMAL(18,2)'
  };
  static const Map<String, String> custom = {};
  static const String integer = 'INTEGER';
  static const String text = 'TEXT';
  static const String boolean = 'BOOLEAN';
  static const String datetime = 'DATETIME';
  static const String bigint = 'BIGINT';
}
