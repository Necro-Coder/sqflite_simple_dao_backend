import 'package:test/test.dart';
import 'package:sqflite_simple_dao_backend/database/database/sql_builder.dart';

void main() {
  group('SqlBuilder.queryOrder', () {
    test('valid input builds expected clause', () {
      final builder = SqlBuilder()
          .querySelect()
          .queryFrom(table: 'table')
          .queryOrder(fields: [
        ['col', 'ASC']
      ]);
      final sql = builder.build().trim();
      expect(sql, 'SELECT * FROM table ORDER BY col ASC');
    });

    test('throws when field list has more than two elements', () {
      final builder = SqlBuilder();
      expect(() => builder.queryOrder(fields: [
            ['col', 'ASC', 'EXTRA']
          ]), throwsA(isA<Exception>()));
    });
  });
}
