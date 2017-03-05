import 'package:flutter/material.dart';
import 'models/workout.dart';
import 'models/exercise.dart';
import 'fake_data.dart';
import 'tap_card.dart';

class WorkoutPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
      // Here we take the value from the MyHomePage object that
      // was created by the App.build method, and use it to set
      // our appbar title.
        title: new Text('Workouts'),
      ),
      body: new WorkoutList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: (() => print('FAB pressed, not incrementing..')),
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma tells the Dart formatter to use
    // a style that looks nicer for build methods.
    );
  }
}

class WorkoutList extends StatefulWidget {

  WorkoutList({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {

  List<Workout> _workouts;

  @override
  void initState() {
    super.initState();
    _workouts = Data.workouts;
  }

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: buildWorkoutList(),
    );
  }

  List<_WorkoutListItem> buildWorkoutList() {
    return _workouts.map((workout) => new _WorkoutListItem(workout)).toList();
  }
}

class _WorkoutListItem extends StatelessWidget {

  Workout workout;

  _WorkoutListItem(this.workout);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.title;
    final TextStyle subtitleStyle = theme.textTheme.caption;

    return new MyCard(
      onTap: () {
        print('clicked');
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