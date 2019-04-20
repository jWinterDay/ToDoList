import 'package:flutter/material.dart';
import 'package:flutter_stetho/flutter_stetho.dart';

import 'ui/home_screen.dart';

void main() {
  //Stetho.initialize();
  runApp(App());
}

//root
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
      },
    );
  }
}