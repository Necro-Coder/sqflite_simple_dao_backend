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

This package is designed to simplify database interactions using [reflectable](https://github.com/google/reflectable.dart) and [sqflite](https://github.com/tekartik/sqflite/tree/master/sqflite). . It aims to facilitate the creation of Data Access Objects (DAOs) in your Flutter application.

Prerequisites
-------------

To use this package, you must have the [reflectable](https://github.com/google/reflectable.dart) dependency installed in your project. Please refer to the [Getting Started](#gettingstarted) section for more details on how to set up and use this package.

Features
--------

This package can automatically create a database based on the models you define. Once the database is created, the following features are available:

-   DAO Operations:

    -   **Insert:** Simply pass the object you wish to insert into the database.
    -   **Update:** Pass the object you wish to update. The logic behind this method will compare the object in the database and only update the fields that have changed, optimizing database access.
    -   **Delete:** Pass the object you wish to delete. You can also specify if you want to delete all the records in a table by setting `all = true`.
-   Parameters: You can modify the database name, version (for database updates), and the tables you wish to create.

-   Constants: You can add, modify, or change constants to help create a model structure that sqflite recognizes. This feature is crucial for customizing the package to meet your specific needs.

Geting Started
--------

### Configuring the package [reflectable](https://github.com/google/reflectable.dart)
First of all, you need to install the [reflectable](https://github.com/google/reflectable.dart) package from [pub.dev](https://pub.dev/packages/reflectable).
Onces you have it. You have to create the `build.yaml` with this structure:

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
I recomend to have all the entities only in one folder in order to make easy to use [reflectable](https://github.com/google/reflectable.dart). 

Then. You must create the `builder.dart`. It always going to be like this:

```dart
import 'package:reflectable/reflectable_builder.dart' as builder;

main(List<String> arguments) async {
  await builder.reflectableBuild(arguments);
}
```

When all this is done. We can continue with the models. 

### Models structure
You must have a strict structure when creating the models. Taking into account that reflexion is
using the *metadata* of out objects, we have to be so clean with this. 

The structure: *The name of the entity will be the name of the table*
```dart
import 'dart:convert';

import 'package:sqflite_simple_dao_backend/database/database/Reflectable.dart';
import 'package:sqflite_simple_dao_backend/database/params/constants.dart';

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

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
