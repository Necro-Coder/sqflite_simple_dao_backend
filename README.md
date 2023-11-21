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

TODO: List prerequisites and provide or point to information on how to
start using the package.

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
