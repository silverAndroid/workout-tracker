import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'platform_method.dart';
import 'workout_view.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  String _title = 'Workout Tracker';

  Future initDB() async {
    PlatformMethod platformMethod = new PlatformMethod();
    await platformMethod.dbPlatform.invokeMethod('initDB');
    await platformMethod.rawQuery('CREATE TABLE IF NOT EXISTS WORKOUTS(ID INTEGER PRIMARY KEY NOT NULL, NAME TEXT UNIQUE NOT NULL, DESCRIPTION TEXT);', [], true, isExecutable: true);
    await platformMethod.rawQuery('CREATE TABLE IF NOT EXISTS EXERCISES(ID INTEGER PRIMARY KEY NOT NULL, NAME TEXT UNIQUE NOT NULL, BODY_GROUP TEXT NOT NULL, DESCRIPTION TEXT, RECOMMENDED_REPS INTEGER DEFAULT -1, RECOMMENDED_SETS INTEGER DEFAULT -1);', [], true, isExecutable: true);
    await platformMethod.rawQuery('CREATE TABLE IF NOT EXISTS SETS(ID INTEGER PRIMARY KEY NOT NULL, NUM_REPS INTEGER NOT NULL, WEIGHT INTEGER NOT NULL, EXERCISE_ID INTEGER NOT NULL, FOREIGN KEY (EXERCISE_ID) REFERENCES EXERCISES (ID));', [], true, isExecutable: true);
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
