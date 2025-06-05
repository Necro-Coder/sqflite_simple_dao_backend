import 'package:meta/meta.dart';
import 'package:sqflite_simple_dao_backend/database/utilities/print_handle.dart';

/// `SqlBuilder` is a class that helps in building SQL queries in a structured manner.
class SqlBuilder {
  /// Default constructor for the `SqlBuilder` class.
  ///
  /// This constructor initializes an empty `SqlBuilder` instance.
  SqlBuilder();

  /// Named constructor for the `SqlBuilder` class that accepts a raw SQL query.
  ///
  /// This constructor initializes an `SqlBuilder` instance with a raw SQL query.
  ///
  /// The `rawSql` parameter is required and it should contain the raw SQL query string.
  ///
  /// Usage:
  /// ```dart
  /// var builder = SqlBuilder.raw(rawSql: 'SELECT * FROM table');
  /// ```
  SqlBuilder.raw({@required required String rawSql}) {
    _rawSql = rawSql;
  }

  /// `constOperators` is a constant map that maps operator names to their SQL equivalents.
  ///
  /// This map is used to convert operator names in the query building process to their actual SQL syntax.
  ///
  /// The keys are the operator names in camel case and the values are the corresponding SQL operators.
  ///
  /// May be there is some operator that you can't use for now, but I will add functionality for this operators in the future.
  /// Here is what each key-value pair represents:
  /// * 'equals': '=' - Represents the SQL equality operator.
  /// * 'notEquals': '<>' - Represents the SQL inequality operator.
  /// * 'greaterThan': '>' - Represents the SQL greater than operator.
  /// * 'greaterThanOrEquals': '>=' - Represents the SQL greater than or equal to operator.
  /// * 'lessThan': '<' - Represents the SQL less than operator.
  /// * 'lessThanOrEquals': '<=' - Represents the SQL less than or equal to operator.
  /// * 'like': 'LIKE' - Represents the SQL LIKE operator for pattern matching.
  /// * 'notLike': 'NOT LIKE' - Represents the SQL NOT LIKE operator for pattern matching.
  /// * 'between': 'BETWEEN' - Represents the SQL BETWEEN operator for range checking.
  /// * 'notBetween': 'NOT BETWEEN' - Represents the SQL NOT BETWEEN operator for range checking.
  /// * 'in': 'IN' - Represents the SQL IN operator for checking if a value is within a set of values.
  /// * 'notIn': 'NOT IN' - Represents the SQL NOT IN operator for checking if a value is not within a set of values.
  /// * 'isNull': 'IS NULL' - Represents the SQL IS NULL operator for checking if a value is NULL.
  /// * 'isNotNull': 'IS NOT NULL' - Represents the SQL IS NOT NULL operator for checking if a value is not NULL.
  /// * 'exists': 'EXISTS' - Represents the SQL EXISTS operator for checking if a subquery returns any row.
  /// * 'notExists': 'NOT EXISTS' - Represents the SQL NOT EXISTS operator for checking if a subquery does not return any row.
  /// * 'and': 'AND' - Represents the SQL AND operator for combining boolean expressions.
  /// * 'or': 'OR' - Represents the SQL OR operator for combining boolean expressions.
  /// * 'not': 'NOT' - Represents the SQL NOT operator for negating a boolean expression.
  /// * 'distinct': 'DISTINCT' - Represents the SQL DISTINCT keyword for selecting unique rows.
  /// * 'asc': 'ASC' - Represents the SQL ASC keyword for sorting in ascending order.
  /// * 'desc': 'DESC' - Represents the SQL DESC keyword for sorting in descending order.
  /// * 'innerJoin': 'INNER JOIN' - Represents the SQL INNER JOIN operator for combining rows from two or more tables.
  /// * 'leftJoin': 'LEFT JOIN' - Represents the SQL LEFT JOIN operator for combining rows from two or more tables.
  /// * 'crossJoin': 'CROSS JOIN' - Represents the SQL CROSS JOIN operator for producing the Cartesian product of two tables.
  static final Map<String, String> constOperators = {
    'equals': '=',
    'notEquals': '<>',
    'greaterThan': '>',
    'greaterThanOrEquals': '>=',
    'lessThan': '<',
    'lessThanOrEquals': '<=',
    'like': 'LIKE',
    'notLike': 'NOT LIKE',
    'between': 'BETWEEN',
    'notBetween': 'NOT BETWEEN',
    'in': 'IN',
    'notIn': 'NOT IN',
    'isNull': 'IS NULL',
    'isNotNull': 'IS NOT NULL',
    'exists': 'EXISTS',
    'notExists': 'NOT EXISTS',
    'and': 'AND',
    'or': 'OR',
    'not': 'NOT',
    'distinct': 'DISTINCT',
    'asc': 'ASC',
    'desc': 'DESC',
    'innerJoin': 'INNER JOIN',
    'leftJoin': 'LEFT JOIN',
    'crossJoin': 'CROSS JOIN',
  };

