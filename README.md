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

This package is designed to simplify database interactions using [reflectable](https://github.com/google/reflectable.dart) and [sqflite](https://github.com/tekartik/sqflite/tree/master/sqflite). It aims to facilitate the creation of Data Access Objects (DAOs) in your Flutter application.

Index
-------------
- [Index](#index)
- [Prerequisites](#prerequisites)
- [Features](#features)
- [Getting Started](#getting_started)

    -   [Configuring the package reflectable](#configuring-the-package-reflectable)
    -   [Models structure](#models-structure)
    -   [Main.dart](#maindart)
    -   [Imports](#imports--you-can-copy-and-paste)
    -   [Method](#method--you-should-copy-and-paste)
    -   [Remember](#remember--important-)

-   [Usage](#usage)


Prerequisites
-------------

To use this package, you must have the [reflectable](https://github.com/google/reflectable.dart) dependency installed in your project. Please refer to the [Getting Started](#getting-started) section for more details on how to set up and use this package.

Features
--------

This package can automatically create a database based on the models you define. Once the database is created, the following features are available:

-   DAO Operations:

    -   **Insert:** Simply pass the object you wish to insert into the database.
    -   **Update:** Pass the object you wish to update. The logic behind this method will compare the object in the database and only update the fields that have changed, optimizing database access.
    -   **Delete:** Pass the object you wish to delete. You can also specify if you want to delete all the records in a table by setting `all = true`.
-   Parameters: You can modify the database name, version (for database updates), and the tables you wish to create.

-   Constants: You can add, modify, or change constants to help create a model structure that sqflite recognizes. This feature is crucial for customizing the package to meet your specific needs.

Getting Started
--------

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

import 'package:sqflite_simple_dao_backend/database/database/Reflectable.dart';
import 'package:sqflite_simple_dao_backend/database/params/constants.dart';

/* Important to use the sqflite_simple_dao_backend to import the @reflector */
@reflector
class Model{
  /* Variables we have in the model */
  int? nr;
  String? name;
  String? date;
  double? price;

  /* Empty constructor */
  Model();

  /* Named constructor with all the fields and named '.all()' */
  Model.all({this.nr, this.name, this.date, this.price});

  /* A map that contains the name of the fields and the database types. */
  static final Map<String, String> _fields = {
    'nr' : Constants.bigint,
    'name' : Constants.varchar['20']!,
    'date' : Constants.datetime,
    'price' : Constants.decimal['9,2']!
  };

  /* This factory to create objects from json */
  factory Model.fromRawJson(String str) =>
      Model.fromJson(json.decode(str));

  /* The fromJson */
  factory Model.fromJson(Map<String, dynamic> json) => Model.all(
    nr: json['nr'],
    name: json['name'],
    date: json['date'],
    price: json['price'],
  );

  /* The toJson */
  Map<String, dynamic> toJson() => {
    'nr': nr,
    'name': name,
    'date': date,
    'price': price,
  };

  /* An iterable object with all the keys in the fields map. */
  static final Iterable<String> _names = _fields.keys;

  /* A list with the primary key values */
  static final List<String> _primary = [_names.elementAt(0)];
  
  /* A exception list in order to remove some elements from the iteration */
  static final List<String> _exception = [_names.elementAt(3)];

  /* A list with the complete line (string) of a foreing key. Example behind.*/
  static final List<String> _foreign = [];
  /* Example: 'FOREIGN KEY (model_id) REFERENCES model (id)' */

  /* Getters and Setters*/
  static List<String> get foreign => _foreign;

  static Map<String, String> get fields => _fields;

  static Iterable<String> get names => _names;

  static List<String> get primary => _primary;

  static List<String> get exception => _exception;
}
```

The `@reflector` annotation is **NECESARY** to use the package.

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

Main example of using this package.

```dart
void insertNewReg() async {
  Dao dao = Dao();
  await dao.insert(Model.all(nr: 1, date: '2020-12-01', name: 'test', price: 15.25)); 
}
```
