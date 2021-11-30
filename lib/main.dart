import 'package:flutter/material.dart';
import 'package:myapp/pages/student_page.dart';
import 'package:provider/provider.dart';

import 'objects/application_state.dart';
import 'objects/student_classes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: (context, _) => MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const MyHomePage(title: 'Organizr'),
        '/class': (context) => ClassPage(),
      },
      title: 'Organizr',
      theme: ThemeData(
          primaryColor: Colors.indigo, backgroundColor: Colors.indigo[400]),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return Scaffold(
      body: StudentPage(),
    );
  }
}
