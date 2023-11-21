import 'dart:convert';

import 'package:sqflite_simple_dao_backend/database/database/Reflectable.dart';
import 'package:sqflite_simple_dao_backend/database/params/constants.dart';

@reflector
class Model{
  int? nr;
  String? name;
  String? date;
  double? price;

  Model();


  Model.all({this.nr, this.name, this.date, this.price});

  static final Map<String, String> _campos = {
    'nr' : Constants.bigint,
    'name' : Constants.varchar['20']!,
    'date' : Constants.datetime,
    'price' : Constants.decimal['9,2']!
  };

  factory Model.fromRawJson(String str) =>
      Model.fromJson(json.decode(str));

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

  static final Iterable<String> _nombres = _campos.keys;

  static final List<String> _primary = [_nombres.elementAt(0)];
  static final List<String> _excepcion = [_nombres.elementAt(3)];

  static final List<String> _foreign = [];

  static List<String> get foreign => _foreign;

  static Map<String, String> get campos => _campos;

  static Iterable<String> get nombres => _nombres;

  static List<String> get primary => _primary;

  static List<String> get excepcion => _excepcion;
}