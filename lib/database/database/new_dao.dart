import 'package:meta/meta.dart';
import 'package:reflectable/mirrors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_simple_dao_backend/database/database/database_service.dart';
import 'package:sqflite_simple_dao_backend/database/database/sql_builder.dart';
import 'package:sqflite_simple_dao_backend/database/utilities/print_handle.dart';
import 'package:sqflite_simple_dao_backend/sqflite_simple_dao_backend.dart';

class NewDao {
  const NewDao();

  /// This method is used to get the database instance from the DBProvider.
  ///
  /// It calls the `database` getter on the `DBProvider.db` singleton instance,
  /// which returns a `Future<Database>`. This future is awaited and the resulting
  /// `Database` instance is returned.
  ///
  /// Returns:
  ///   Future<Database?>: A future that completes with the `Database` instance.
  Future<Database?> getDatabase() async {
    var db = await DBProvider.db.database;
    return db;
  }

  /// This method is used to get the table name for a given object.
  ///
  /// It takes an object as a parameter and returns a string that represents the
  /// table name for that object in the database. The table name is constructed by
  /// converting the runtime type of the object to a string and making it lowercase.
  /// An 's' is appended to the end of the string to make it plural.
  ///
  /// Parameters:
  ///   obj (dynamic): The object for which to get the table name.
  ///
  /// Returns:
  ///   String: The table name for the given object.
  String getTableName(dynamic obj) {
    return '${obj.runtimeType.toString().toLowerCase()}s';
  }

  /// This method is used to construct a WHERE clause for SQL operations.
  ///
  /// It takes a current WHERE clause, a field name, and a list of primary keys as parameters.
  /// It adds a condition for the field to the WHERE clause. If the field is the last primary key,
  /// it simply adds the condition to the WHERE clause. If the field is not the last primary key,
  /// it adds the condition followed by 'AND' to the WHERE clause.
  ///
  /// Parameters:
  ///   where (String): The current WHERE clause.
  ///   x (String): The field name to add to the WHERE clause.
  ///   primary (List<String>): The list of primary keys.
  ///
  /// Returns:
  ///   String: The updated WHERE clause.
  String makeWhere(String where, String x, List<String> primary) {
    var whereToAdd = '$where $x = ?';
    if (x == primary.last) {
      where += whereToAdd;
    } else {
      where = "$where $whereToAdd AND ";
    }
    return where;
  }

  List<dynamic> _getIntersectionList(
      Set<dynamic> objectsToInsertSet, Set<dynamic> querySet) {
    Set<dynamic> intersection = objectsToInsertSet.intersection(querySet);
    List<dynamic> intersectionList = intersection.toList();
    return intersectionList;
  }

  List<dynamic> _getDifferenceList(
      Set<dynamic> objectsToInsertSet, Set<dynamic> querySet) {
    Set<dynamic> difference = objectsToInsertSet.difference(querySet);
    List<dynamic> differenceList = difference.toList();
    return differenceList;
  }

  /// This method is used to insert a list of objects into the database.
  ///
  /// It takes a list of objects as a parameter and inserts each object into the
  /// database in a batch operation. This can improve performance when inserting
  /// multiple objects at once.
  ///
  /// The method first gets the database instance and starts a batch operation.
  /// Then, for each object in the list, it calls the `toJson` method on the object
  /// to convert it to a map, and inserts the map into the database. The table name
  /// for the insert operation is obtained by calling the `getTableName` method with
  /// the object.
  ///
  /// After all objects have been inserted, the batch operation is committed. If the
  /// batch operation is successful, the method returns the number of operations that
  /// were performed. If an error occurs during the batch operation, the method logs
  /// the error and returns -1.
  ///
  /// Parameters:
  ///   objectsToInsert (List<dynamic>): The list of objects to insert into the database.
  ///
  /// Returns:
  ///   Future<int>: A future that completes with the number of insert operations that were performed, or -1 if an error occurred.
  Future<int> batchInsert(
      {@required required List<dynamic> objectsToInsert,
      bool orUpdate = false}) async {
    var db = await getDatabase();
    var batch = db!.batch();

    var queryResult = await select(
        sqlBuilder: SqlBuilder()
            .querySelect()
            .queryFrom(table: getTableName(objectsToInsert.first)),
        model: objectsToInsert.first,
        print: false);

    Set<dynamic> querySet = Set.of(queryResult);
    Set<dynamic> objectsToInsertSet = Set.of(objectsToInsert);

    List<dynamic> differenceList =
        _getDifferenceList(objectsToInsertSet, querySet);

    for (var object in differenceList) {
      batch.insert(getTableName(object), object.toJson());
    }
    try {
      var result = await batch.commit();
      return result.length;
    } catch (e) {
      PrintHandler.warningLogger.e(
          '⛔sqflite_simple_dao_backend⛔: Error inserting batch: $e. "-1" returned.');
      return -1;
    }
  }

