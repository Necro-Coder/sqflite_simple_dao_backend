import 'package:example/database/entity/Model.dart';
import 'package:sqflite_simple_dao_backend/database/params/append.dart';

class Parameters {

  Parameters(){
    _constants();
    _dbParameters();
  }

  void _dbParameters(){
    Append.dbParameters(param: 'name', value: 'Test');
    Append.dbParameters(param: 'tables', value: [Model]);
    // Append.dbParameters(param: 'tables', value: Model, update: true);
    Append.dbParameters(param: 'version', value: 1);
  }

  void _constants(){
    Append.constant(type: 'varchar', key: '60', value: 'VARCHAR(10)');
    Append.constant(type: 'varchar', key: '60', value: 'VARCHAR(60)', override: true);
  }
}