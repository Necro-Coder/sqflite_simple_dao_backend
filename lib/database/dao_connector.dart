import 'dart:async';
import 'package:sqflite_simple_dao_backend/database/database/new_dao.dart';

import 'database/dao.dart';

class Dao extends NewDao {
  final GenericDao dao = const GenericDao();

  Dao();

  /// This function takes a record [newReg] and inserts it into the corresponding table.
  ///
  /// The method `insert` is asynchronous and returns a `Future<int>`. It accepts a dynamic object [newReg] as an argument.
  /// It first gets a reference to the database using `DBProvider.db.database`.
  /// Then, it inserts [newReg] into the table corresponding to its runtime type, converting [newReg] to JSON format for insertion.
  /// The method returns the result of the insertion operation as an integer.
  @Deprecated(
      'This method is deprecated and will be deleted on the next release. Please use `insertSingle` or `batchInsert` instead.')
  Future<int> insert(dynamic newReg) async {
    var old = await query(newReg);
    if (old.isEmpty) {
      return await dao.newReg(newReg);
    }
    return -1;
  }

  /// This function updates a record in the database with the changes specified in [newReg].
  ///
  /// The function takes an object [newReg] that contains the modified data. It retrieves the primary and foreign keys from [newReg] and uses them to find the corresponding record in the database.
  ///
  /// The function then compares the old record with [newReg], identifies the changes, and constructs an SQL query that updates the record with these changes.
  ///
  /// Note: Boolean fields should be added to the if condition to prevent errors.
  ///
  /// Returns a Future that completes with the number of updated records.
  @Deprecated(
      'This method is deprecated and will be deleted on the next release. Please use `updateSingle` or `batchUpdate` instead.')
  Future<int> update(dynamic newReg) async {
    return await dao.updateReg(newReg);
  }

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
  @Deprecated(
      'This method is deprecated and will be deleted on the next release. Please use `deleteSingle` or `batchDelete` instead.')
  Future<int> delete(dynamic obj,
      {bool all = true, Map<String, String> whereArgs = const {'': ''}}) async {
    return await dao.delete(obj, whereArgs: whereArgs, all: all);
  }

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
  Future<List<dynamic>> query(dynamic obj,
      {List<String>? primaryKeys,
      Map<String, String>? whereArgs,
      List<String>? fields}) async {
    return await dao.getReg(obj,
        whereArgs: whereArgs, primaryKeys: primaryKeys);
  }
}
