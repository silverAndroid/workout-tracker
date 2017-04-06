import 'dart:async';
import 'dart:convert';

import 'package:WorkoutTracker/create_view.dart';
import 'package:flutter/material.dart';

import 'exercise_view.dart';
import 'fake_data.dart';
import 'models/exercise.dart';
import 'models/workout.dart';
import 'platform_method.dart';
import 'tap_card.dart';

class WorkoutPage extends StatelessWidget {

  _WorkoutList _workoutListElement;

  WorkoutPage() {
    _workoutListElement = new _WorkoutList();
  }

  VoidCallback _createWorkout(BuildContext context) {
    return () async {
      bool updated = await Navigator.of(context).push(
          new MaterialPageRoute<bool>(
              builder: (BuildContext context) => new CreateWorkoutPage()
          ));
      if (updated != null && updated) {
        this._workoutListElement.state.loadWorkouts();
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that
        // was created by the App.build method, and use it to set
        // our appbar title.
        title: new Text('Workouts'),
      ),
      body: _workoutListElement,
      floatingActionButton: new FloatingActionButton(
        onPressed: this._createWorkout(context),
        tooltip: 'New workout',
        child: new Icon(Icons.add),
      ),
    );
  }
}

class _WorkoutList extends StatefulWidget {

  _WorkoutListState state;

  _WorkoutList({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = new _WorkoutListState();
    return state;
  }
}

class _WorkoutListState extends State<_WorkoutList> {

  List<Workout> _workouts;

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_workouts == null) {
      body = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      body = new ListView(
        children: buildWorkoutList(),
      );
    }

    return body;
  }

  List<_WorkoutListItem> buildWorkoutList() {
    return _workouts.map((workout) => new _WorkoutListItem(workout, 0))
        .toList();
  }

  Future loadWorkouts() {
    return new PlatformMethod()
        .rawQuery('SELECT * FROM workouts;', [], false)
        .then((json) {
      setState(() {
        _workouts = JSON.decode(json).map((workout) =>
        new Workout(
          workout['ID'],
          workout['NAME'],
          workout['DESCRIPTION'],
        )).toList();
      });
    });
  }
}

class _WorkoutListItem extends StatelessWidget {

  Workout workout;
  int index;

  _WorkoutListItem(this.workout, this.index);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.title;
    final TextStyle subtitleStyle = theme.textTheme.caption;

    return new MyCard(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => new WorkoutDetailsPage(index),
        ));
      },
      child: new Column(
        children: [
          new Container(
              child: new Text(workout.name, style: titleStyle),
              alignment: FractionalOffset.topLeft,
              margin: new EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0)
          ),
          new Container(
            child: new Text(workout.description, style: subtitleStyle),
            alignment: FractionalOffset.centerLeft,
            margin: new EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
          ),
          new Container(
            child: new Text(workout.days.join(', ')),
            alignment: FractionalOffset.centerLeft,
            margin: new EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 8.0,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutDetailsPage extends StatelessWidget {

  int workoutID;

  WorkoutDetailsPage(this.workoutID);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that
        // was created by the App.build method, and use it to set
        // our appbar title.
        title: new Text('Exercises'),
      ),
      body: new WorkoutDetailsList(workoutID),
      floatingActionButton: new FloatingActionButton(
        onPressed: (() => print('FAB pressed, not incrementing..')),
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma tells the Dart formatter to use
      // a style that looks nicer for build methods.
    );
  }
}

class WorkoutDetailsList extends StatefulWidget {

  int workoutID;

  WorkoutDetailsList(this.workoutID);

  @override
  State<StatefulWidget> createState() => new WorkoutDetailsState();
}

class WorkoutDetailsState extends State<WorkoutDetailsList> {

  List<Exercise> exercises;

  @override
  void initState() {
    super.initState();
    exercises = Data.workouts[config.workoutID].exercises;
  }

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: buildWorkoutDetailsList(),
    );
  }

  List<_WorkoutDetailsListItem> buildWorkoutDetailsList() {
    return exercises.map((exercise) => new _WorkoutDetailsListItem(exercise))
        .toList();
  }
}

class _WorkoutDetailsListItem extends StatelessWidget {

  Exercise exercise;

  _WorkoutDetailsListItem(this.exercise);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new ListTile(
      title: new Text(exercise.name),
      subtitle: new Text(
        '${exercise.recommendedSets} sets of ${exercise.recommendedReps}',
      ),
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (BuildContext context) => new ExercisePage(0),
        ));
      },
    );
  }
}