  Future<int> batchInsertOrUpdate(
      {@required required List<dynamic> objects}) async {
    int result;
    var queryResult = await select(
        sqlBuilder: SqlBuilder()
            .querySelect()
            .queryFrom(table: getTableName(objects.first)),
        model: objects.first,
        print: false);

    Set<dynamic> querySet = Set.of(queryResult);
    Set<dynamic> objectsToInsertSet = Set.of(objects);

    List<dynamic> differenceList =
        _getDifferenceList(objectsToInsertSet, querySet);

    List<dynamic> intersectionList =
        _getIntersectionList(objectsToInsertSet, querySet);

    result = await batchInsert(objectsToInsert: differenceList);
    result += await batchUpdate(objectsToUpdate: intersectionList);

    return result;
  }

  Future<int> batchInsertOrDelete(
      {@required required List<dynamic> objects}) async {
    int result;
    var queryResult = await select(
        sqlBuilder: SqlBuilder()
            .querySelect()
            .queryFrom(table: getTableName(objects.first)),
        model: objects.first,
        print: false);

    Set<dynamic> querySet = Set.of(queryResult);
    Set<dynamic> objectsToInsertSet = Set.of(objects);

    List<dynamic> differenceList =
        _getDifferenceList(objectsToInsertSet, querySet);

    List<dynamic> intersectionList =
        _getIntersectionList(objectsToInsertSet, querySet);

    result = await batchInsert(objectsToInsert: differenceList);
    result += await batchDelete(objectsToDelete: intersectionList);

    return result;
  }

  /// This method is used to insert a single object into the database.
  ///
  /// It takes an object as a parameter and inserts it into the database. If the
  /// insert operation is successful, the method returns the id of the inserted
  /// record. If an error occurs during the insert operation, the method logs the
  /// error and returns -1.
  ///
  /// The method first gets the database instance. Then, it calls the `toJson`
  /// method on the object to convert it to a map, and inserts the map into the
  /// database. The table name for the insert operation is obtained by calling the
  /// `getTableName` method with the object.
  ///
  /// Parameters:
  ///   objectToInsert (dynamic): The object to insert into the database.
  ///
  /// Returns:
  ///   Future<int>: A future that completes with the id of the inserted record, or -1 if an error occurred.
  Future<int> insertSingle({@required required dynamic objectToInsert}) async {
    var db = await getDatabase();
    try {
      var queryResult = await select(
          sqlBuilder: SqlBuilder()
              .querySelect()
              .queryFrom(table: getTableName(objectToInsert)),
          model: objectToInsert,
          print: false);
      if (queryResult.contains(objectToInsert.toJson())) {
        PrintHandler.warningLogger.e(
            '⛔sqflite_simple_dao_backend⛔: Error inserting record: Record already exists. "-1" returned.');
        return -1;
      }
      var result = await db!
          .insert(getTableName(objectToInsert), objectToInsert.toJson());
      return result;
    } catch (e) {
      PrintHandler.warningLogger.e(
          '⛔sqflite_simple_dao_backend⛔: Error inserting the record: $e. "-1" returned.');
      return -1;
    }
  }

  /// This method is used to update a list of objects in the database.
  ///
  /// It takes a list of objects as a parameter and updates each object in the
  /// database in a batch operation. This can improve performance when updating
  /// multiple objects at once.
  ///
  /// The method first gets the database instance and starts a batch operation.
  /// Then, for each object in the list, it calls the `toJson` method on the object
  /// to convert it to a map, and updates the corresponding record in the database.
  /// The table name for the update operation is obtained by calling the `getTableName`
  /// method with the object.
  ///
  /// After all objects have been updated, the batch operation is committed and
  /// the method returns the number of operations that were performed. If an error
  /// occurs during the batch operation, the method logs the error and returns -1.
  ///
  /// Parameters:
  ///   objectsToUpdate (List<dynamic>): The list of objects to update in the database.
  ///
  /// Returns:
  ///   Future<int>: A future that completes with the number of update operations that were performed, or -1 if an error occurred.
  Future<int> batchUpdate(
      {@required required List<dynamic> objectsToUpdate}) async {
    var db = await getDatabase();
    var batch = db!.batch();

    for (var object in objectsToUpdate) {
      batch.update(getTableName(object), object.toJson());
    }
    try {
      var result = await batch.commit();
      return result.length;
    } catch (e) {
      PrintHandler.warningLogger.e(
          '⛔sqflite_simple_dao_backend⛔: Error updating batch: $e. "-1" returned.');
      return -1;
    }
  }