  final List<String> _select = [];
  String? _rawSql;
  var _error = '⛔sqflite_simple_dao_backend⛔: ';

  /// Builds the SQL query string from the `SqlBuilder` instance.
  ///
  /// This method constructs the SQL query string by joining the statements in the `_select` list.
  /// It also performs various checks to ensure that the SQL query is valid.
  ///
  /// The `print` parameter is optional and defaults to `false`. If `print` is `true`, the final SQL query string is logged using `PrintHandler.warningLogger.i()`.
  ///
  /// The method throws an `Exception` if the SQL query is invalid. For example, if the 'select' statement is not the first one in the `_select` list, or if the 'select' statement is missing.
  ///
  /// The flow of the method is as follows:
  /// 1. It initializes a `statements` map with keys as SQL statement names and values as `Statement` objects.
  /// 2. If `_select` list is empty and `_rawSql` is not null and valid, it returns `_rawSql`.
  /// 3. If `_select` list is not empty, it iterates over the list and performs the following checks:
  ///    - If the statement name is 'select' and it's not the first statement, it logs an error and throws an `Exception`.
  ///    - It checks the index of the current statement and the count of the same type of statements.
  /// 4. It joins the `_select` list into a string to form the final SQL query.
  /// 5. If `print` is `true`, it logs the final SQL query.
  /// 6. It returns the final SQL query.
  /// 7. If `_select` list is empty and `_rawSql` is null or invalid, it logs an error and throws an `Exception`.
  ///
  /// It's important to note that the `select` method of the DAO uses this method to create the SQL query. Therefore, it's not necessary to make a raw query with this method. The use of this method is primarily for debugging or similar purposes.
  ///
  /// Usage:
  /// ```dart
  /// String sentence = SqlBuilder().addTheStatementsToTheBuilder().build(print: true);
  /// ```
  ///
  /// Returns the final SQL query string.
  String build({bool print = false}) {
    var statements = {
      'select': Statement('select', 0),
      'from': Statement('from', 0),
      'join': Statement('join', 0),
      'where': Statement('where', 0),
      'order': Statement('order', 0),
      'limit': Statement('limit', 0),
    };
    if (_select.isEmpty && _rawSql != null && _checkStatement(_rawSql!)) {
      return _rawSql!;
    } else if (_select.isNotEmpty) {
      for (var index = 0; index < _select.length; index++) {
        var statementName = _select[index].split(' ')[0].toLowerCase();

        if (statements.containsKey(statementName)) {
          var statement = statements[statementName];

          if (statementName == 'select' && index != 0) {
            _error +=
                'The select statement must be the first one in the sentence.';
            PrintHandler.warningLogger.e(_error);
            throw Exception(_error);
          } else {
            _checkIndex(index, _select.length, statementName,
                isLimit: statementName == 'limit');
            _checkIndexCount(statement!.index, statementName);
            statement.index++;
          }
        }
      }
      var finalSql = _select.join();
      if (print) {
        PrintHandler.warningLogger.i(finalSql);
      }
      return finalSql;
    } else {
      _error += 'The select statement is required.';
      PrintHandler.warningLogger.e(_error);
      throw Exception(_error);
    }
  }

