import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sqflite_simple_dao_backend/database/dao_connector.dart';

class MockMyClass extends Mock implements Dao {}

void main() {
  group('insert', () {
    test('should return result of dao.newReg when query returns an empty list',
        () async {
      // Arrange
      var mockMyClass = MockMyClass();
      var newReg = 'newReg';
      when(mockMyClass.query(newReg)).thenAnswer((_) async => []);
      when(mockMyClass.dao.newReg(newReg)).thenAnswer((_) async => 1);

      // Act
      var result = await mockMyClass.insert(newReg);

      // Assert
      expect(result, 1);
    });

    test('should return -1 when query does not return an empty list', () async {
      // Arrange
      var mockMyClass = MockMyClass();
      var newReg = 'newReg';
      when(mockMyClass.query(newReg)).thenAnswer((_) async => ['oldReg']);

      // Act
      var result = await mockMyClass.insert(newReg);

      // Assert
      expect(result, -1);
    });
  });
}
