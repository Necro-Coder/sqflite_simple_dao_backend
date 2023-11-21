import 'package:reflectable/mirrors.dart';
import 'package:sqflite_simple_dao_backend/database/database/Reflectable.dart';
import 'package:sqflite_simple_dao_backend/database/database/database_service.dart';
import 'package:sqflite_simple_dao_backend/database/utilities/print_handle.dart';

class GenericDao {
  GenericDao();
  /* region: Dao Reflectable Methods */
  /* region: Insert */
  /// This function takes a record [newReg] and inserts it into the corresponding table.
  ///
  /// The method `newReg` is asynchronous and returns a `Future<int>`. It accepts a dynamic object [newReg] as an argument.
  /// It first gets a reference to the database using `DBProvider.db.database`.
  /// Then, it inserts [newReg] into the table corresponding to its runtime type, converting [newReg] to JSON format for insertion.
  /// The method returns the result of the insertion operation as an integer.
  Future<int> newReg(dynamic newReg) async {
    final db = await DBProvider.db.database;
    int res = 0;
    res = await db!.insert('${newReg.runtimeType}', newReg.toJson());

    PrintHandler.warninLogger.i(
        'sqflite_simple_dao_backend: You just insert $res items to ${newReg.runtimeType}.✨');
    return res;
  }

  /* endregion: Insert */

  /* region: Update */
  /// This function updates a record in the database with the changes specified in [newReg].
  ///
  /// The function takes an object [newReg] that contains the modified data. It retrieves the primary and foreign keys from [newReg] and uses them to find the corresponding record in the database.
  ///
  /// The function then compares the old record with [newReg], identifies the changes, and constructs an SQL query that updates the record with these changes.
  ///
  /// Note: Boolean fields should be added to the if condition to prevent errors.
  ///
  /// Returns a Future that completes with the number of updated records.
  Future<int> updateReg(dynamic newReg) async {
    final db = await DBProvider.db.database;
    Map<String, String> changes = {};
    List<String> auxPr = [];
    List<String> auxFr = [];
    String sql = '';

    /* Retrieve the primary keys of the table. */
    InstanceMirror reflectNew = reflector.reflect(newReg);
    var classMirror = reflector.reflectType(newReg) as ClassMirror;

    List<String> primary =
    reflectNew.type.invokeGetter("primary") as List<String>;

    /* Retrieve the foreign keys of the table. */
    List<String> foreign =
    reflectNew.type.invokeGetter("foreign") as List<String>;

    /* Retrieve all the field names. */
    Iterable<String> names =
    reflectNew.type.invokeGetter("names") as Iterable<String>;

    /* Retrieve the fields for comparison. */
    Map<String, String> fields =
    classMirror.invokeGetter("fields") as Map<String, String>;

    /* Retrieve the record to be updated. */
    for (var x in primary) {
      auxPr.add(reflectNew.invokeGetter(x).toString());
    }

    List oldReg = await getReg(newReg, primaryKeys: auxPr);
    InstanceMirror reflect = reflector.reflect(oldReg.first);

    /* Compare the old record with [newReg] and identify the changes. */
    for (var x in names) {
      if (reflectNew.invokeGetter(x) != reflect.invokeGetter(x)) {
        if (fields[x]!.toLowerCase().contains('bool')) {
          changes.addAll({x: "${reflectNew.invokeGetter(x) == true ? 1 : 0}"});
        } else if (fields[x]!.toLowerCase().contains('date')) {
          changes
              .addAll({x: reflectNew.invokeGetter(x).toString().split(' ')[0]});
        } else {
          changes.addAll({x: "${reflectNew.invokeGetter(x)}"});
        }
      }
    }

    /* If there are no changes, exit the function. */
    if (changes.isEmpty) {
      return 0;
    }

    /* Construct the SQL query. */
    String start = "UPDATE ${newReg.runtimeType} SET";
    String changesStr = '';
    for (var x in changes.keys) {
      if (x != changes.keys.last) {
        changesStr =
        '$changesStr $x = ${changes[x] == 'true' ? 1 : changes[x] == 'false' ? 0 : changes[x]},';
      } else {
        changesStr =
        '$changesStr $x = ${changes[x] == 'true' ? 1 : changes[x] == 'false' ? 0 : changes[x]}';
      }
    }
    String finalStr = '';

    /* Add the primary keys to the SQL query. */
    for (var x in primary) {
      if (x == primary.first) {
        if (fields[x]!.toLowerCase().contains('date')) {
          finalStr =
          ' WHERE $x = "${reflectNew.invokeGetter(x).toString().split(' ')[0]}"';
        } else {
          finalStr = ' WHERE $x = "${reflectNew.invokeGetter(x)}"';
        }
      } else {
        if (fields[x]!.toLowerCase().contains('date')) {
          finalStr =
              '$finalStr and $x = "${reflectNew.invokeGetter(x).toString().split(' ')[0]}"';
        } else {
          finalStr = '$finalStr and $x = "${reflectNew.invokeGetter(x)}"';
        }
      }
    }

    sql = '$start $changesStr $finalStr';

    final res = db!.rawUpdate(sql);
    PrintHandler.warninLogger.w(
        'sqflite_simple_dao_backend: You just updated $res items to ${newReg.runtimeType}.📖');
    return res;
  }