  /// Adds a 'SELECT' statement to the SQL query.
  ///
  /// The `fields` parameter is optional and defaults to `['*']`. It should contain the list of fields to select.
  ///
  /// This method adds a 'SELECT' statement to the `_select` list and then returns the `SqlBuilder` instance for method chaining.
  ///
  /// Usage:
  /// ```dart
  /// var builder = SqlBuilder();
  /// builder.querySelect(fields: ['field1', 'field2']);
  /// ```
  SqlBuilder querySelect({List<String> fields = const ['*']}) {
    _select.add('SELECT ${fields.join(', ')} ');
    return this;
  }

  /// Adds a 'WHERE' clause to the SQL query.
  ///
  /// The `conditions` parameter is optional and defaults to an empty list. It should contain the list of conditions for the 'WHERE' clause.
  ///
  /// This method adds a 'WHERE' clause to the `_select` list and then returns the `SqlBuilder` instance for method chaining.
  ///
  /// Usage:
  /// ```dart
  /// var builder = SqlBuilder();
  /// builder.queryWhere(conditions: ['field1 = value1', 'field2 = value2']);
  /// ```
  SqlBuilder queryWhere({List<String> conditions = const []}) {
    _select.add('WHERE ${conditions.join(' ')} ');
    return this;
  }

  /// Adds a 'FROM' clause to the SQL query.
  ///
  /// The `table` parameter is optional and defaults to an empty string. It should contain the name of the table for the 'FROM' clause.
  ///
  /// This method adds a 'FROM' clause to the `_select` list and then returns the `SqlBuilder` instance for method chaining.
  ///
  /// Usage:
  /// ```dart
  /// var builder = SqlBuilder();
  /// builder.queryFrom(table: 'tableName');
  /// ```
  SqlBuilder queryFrom({String table = ''}) {
    _select.add('FROM $table ');
    return this;
  }

  /// Adds a 'JOIN' clause to the SQL query.
  ///
  /// The `table` and `on` parameters are required. `table` should contain the name of the table to join, and `on` should contain the join condition.
  /// The `join` parameter is optional and defaults to 'INNER JOIN'. It should contain the type of join to perform. Use constants from the `SqlBuilder.constOperators` map to specify the join type.
  ///
  /// This method adds a 'JOIN' clause to the `_select` list and then returns the `SqlBuilder` instance for method chaining.
  ///
  /// Usage:
  /// ```dart
  /// var builder = SqlBuilder();
  /// builder.queryJoin(table: 'table2', on: 'table1.id = table2.id');
  /// ```
  SqlBuilder queryJoin(
      {@required required String table,
      @required required String on,
      String join = 'INNER JOIN'}) {
    _select.add('$join $table ON $on ');
    return this;
  }

  /// Adds an 'ORDER BY' clause to the SQL query.
  ///
  /// The `fields` parameter is optional and defaults to an empty list. It should contain the list of fields to order by and the order direction (ASC or DESC).
  ///
  /// This method adds an 'ORDER BY' clause to the `_select` list and then returns the `SqlBuilder` instance for method chaining.
  ///
  /// Usage:
  /// ```dart
  /// var builder = SqlBuilder();
  /// builder.queryOrder(fields: [['field1', 'ASC'], ['field2', 'DESC']]);
  /// ```
  SqlBuilder queryOrder({List<List<String>> fields = const []}) {
    if (fields.isEmpty) {
      return this;
    }
    List<String> cases = [];
    for (var field in fields) {
      if (field.length > 2) {
        _error +=
            'The order statement must have a maximum of two fields. field (ASC|DESC),)';
        PrintHandler.warningLogger.e(_error);
        throw Exception(_error);
      }
      cases.add('${field[0]} ${field[1]}');
    }
    _select.add('ORDER BY ${cases.join(', ')} ');
    return this;
  }

