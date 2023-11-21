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

This package is created looking to simplify the traits with database using 
[reflectable](https://github.com/google/reflectable.dart) and [sqflite](https://github.com/tekartik/sqflite/tree/master/sqflite). 
This will helps you to make easier the dao creation in your flutter application. 

## Important
In order to use this package, you must have installed the [reflectable](https://github.com/google/reflectable.dart)
dependencies on your proyect. 

As well you have to do some things that are explained on getting started, so read carefully to understand
the behavior of this package. 

## Features

This package have the capacity to create database just with the name of the models you create. As the package 
creates de database, you have implemented the following features:
    - Dao: 
        - Insert: In this method, you just have to pass the object you want to insert on the database. 
        - Update: In this method, you just have to pass the object you want to update and the logic behind
        this method will compare the object in the database and update just the fields that change in order to 
        optimize the database access. 
        - Delete: In this method, you just have to pass the object you want to delete, as well you can specify 
        if you want to delete all the table just setting all = true.

    - Parameters: You will be able to change the database name, version (looking for updates in the database) and the 
    tables you want to create. 

    - Constants: You can change, modify and add constants that helps you to create the model structure that sqflite 
    recognize. This is an important feature to make the package able to cover all your needs. 

## Getting started

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
