import 'package:example/database/Parameters.dart';
import 'package:example/database/entity/Model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_simple_dao_backend/database/dao_connector.dart';
import 'package:sqflite_simple_dao_backend/database/database/sql_builder.dart';
import 'package:sqflite_simple_dao_backend/database/utilities/print_handle.dart';
import 'main.reflectable.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Parameters();
  initializeReflectable();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    Dao dao = Dao();

    List<Model> models = [
      Model.all(nr: 1, date: '2020-12-01', name: 'test1', price: 15.25),
      Model.all(nr: 2, date: '2020-12-02', name: 'test2', price: 15.25),
      Model.all(nr: 3, date: '2020-12-03', name: 'test3', price: 15.25),
      Model.all(nr: 4, date: '2020-12-04', name: 'test4', price: 15.25),
      Model.all(nr: 5, date: '2020-12-05', name: 'test5', price: 15.25),
      Model.all(nr: 6, date: '2020-12-06', name: 'test6', price: 15.25),
      Model.all(nr: 7, date: '2020-12-07', name: 'test7', price: 15.25),
    ];

    await dao.insertSingle(objectToInsert: models[0]);

    await dao.batchInsert(objectsToInsert: models.sublist(1));

    PrintHandler.warningLogger.t('Printing data before update and delete');
    await printData(dao);
    models[0].price = 20.25;
    await dao.updateSingle(objectToUpdate: models[0]);

    // await dao.batchUpdate(objectsToUpdate: models.sublist(1));

    PrintHandler.warningLogger
        .t('Printing data after update and before delete');

    await printData(dao);

    PrintHandler.warningLogger.t('Printing full model');
    var modelsResult = await dao.select<Model>(
        sqlBuilder: SqlBuilder().querySelect().queryFrom(table: 'models'),
        model: Model(),
        print: true);

    for (var x in modelsResult) {
      PrintHandler.warningLogger.i(x.toJson());
    }

    await dao.deleteSingle(objectToDelete: models[0]);

    await dao.batchDelete(objectsToDelete: models.sublist(1, 3));

    PrintHandler.warningLogger.t('Printing data after delete');

    await printData(dao);

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> printData(Dao dao) async {
    var response = await dao.select(
        sqlBuilder: SqlBuilder()
            .querySelect(fields: [
              'nr',
              'date',
              'name',
              'price',
            ])
            .queryFrom(table: 'models')
            .queryOrder());
    for (var element in response) {
      PrintHandler.warningLogger.i(
          'nr: ${element['nr']} -- date: ${element['date']} -- name: ${element['name']} -- price: ${element['price']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appBar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireFrame for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
