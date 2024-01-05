import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:reflectable/mirrors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_simple_dao_backend/database/database/reflectable.dart';
import 'package:sqflite_simple_dao_backend/database/params/db_parameters.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  /// This method is used to initialize the database.
  /// It first gets the application documents directory and then constructs the path of the database file.
  /// It then opens the database and creates the tables if they do not exist.
  /// It also handles the database upgrade process.
  Future<Database?> initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentDirectory.path, '${DbParameters.dbName}.db');

    return await openDatabase(
      path,
      version: DbParameters.dbVersion,
      onOpen: (db) {},
      onCreate: (db, version) async {
        // For each table in DbParameters.tables, it creates the table if it does not exist.
        await createDatabase(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        switch (oldVersion) {
          default:
            // For each table in DbParameters.tables, it creates the table if it does not exist.
            await createDatabase(db);
        }
      },
    );
  }

  Future<void> createDatabase(Database db) async {
    for (var x in DbParameters.tables) {
      var classMirror = reflector.reflectType(x) as ClassMirror;

      Iterable<String> names =
          classMirror.invokeGetter("names") as Iterable<String>;
      Map<String, String> campos =
          classMirror.invokeGetter("fields") as Map<String, String>;
      List<String> primary =
          classMirror.invokeGetter("primary") as List<String>;
      List<String> foreign =
          classMirror.invokeGetter("foreign") as List<String>;

      String sql =
          '''CREATE TABLE IF NOT EXISTS ${x.toString().toLowerCase()}s (''';

      for (var nombre in names) {
        sql = '$sql$nombre ${campos[nombre]}, ';
      }

      sql = '$sql PRIMARY KEY(';
      for (var primaryKey in primary) {
        if (primaryKey != primary.last) {
          sql = '$sql$primaryKey,';
        } else {
          if (foreign.isNotEmpty) {
            sql = '$sql$primaryKey),';
            for (var foreignKey in foreign) {
              if (foreignKey == foreign.last) {
                sql = '$sql$foreignKey';
              } else {
                sql = '$sql$foreignKey, ';
              }
            }
          } else {
            sql = '$sql$primaryKey)';
          }
        }
      }

      sql = '$sql);';
      await db.execute(sql);
    }
  }
}
