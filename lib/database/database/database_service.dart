import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:reflectable/mirrors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_simple_dao_backend/database/params/db_parameters.dart';

import 'Reflectable.dart';

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

  Future<Database?> initDB() async {
    // Path de donde almacenaremos la base de datos.
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentDirectory.path, '${DbParameters.dbName}.db');

    // Crear la base de datos
    return await openDatabase(
      path,
      version: DbParameters.dbVersion,
      onOpen: (db) {},
      onCreate: (db, version) async {
        /*
        * Creamos las tablas mediante reflexión.
        */
        for (var x in DbParameters.tables) {
          /*
          * Esta variable nos permite recoger cada una de las clases de
          * la tabla "tablas" para poder usar las variables que contiene.
          */
          var classMirror = reflector.reflectType(x) as ClassMirror;

          /*
          * Creamos las listas que vamos a usar para crear las tablas.
          */
          Iterable<String> nombres =
          classMirror.invokeGetter("names") as Iterable<String>;
          Map<String, String> campos =
          classMirror.invokeGetter("fields") as Map<String, String>;
          List<String> primary =
          classMirror.invokeGetter("primary") as List<String>;
          List<String> foreign =
          classMirror.invokeGetter("foreign") as List<String>;

          //Sentencia SQL
          String sql = '''CREATE TABLE IF NOT EXISTS $x (''';

          /*
          * Vamos a recorrer el iterable nombres para sacar cada uno de los
          * campos y con la tabla campos vamos a obtener el tipo de dato.
          * De esta forma creamos la sentencia casi completa.
          */
          for (var nombre in nombres) {
            sql = '$sql$nombre ${campos[nombre]}, ';
          }

          /*
          * Aquí añadimos el PRIMARY KEY recorriendo la tabla de la clase
          */
          sql = '$sql PRIMARY KEY(';
          for (var primaryKey in primary) {
            if (primaryKey != primary.last) {
              sql = '$sql$primaryKey,';
            } else {
              /*
              * En esta parte del código estamos comprobando si la tabla
              * tiene foreign keys, creando las sentencias que ya tenemos
              * en la lista de foreign de las clases.
              */
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
          /* Ejecutamos la sentencia que hemos creado */
          await db.execute(sql);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        switch (oldVersion) {
          default:
          /*
            * Con este valor por defecto, siempre que haya una versión
            * nueva vamos a crear las tablas nuevas de la base de datos
            * ya que solo va a crear las tablas que no existan anteriormente
            * en esta.
            */
            for (var x in DbParameters.tables) {
              var classMirror = reflector.reflectType(x) as ClassMirror;
              Iterable<String> nombres =
              classMirror.invokeGetter("names") as Iterable<String>;
              Map<String, String> campos =
              classMirror.invokeGetter("fields") as Map<String, String>;
              List<String> primary =
              classMirror.invokeGetter("primary") as List<String>;
              List<String> foreign =
              classMirror.invokeGetter("foreign") as List<String>;

              String sql = '''CREATE TABLE IF NOT EXISTS $x (''';
              for (var i in nombres) {
                sql = '$sql$i ${campos[i]}, ';
              }
              sql = '$sql PRIMARY KEY(';
              for (var u in primary) {
                if (u != primary.last) {
                  sql = '$sql$u,';
                } else {
                  if (foreign.isNotEmpty) {
                    sql = '$sql$u),';
                    for (var f in foreign) {
                      if (f == foreign.last) {
                        sql = '$sql$f';
                      } else {
                        sql = '$sql$f, ';
                      }
                    }
                  } else {
                    sql = '$sql$u)';
                  }
                }
              }

              sql = '$sql);';
              await db.execute(sql);
            }
        }
      },
    );
  }
}
