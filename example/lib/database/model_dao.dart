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
