import 'dart:io';

import 'package:sqflite_simple_dao_backend/database/utilities/print_handle.dart';

class GetReflector {
  GetReflector(){
    Process.run('dart run build_runner', [], runInShell: true);
  }
}