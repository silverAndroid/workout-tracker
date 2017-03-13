import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'platform_method.dart';

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
  int numReps, weight;

  Future submit() async {
    return await new PlatformMethod().rawQuery(
        'INSERT INTO SETS (NUM_REPS, WEIGHT, EXERCISE_ID) VALUES (?, ?, ?)', [
      numReps,
      weight,
      0,
    ], true, false);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      child: new Column(
        children: [
          new Input(
            onChanged: (value) {
              if (value.text.isNotEmpty)
                numReps = int.parse(value.text);
            },
            labelText: 'Reps',
            keyboardType: TextInputType.number,
          ),
          new Input(
            onChanged: (value) {
              if (value.text.isNotEmpty)
                weight = int.parse(value.text);
            },
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