  /// This method is used to update a single object in the database.
  ///
  /// It takes an object as a parameter and updates the corresponding record in the
  /// database. If the update operation is successful, the method returns the number
  /// of rows affected. If an error occurs during the update operation, the method
  /// logs the error and returns -1.
  ///
  /// The method first gets the database instance. Then, it uses reflection to get
  /// the primary key(s) of the object. It constructs a WHERE clause for the update
  /// operation using the primary key(s) and their values.
  ///
  /// Then, it updates the corresponding record in the database. The table name for
  /// the update operation is obtained by calling the `getTableName` method with the object.
  /// The new values for the record are obtained by calling the `toJson` method on the object.
  ///
  /// Parameters:
  ///   objectToUpdate (dynamic): The object to update in the database.
  ///
  /// Returns:
  ///   Future<int>: A future that completes with the number of rows affected by the update operation, or -1 if an error occurred.
  Future<int> updateSingle({@required required dynamic objectToUpdate}) async {
    var db = await getDatabase();

    InstanceMirror reflectNew = reflector.reflect(objectToUpdate);
    List<String> primary =
        reflectNew.type.invokeGetter("primary") as List<String>;
    List<dynamic> databaseModel;

    databaseModel = await select<dynamic>(
        sqlBuilder: SqlBuilder()
            .querySelect(fields: primary)
            .queryFrom(table: getTableName(objectToUpdate))
            .queryWhere(
                conditions: primary
                    .map((e) => '$e = ${reflectNew.invokeGetter(e)}')
                    .toList()),
        model: objectToUpdate,
        print: false);

    Map<String, dynamic> updatedFields = {};

    for (String field in objectToUpdate.toJson().keys) {
      if (objectToUpdate.toJson()[field] != databaseModel[0].toJson()[field]) {
        updatedFields[field] = objectToUpdate.toJson()[field];
      }
    }

    if (updatedFields.isEmpty) {
      PrintHandler.warningLogger.w(
          '⚠️sqflite_simple_dao_backend⚠️: No changes detected. "0" returned.');
      return 0;
    }

    String where = primary.map((e) => '$e = ?').join(' AND ');
    List<dynamic> whereArgs =
        primary.map((e) => reflectNew.invokeGetter(e)).toList();

    int result = await db!.update(
      getTableName(objectToUpdate),
      updatedFields,
      where: where,
      whereArgs: whereArgs,
    );

    return result;
  }

  /// This method is used to delete a batch of objects from the database.
  ///
  /// It takes a list of objects as a parameter and deletes the corresponding records from the
  /// database. If the delete operation is successful, the method returns the number
  /// of rows affected. If an error occurs during the delete operation, the method
  /// logs the error and returns -1.
  ///
  /// The method first gets the database instance and starts a batch operation.
  /// Then, for each object in the list of objects to delete, it uses reflection to get
  /// the primary key(s) of the object. It constructs a WHERE clause for the delete
  /// operation using the primary key(s) and their values.
  ///
  /// Then, it adds the delete operation to the batch. The table name for the delete operation
  /// is obtained by calling the `getTableName` method with the object.
  ///
  /// Finally, it commits the batch and returns the number of operations in the batch.
  ///
  /// Parameters:
  ///   objectsToDelete (List<dynamic>): The list of objects to delete from the database.
  ///
  /// Returns:
  ///   Future<int>: A future that completes with the number of rows affected by the delete operation, or -1 if an error occurred.
  ///
  Future<int> batchDelete(
      {@required required List<dynamic> objectsToDelete}) async {
    var db = await getDatabase();
    var batch = db!.batch();

    for (var object in objectsToDelete) {
      InstanceMirror reflectNew = reflector.reflect(object);
      List<String> primary =
          reflectNew.type.invokeGetter("primary") as List<String>;
      List<dynamic> whereArgs = [];

      /* Construct the WHERE clause. */
      String where = '';
      // Primary keys
      for (var x in primary) {
        whereArgs.add(reflectNew.invokeGetter(x));

        where = makeWhere(where, x, primary);
      }
      batch.delete(getTableName(object), where: where, whereArgs: whereArgs);
    }

    try {
      var result = await batch.commit();
      return result.length;
    } catch (e) {
      PrintHandler.warningLogger.e(
          '⛔sqflite_simple_dao_backend⛔: Error deleting batch: $e. "-1" returned.');
      return -1;
    }
  }

