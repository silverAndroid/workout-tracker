import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'platform_method.dart';
import 'workout_view.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  String _title = 'Workout Tracker';
  PlatformMethodChannel dbPlatform = new PlatformMethod().dbPlatform;

  void initDB() {
    dbPlatform.invokeMethod('initDB');
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initDB();
    return new MaterialApp(
      title: _title,
      theme: new ThemeData(
      // This is the theme of your application.
      //
      // Try running your application with "flutter run". You'll see
      // the application has a blue toolbar. Then, without quitting
      // the app, try changing the primarySwatch below to Colors.green
      // and press "r" in the console where you ran "flutter run".
      // We call this a "hot reload". Notice that the counter didn't
      // reset back to zero -- the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new WorkoutPage(),
    );
  }
}
