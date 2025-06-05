import 'package:test/test.dart';
import 'package:sqflite_simple_dao_backend/database/database/dao_connector.dart';
import 'package:sqflite_simple_dao_backend/database/database/sql_builder.dart';
import 'package:sqflite/sqflite.dart';

class FakeDatabase implements Database {
  final List<Map<String, Object?>> data;
  FakeDatabase(this.data);

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    return data;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestDao extends Dao {
  final Database db;
  TestDao(this.db);

  @override
  Future<Database?> getDatabase() async => db;
}

void main() {
  group('Dao.select', () {
    test('returns raw result when no model and non-primitive type', () async {
      final dao = TestDao(FakeDatabase([
        {'value': 1}
      ]));
      final builder = SqlBuilder.raw(rawSql: 'SELECT value FROM table');

      final result = await dao.select<dynamic>(sqlBuilder: builder);

      expect(result, isA<List<Map<String, Object?>>>());
    });

    test('returns typed primitives when model is null', () async {
      final dao = TestDao(FakeDatabase([
        {'value': 1},
        {'value': 2},
      ]));
      final builder = SqlBuilder.raw(rawSql: 'SELECT value FROM table');

      final result = await dao.select<int>(sqlBuilder: builder);

      expect(result, equals([1, 2]));
    });
  });
}