  /// Adds a 'LIMIT' clause to the SQL query.
  ///
  /// The `limit` parameter is optional and defaults to an empty string. It should contain the limit for the 'LIMIT' clause.
  ///
  /// This method adds a 'LIMIT' clause to the `_select` list and then returns the `SqlBuilder` instance for method chaining.
  ///
  /// Usage:
  /// ```dart
  /// var builder = SqlBuilder();
  /// builder.queryLimit(limit: '10');
  /// ```
  SqlBuilder queryLimit({String limit = ''}) {
    _select.add('LIMIT $limit ');
    return this;
  }

  /// Creates a 'COUNT' function for the SQL query.
  ///
  /// The `fields` parameter is optional and defaults to `['*']`. It should contain the list of fields to count.
  /// The `all` parameter is optional and defaults to `true`. If `all` is `true`, the method counts all fields. If `all` is `false`, the method counts only distinct fields.
  ///
  /// This method returns a 'COUNT' function as a string.
  ///
  /// Usage:
  /// ```dart
  /// var count = SqlBuilder.queryCount(fields: ['field1', 'field2'], all: false);
  /// ```
  static String queryCount(
      {List<String> fields = const ['*'], bool all = true}) {
    var sentence = '';
    if (all) {
      sentence = 'COUNT(${fields.join(', ')})';
    } else {
      sentence = 'COUNT(DISTINCT ${fields.join(', ')})';
    }
    return sentence;
  }

  /// Creates a subselect for the SQL query.
  ///
  /// The `sqlBuilder` parameter is required. It should contain an instance of `SqlBuilder` that represents the subselect.
  ///
  /// This method returns a subselect as a string.
  ///
  /// Usage:
  /// ```dart
  /// var subselect = SqlBuilder.querySubSelect(sqlBuilder);
  /// ```
  static String querySubSelect(SqlBuilder sqlBuilder) {
    return '(${sqlBuilder.build()})';
  }

  void _checkIndex(int index, int length, String statement,
      {bool isLimit = false}) {
    if (index == 0 && statement != 'select') {
      _error +=
          'The $statement statement must be the first one in the sentence.';
      PrintHandler.warningLogger.e(_error);
      throw Exception(_error);
    }
    if ((isLimit && index != length - 1)) {
      _error +=
          'The $statement statement must be the last one in the sentence.';
      PrintHandler.warningLogger.e(_error);
      throw Exception(_error);
    }
  }

  void _checkIndexCount(int indexCount, String statement) {
    if (indexCount != 0) {
      _error += 'The $statement statement must be only once in the sentence.';
      PrintHandler.warningLogger.e(_error);
      throw Exception(_error);
    }
  }

  bool _checkStatement(String statement) {
    List<String> expectedOrder = [
      'select',
      'from',
      'join',
      'where',
      'group',
      'order',
      'limit'
    ];
    var statementList = statement.toLowerCase().splitMapJoin(' ');
    int lastIndex = -1;
    for (var statement in expectedOrder) {
      int currentIndex = statementList.indexOf(statement);
      if (currentIndex != -1) {
        if (currentIndex < lastIndex) {
          _error +=
              'The `$statement` statement is out of order. The expected order is: $expectedOrder';
          PrintHandler.warningLogger.e(_error);
          throw Exception(_error);
        }
        lastIndex = currentIndex;
      }
    }
    if (!statementList.contains('select')) {
      _error += 'The `select` statement is required.';
      PrintHandler.warningLogger.e(_error);
      throw Exception(_error);
    } else if (!statementList.contains('from')) {
      _error += 'The `from` statement is required.';
      PrintHandler.warningLogger.e(_error);
      throw Exception(_error);
    } else {
      return true;
    }
  }
}

class Statement {
  final String name;
  int index;

  Statement(this.name, this.index);
}