  /* endregion: Update */

  /* region: Delete */
  /// This function deletes a record from the database.
  ///
  /// The function takes an object [obj] and a boolean [all] as parameters. The [all] parameter is used to indicate whether you want to delete the entire table or not.
  /// by default it is set to true.
  ///
  /// If [all] is true, the entire table is deleted.
  /// If [all] is false, only the record passed as a parameter is deleted.
  ///
  /// If you do not want to delete the entire table, a WHERE clause is generated with the primary and foreign keys.
  ///
  /// The function also takes an optional parameter [whereArgs] which can be used to specify additional conditions for the WHERE clause.
  ///
  /// Returns a Future that completes with the number of deleted records.
  Future<int> delete(dynamic obj,
      {bool all = true,
        Map<String, String> whereArgs = const {'': ''}}) async {
    final db = await DBProvider.db.database;
    String sql = 'DELETE FROM ${obj.runtimeType}';

    /* If we're not deleting the entire table, retrieve the primary and foreign keys. */
    if (!all) {
      InstanceMirror reflectNew = reflector.reflect(obj);
      List<String> primary =
      reflectNew.type.invokeGetter("primary") as List<String>;

      /* Construct the WHERE clause. */
      String where = ' WHERE ';
      // Primary keys
      for (var x in primary) {
        if (x == primary.last) {
          where = "$where $x = '${reflectNew.invokeGetter(x)}'";
        } else {
          where = "$where $x = '${reflectNew.invokeGetter(x)}' and";
        }
      }
      sql = '$sql$where';
    }
    if (whereArgs.keys.first != '') {
      Iterable<String> campos = whereArgs.keys;
      String where = ' WHERE ';
      for (var x in campos) {
        if (x == campos.last) {
          where = "$where $x = '${whereArgs[x]}'";
        } else {
          where = "$where $x = '${whereArgs[x]}' and";
        }
      }
      sql = '$sql$where';
    }

    final res = await db!.rawDelete(sql);
    PrintHandler.warninLogger.e(
        'sqflite_simple_dao_backend: You just deleted $res items from ${obj.runtimeType}.⚠️');
    return res;
  }
  /* endregion: Delete */

