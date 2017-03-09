import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExercisePage extends StatelessWidget {

  int exerciseID;

  ExercisePage(this.exerciseID);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
      // Here we take the value from the MyHomePage object that
      // was created by the App.build method, and use it to set
      // our appbar title.
        title: new Text('Workouts'),
      ),
      body: new ExerciseView(),
      floatingActionButton: new FloatingActionButton(
        onPressed: (() => print('FAB pressed, not incrementing..')),
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}

class ExerciseView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new ExerciseState();
}

class ExerciseState extends State<ExerciseView> {
  PlatformMethodChannel dbPlatform = const PlatformMethodChannel('database');

  Future<String> query(String query, List<String> params) {
    if (query != null && query.isNotEmpty && params != null) {
      Map<String, dynamic> json = {
        'query': '\'$query\'',
        'params': params,
        'write': false
      };
      print(json.toString());
      try {
        return dbPlatform.invokeMethod('query', json.toString()).then((result) {
          print(result);
        });
      } on PlatformException catch (e) {
        print('Failed to query db');
        print(e.message);
      }
    }
    return new Future<String>.value("[]");
  }

  Future submit() async {
    return await query('SELECT * FROM android_metadata;', []);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      child: new Column(
        children: [
          new Input(
            labelText: 'Reps',
            keyboardType: TextInputType.number,
          ),
          new Input(
            labelText: 'Weight',
            keyboardType: TextInputType.number,
          ),
          new RaisedButton(
            onPressed: submit,
            child: new Text('Submit'),
          )
        ],
      ),
    );
  }
}