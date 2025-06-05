<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->
# Introduction

This package is designed to simplify database interactions using [reflectable](https://github.com/google/reflectable.dart) and [sqflite](https://github.com/tekartik/sqflite/tree/master/sqflite). It aims to facilitate the creation of Data Access Objects (DAOs) in your Flutter application.

## Index

- [Index](#index)
- [Prerequisites](#prerequisites)
- [Features](#features)
- [Getting Started](#getting-started)

  - [Configuring the package reflectable](#configuring-the-package-reflectable)
  - [Models structure](#models-structure)
  - [Main.dart](#maindart)
  - [Imports](#imports-you-can-copy-and-paste)
  - [Method](#method-you-should-copy-and-paste)
  - [Remember](#remember-important)

- [Usage](#usage)

  - [Batch](#batch-methods)
    - [Batch Insert](#batch-insert)
      - [Batch Insert Usage](#batch-insert-usage)
    - [Batch Update](#batch-update)
      - [Batch Update Usage](#batch-update-usage)
    - [Batch Delete](#batch-delete)
      - [Batch Delete Usage](#batch-delete-usage)
    - [Batch Insert or Update](#batch-insert-or-update)
      - [Batch Insert or Update Usage](#batch-insert-or-update-usage)
    - [Batch Insert or Delete](#batch-insert-or-delete)
      - [Batch Insert or Delete Usage](#batch-insert-or-delete-usage)

## Prerequisites

To use this package, you must have the [reflectable](https://github.com/google/reflectable.dart) dependency installed in your project. Please refer to the [Getting Started](#getting-started) section for more details on how to set up and use this package.

## Features

This package can automatically create a database based on the models you define. Once the database is created, the following features are available:

- DAO Operations:

  - **Insert:** Simply pass the object you wish to insert into the database.
  - **Update:** Pass the object you wish to update. The logic behind this method will compare the object in the database and only update the fields that have changed, optimizing database access.
  - **Delete:** Pass the object you wish to delete.
  - **Select:** This functionality is designed to build a complex select query using familiar SQL syntax. It's simplified through the use of chaining methods, making the query construction process easier.

  (For more information go towards the [Batch](#batch-methods) section)
  - **Batch Insert:** Is designed to insert multiple records into a database in a single operation.
  - **Batch Update:**  Is designed to update multiple records into a database in a single operation.
  - **Batch Delete:**  Is designed to delete multiple records into a database in a single operation.
  - **Batch Insert or Update:** Is designed to insert or update multiple records into a database in a single operation.
  - **Batch Insert or Delete:** Is designed to insert or delete multiple records into a database in a single operation.

- Parameters: You can modify the database name, version (for database updates), and the tables you wish to create.

- Constants:You can add, modify, or change constants to help create a model structure that sqflite
  recognizes. This feature is crucial for customizing the package to meet your specific needs.
- The package also print logs in the console in order to display the changes on the database. Does not log in production.

## Getting Started

### Configuring the package [reflectable](https://github.com/google/reflectable.dart)

Firstly, you need to install the [reflectable](https://github.com/google/reflectable.dart) package from [pub.dev](https://pub.dev/packages/reflectable).
Once installed, you should create a `build.yaml` file with the following structure:

```yaml
targets:
  $default:
    builders:
      reflectable:
        generate_for:
          - lib/database/entity/**.dart # Here your entity directory
        options:
          formatted: true
```

I recommend keeping all the entities in a single folder for ease of use with  [reflectable](https://github.com/google/reflectable.dart).

Next, you need to create a `builder.dart` file. It will always look like this:

```dart
import 'package:reflectable/reflectable_builder.dart' as builder;

main(List<String> arguments) async {
  await builder.reflectableBuild(arguments);
}
```

Once this is done, we can proceed with the models.

### Models structure

When creating the models, you must adhere to a strict structure. Given that reflection uses the *metadata* of our objects, we need to be very meticulous with this.

The structure is as follows: *(The name of the entity will be the name of the table)*

```dart
import 'dart:convert';

import 'package:example/database/model_dao.dart';
import 'package:sqflite_simple_dao_backend/database/database/Reflectable.dart';
import 'package:sqflite_simple_dao_backend/database/params/constants.dart';

@reflector
class Model extends ModelDao {
  int? nr;
  String? name;
  String? date;
  double? price;

  Model();

  Model.all({this.nr, this.name, this.date, this.price});

  static final Map<String, String> _fields = {
    'nr': Constants.bigint,
    'name': Constants.varchar['20']!,
    'date': Constants.datetime,
    'price': Constants.decimal['9,2']!
  };

  factory Model.fromRawJson(String str) => Model.fromJson(json.decode(str));

  factory Model.fromJson(Map<String, dynamic> json) => Model.all(
        nr: json['nr'],
        name: json['name'],
        date: json['date'],
        price: json['price'],
      );

  Map<String, dynamic> toJson() => {
        'nr': nr,
        'name': name,
        'date': date,
        'price': price,
      };

  static final Iterable<String> _names = _fields.keys;

  static final List<String> _primary = [_names.elementAt(0)];
  static final List<String> _exception = [_names.elementAt(3)];

  static final List<String> _foreign = [];

  static List<String> get foreign => _foreign;

  static Map<String, String> get fields => _fields;

  static Iterable<String> get names => _names;

  static List<String> get primary => _primary;

  static List<String> get exception => _exception;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Model && other.nr == nr;
  }

  @override
  int get hashCode {
    return nr.hashCode;
  }
}

```

The `@reflector` annotation is **NECESSARY** to use the package.

Once we have done this, we need to finish a couple of settings in `main.dart`.

### Main.dart

The first thing is to use `WidgetsFlutterBinding.ensureInitialized();` to initialize the communication between the **Dart** layer and the **Flutter** engine. This is especially important for correctly initializing the database.

Next, I strongly recommend creating a class called `Parameters` where we will have all the parameters we want from the database. In my case, it would look something like this:

```dart
import 'package:example/database/entity/Model.dart';
import 'package:sqflite_simple_dao_backend/database/params/append.dart';

/* Remember to use the sqflite_simple_dao_backend */
class Parameters {

  Parameters(){
    _constants();
    _dbParameters();
  }

  void _dbParameters(){
    Append.dbParameters(param: 'name', value: 'Test');
    Append.dbParameters(param: 'tables', value: [Model]);
    Append.dbParameters(param: 'version', value: 1);
    
    /* This will be used in case you have to modify the database */
    // Append.dbParameters(param: 'tables', value: Model, update: true);
  }

  void _constants(){
    Append.constant(type: 'varchar', key: '60', value: 'VARCHAR(10)');
    Append.constant(type: 'varchar', key: '60', value: 'VARCHAR(60)', override: true);
  }
}
```

After all this, we only have one thing left to do to get everything working. *Initialize reflection*.

To initialize reflection, we must import the [reflectable](https://github.com/google/reflectable.dart) package and a class that will be created, as well as having the method called beforehand. At first, some errors will appear but they will disappear quickly.

#### Imports: *(You can copy and paste)*

```dart
import 'package:reflectable/reflectable.dart';
import 'main.reflectable.dart';
```

#### Method: *(You should copy and paste)*

```dart
initializeReflectable();
```

Both the `Parameters` class, `initializeReflectable`, and `WidgetsFlutterBinding.ensureInitialized()` must be initialized in the `main` like this:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Parameters();
  initializeReflectable();
  runApp(const MyApp());
}
```

Once we have this, we are ready to get everything up and running.

We go to the console and write the following command:

```bash
dart lib/builder.dart lib/main.dart
```

Now it will create a file called `main.reflectable.dart`. We enter and we have to check that all the lines of code have been correctly created for the classes we have with the `@reflector`.

It would look something like this: **(This is only a part of the code, there may be much more)**

```dart
import 'dart:core';
import 'package:example/database/entity/Model.dart' as prefix1;
import 'package:sqflite_simple_dao_backend/database/database/Reflectable.dart'
as prefix0;

// ignore_for_file: camel_case_types
// ignore_for_file: implementation_imports
// ignore_for_file: prefer_adjacent_string_concatenation
// ignore_for_file: prefer_collection_literals
// ignore_for_file: unnecessary_const

// ignore:unused_import
import 'package:reflectable/mirrors.dart' as m;
// ignore:unused_import
import 'package:reflectable/src/reflectable_builder_based.dart' as r;
// ignore:unused_import
import 'package:reflectable/reflectable.dart' as r show Reflectable;

final _data = <r.Reflectable, r.ReflectorData>{
const prefix0.MyReflectable(): r.ReflectorData(
<m.TypeMirror>[
r.NonGenericClassMirrorImpl(
r'Model',
r'.Model',
134217735,
0,
const prefix0.MyReflectable(),
const <int>[0, 1, 2, 3, 4, 13, 14, 15, 16, 17, 18, 19, 20, 21],
const <int>[22, 23, 24, 25, 26, 4, 5, 6, 7, 8, 9, 10, 11, 12],
const <int>[13, 14, 15, 16, 17],
-1,
```

If this code does not appear, you should check for errors in the installation. If there are no errors and it still does not appear, run the command again. If you continue to have problems, you can contact me at <nunezcotanoruben@gmail.com>

### Remember (Important)

This Dart command needs to be executed in case you modify anything about the [reflectable](https://github.com/google/reflectable.dart) package.

```bash
dart lib/builder.dart lib/main.dart
```

## Usage

This package is designed for ease of use. The implementation is straightforward, just as I would prefer to use this package.
To see this working I recommend to check the example.

First, we have to create the 'ModelDao' class, in witch we will have the generic methods of the Dao that we will use with the models.

In my case I only implement the basic Dao in order to insert, delete or update directly from the object. But you can implement the methods that you consider.

So, this class extends the 'Dao' class from the package.

Then, the models extends from 'ModelDao'. And it's all. Now you can insert, delete and update using a method in the model.

Here is an example.

This is the ModelDao class.

```dart
import 'package:sqflite_simple_dao_backend/database/database/dao_connector.dart';

class ModelDao extends Dao {
  ModelDao() : super();

  Future<int> insert() async {
    return await super.insertSingle(objectToInsert: this);
  }

  Future<int> update() async {
    return await super.updateSingle(objectToUpdate: this);
  }

  Future<int> delete() async {
    return await super.deleteSingle(objectToDelete: this);
  }
}
```

This is the model.

```dart
@reflector
class Model extends ModelDao {
  int? nr;
  String? name;
  String? date;
  double? price;
```

Now you can use it like this.

```dart
await models[0].insert();

await models[0].update();

await models[0].delete();
```

### Batch Methods

The batch methods are designed to perform an operation (like insert, update, or delete) on multiple data items at once, rather than individually. This can significantly improve performance when dealing with large amounts of data, as it reduces the number of individual database transactions.

#### Batch Insert

Performs a batch insert operation on a table.

This method takes a list of [objectsToInsert] as a parameter and performs a batch insert operation.
It first performs a select operation on the table corresponding to the type of the first object in the list.
It then creates two sets: one from the result of the select operation and another from the input [objectsToInsert].

It calls the `_getDifferenceList` method with these two sets as parameters to get a list of new objects that need to be inserted into the table.

It then performs a batch insert operation with the new objects.
The total number of rows affected by this operation is returned.

This method is useful when you have a list of objects and you want to insert new objects into the table in a single operation.

##### Batch Insert Usage

```dart
var objectsToInsert = [object1, object2, object3];
int result = await daoConnector.batchInsert(objectsToInsert: objectsToInsert);
print('Number of rows inserted: $result');
```

#### Batch Update

Performs a batch insert or update operation on a table.

This method takes a list of [objects] as a parameter and performs a batch insert or update operation.
It first performs a select operation on the table corresponding to the type of the first object in the list.
It then creates two sets: one from the result of the select operation and another from the input [objects].

It calls the `_getDifferenceList` method with these two sets as parameters to get a list of new objects that need to be inserted into the table.
It also calls the `_getIntersectionList` method with these two sets as parameters to get a list of existing objects that need to be updated in the table.

It then performs a batch insert operation with the new objects and a batch update operation with the existing objects.
The total number of rows affected by these operations is returned.

This method is useful when you have a list of objects and you want to insert new objects into the table and update existing objects in a single operation.

##### Batch Update Usage

```dart
var objects = [object1, object2, object3];
int result = await daoConnector.batchInsertOrUpdate(objects: objects);
print('Number of rows affected: $result');
```

#### Batch Delete

Performs a batch delete operation on a table.

This method takes a list of [objectsToDelete] as a parameter and performs a batch delete operation.
It first gets the database instance and starts a batch operation.
Then, for each object in the listcd  of objects to delete, it uses reflection to get
the primary key(s) of the object. It constructs a WHERE clause for the delete
operation using the primary key(s) and their values.

It then adds the delete operation to the batch. The table name for the delete operation
is obtained by calling the `getTableName` method with the object.

Finally, it commits the batch and returns the number of operations in the batch.
If an error occurs during the delete operation, the method logs the error and returns -1.

This method is useful when you have a list of objects and you want to delete them from the table in a single operation.

##### Batch Delete Usage

```dart
var objectsToDelete = [object1, object2, object3];
int result = await daoConnector.batchDelete(objectsToDelete: objectsToDelete);
print('Number of rows deleted: $result');
```

#### Batch Insert or Update

Performs a batch insert or update operation on a table.

This method takes a list of [objects] as a parameter and performs a batch insert or update operation.
It first performs a select operation on the table corresponding to the type of the first object in the list.
It then creates two sets: one from the result of the select operation and another from the input [objects].

It calls the `_getDifferenceList` method with these two sets as parameters to get a list of new objects that need to be inserted into the table.
It also calls the `_getIntersectionList` method with these two sets as parameters to get a list of existing objects that need to be updated in the table.

It then performs a batch insert operation with the new objects and a batch update operation with the existing objects.
The total number of rows affected by these operations is returned.

This method is useful when you have a list of objects and you want to insert new objects into the table and update existing objects in a single operation.

##### Batch Insert or Update Usage

```dart
var objects = [object1, object2, object3];
int result = await daoConnector.batchInsertOrUpdate(objects: objects);
print('Number of rows affected: $result');
```

#### Batch Insert or Delete

Performs a batch insert or delete operation on a table.

This method takes a list of [objects] as a parameter and performs a batch insert or delete operation.
It first performs a select operation on the table corresponding to the type of the first object in the list.
It then creates two sets: one from the result of the select operation and another from the input [objects].

It calls the `_getDifferenceList` method with these two sets as parameters to get a list of new objects that need to be inserted into the table.
It also calls the `_getIntersectionList` method with these two sets as parameters to get a list of existing objects that need to be deleted from the table.

It then performs a batch insert operation with the new objects and a batch delete operation with the existing objects.
The total number of rows affected by these operations is returned.

This method is useful when you have a list of objects and you want to insert new objects into the table and delete existing objects in a single operation.

##### Batch Insert or Delete Usage

```dart
var objects = [object1, object2, object3];
int result = await daoConnector.batchInsertOrDelete(objects: objects);
print('Number of rows affected: $result');
```