  /// This method is used to delete a single object from the database.
  ///
  /// It takes an object as a parameter and deletes the corresponding record from the
  /// database. If the delete operation is successful, the method returns the number
  /// of rows affected. If an error occurs during the delete operation, the method
  /// logs the error and returns -1.
  ///
  /// The method first gets the database instance. Then, it uses reflection to get
  /// the primary key(s) of the object. It constructs a WHERE clause for the delete
  /// operation using the primary key(s) and their values.
  ///
  /// Then, it deletes the corresponding record from the database. The table name for
  /// the delete operation is obtained by calling the `getTableName` method with the object.
  ///
  /// Parameters:
  ///   objectToDelete (dynamic): The object to delete from the database.
  ///
  /// Returns:
  ///   Future<int>: A future that completes with the number of rows affected by the delete operation, or -1 if an error occurred.
  Future<int> deleteSingle({@required required dynamic objectToDelete}) async {
    var db = await getDatabase();

    InstanceMirror reflectNew = reflector.reflect(objectToDelete);
    List<String> primary =
        reflectNew.type.invokeGetter("primary") as List<String>;
    List<dynamic> whereArgs = [];

    /* Construct the WHERE clause. */
    String where = '';
    // Primary keys
    for (var x in primary) {
      whereArgs.add(reflectNew.invokeGetter(x));

      where = makeWhere(where, x, primary);
    }

    try {
      var result = await db!.delete(getTableName(objectToDelete),
          where: where, whereArgs: whereArgs);
      return result;
    } catch (e) {
      PrintHandler.warningLogger.e(
          '⛔sqflite_simple_dao_backend⛔: Error deleting record: $e. "-1" returned.');
      return -1;
    }
  }

  /// Executes a 'SELECT' SQL query and returns the results.
  ///
  /// The `sqlBuilder` parameter is required. It should be an instance of `SqlBuilder` that represents the 'SELECT' query.
  /// The `print` parameter is optional and defaults to `false`. If `print` is `true`, the final SQL query string will be logged.
  /// The `model` parameter is optional. If provided, it should be an empty instance of the model class that the results should be converted to.
  ///
  /// This method first gets a reference to the database by calling `getDatabase()`. Then it executes the 'SELECT' query by calling `rawQuery()` on the database reference. The SQL query string is obtained by calling `build(print: print)` on the `sqlBuilder` instance.
  ///
  /// If the result set is empty, a warning is logged and the method returns an empty list.
  ///
  /// If `T` is not a basic type (`String`, `int`, `double`, `bool`, `DateTime`, or `Null`) and `model` is `null`, the method returns the result set as a `List<Map<String, dynamic>>`.
  ///
  /// If `model` is not `null`, the method uses reflection to convert each map in the result set to an instance of `T`. The `fromJson` method of the model class is used for this conversion. The method returns a list of these instances.
  ///
  /// If `T` is a basic type and `model` is `null`, the method tries to convert each map in the result set to `T` and returns a list of these values. If this conversion fails, a warning is logged and the method returns `null`.
  ///
  /// Usage:
  /// ```dart
  /// var builder = SqlBuilder();
  /// // Add statements to the builder...
  /// var result = await select<int>(sqlBuilder: builder, print: true);
  /// // or
  /// var result = await select<MyModel>(sqlBuilder: builder, model: MyModel());
  /// ```
  ///
  /// Note: If you want to return a model, you must specify an empty instance of that model in order to make the reflection.

  Future<dynamic> select<T>(
      {@required required SqlBuilder sqlBuilder,
      bool print = false,
      dynamic model}) async {
    var db = await getDatabase();
    var result = await db!.rawQuery(sqlBuilder.build(print: print));
    if (result.isEmpty) {
      PrintHandler.warningLogger
          .t('⚠️sqflite_simple_dao_backend⚠️: No data found.');
    }
    if ((T != String ||
            T != int ||
            T != double ||
            T != bool ||
            T != DateTime ||
            T == Null) &&
        model == null) {
      return result;
    } else if (model != null) {
      ClassMirror instance = reflector.reflect(model).type;
      List<dynamic> list = [];
      for (var x in result) {
        list.add(instance.newInstance('fromJson', [x]));
      }
      return list;
    } else {
      try {
        return result.map((e) => e.values.first as T).toList();
      } catch (e) {
        PrintHandler.warningLogger.f(
            '⛔sqflite_simple_dao_backend⛔: Error selecting data: $e. "null" returned.');
        return null;
      }
    }
  }
}