  /* region: Select */
  /// This function constructs an SQL query based on the parameters passed to it.
  ///
  /// The function takes a dynamic object [obj] which is used to determine the data type.
  ///
  /// The function also takes an optional parameter [primaryKeys] which is a list of primary key values in the order specified by the class.
  ///
  /// Another optional parameter [whereArgs] can be used to specify additional conditions for the WHERE clause. The keys of the map are the field names and the values are the corresponding values.
  ///
  /// The [fields] parameter is a list of specific fields that you want to retrieve in the query. If this parameter is not provided, the function will retrieve the entire record.
  ///
  /// Note: If the field is a boolean, it should be represented as 0 or 1, otherwise the program will fail.
  Future<List<dynamic>> getReg(dynamic obj,
      {List<String>? primaryKeys,
        Map<String, String>? whereArgs,
        List<String>? fields}) async {
    List listRes = [];
    InstanceMirror reflect = reflector.reflect(obj);
    final db = await DBProvider.db.database;
    String sql = "SELECT";

    /* Check if specific fields are provided, otherwise select all fields. */
    if (fields != null && fields.isNotEmpty) {
      for (var x in fields) {
        if (x != fields.last) {
          sql = "$sql $x,";
        } else {
          sql = "$sql $x FROM ${obj.runtimeType}";
        }
      }
    } else {
      sql = "$sql * FROM ${obj.runtimeType}";
    }

    /* Check if filtering by primary key is required. */
    if (primaryKeys != null && primaryKeys.isNotEmpty) {
      List<String> finalPrimary =
      reflect.type.invokeGetter("primary") as List<String>;
      int cont = 0;
      for (var x in finalPrimary) {
        if (x == finalPrimary.last) {
          if (x == finalPrimary.first) {
            sql = "$sql WHERE $x = '${primaryKeys[cont]}'";
          } else {
            sql = "$sql $x = '${primaryKeys[cont]}'";
          }
        } else {
          if (x == finalPrimary.first) {
            sql = "$sql WHERE $x = '${primaryKeys[cont]}' and";
          } else {
            sql = "$sql $x = '${primaryKeys[cont]}' and";
          }
        }
        cont++;
      }
    }


    /* Construct the specific WHERE clause. */
    if (whereArgs != null && whereArgs.isNotEmpty) {
      Iterable<String> claves = whereArgs.keys;
      String body = "";

      for (var x in claves) {
        if (x != claves.last) {
          if (whereArgs[x]!.contains('SELECT')) {
            body = "$body$x = ${whereArgs[x]} and ";
          } else {
            body = "$body$x = '${whereArgs[x]}' and ";
          }
        } else {
          if (whereArgs[x]!.contains('SELECT')) {
            body = "$body$x = ${whereArgs[x]}";
          } else {
            body = "$body$x = '${whereArgs[x]}'";
          }
        }
      }
      /* Check if the WHERE clause has been created when processing the primary keys. */
      if (primaryKeys != null &&
          primaryKeys.isNotEmpty) {
        // The WHERE clause has been created.
        sql = "$sql $body";
      } else {
        // The WHERE clause has not been created.
        sql = "$sql WHERE $body";
      }
    }
    final res = await db!.rawQuery(sql);
    for (var x in res) {
      listRes.add(reflect.type.newInstance('fromJson', [x]));
    }
    PrintHandler.warninLogger.w(
        'sqflite_simple_dao_backend: The query returned ${listRes.length} values from ${obj.runtimeType} ⌨️');
    return listRes;
  }
  /* endregion: Select */
  /* endregion: Dao Reflectable Methods */

  /* region: Raw Dao */
  Future<int> rawInsert(String sql) async {
    final db = await DBProvider.db.database;
    int result = 0;
    result = await db!.rawInsert(sql);
    return result;
  }

  Future<int> rawUpdate(String sql) async {
    final db = await DBProvider.db.database;
    int result = 0;
    result = await db!.rawUpdate(sql);
    return result;
  }

  Future<int> rawDelete(String sql) async {
    final db = await DBProvider.db.database;
    int result = 0;
    result = await db!.rawDelete(sql);
    return result;
  }
/* endregion: Raw Dao */
}