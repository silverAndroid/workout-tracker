import 'package:WorkoutTracker/exercise_view.dart';
import 'package:WorkoutTracker/models/exercise.dart';
import 'package:WorkoutTracker/models/workout.dart';
import 'package:WorkoutTracker/platform_method.dart';
import 'package:flutter/material.dart';

class CreateWorkoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that
        // was created by the App.build method, and use it to set
        // our appbar title.
        title: new Text('Workouts'),
      ),
      body: new _CreateWorkoutForm(),
    );
  }
}

class _CreateWorkoutForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _CreateWorkoutFormState();
}

class _CreateWorkoutFormState extends State<_CreateWorkoutForm> {
  Workout _workout;
  bool _autoValidate = false;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  _CreateWorkoutFormState() {
    _workout = new Workout(-1, '', '');
    _formKey = new GlobalKey<FormState>();
  }

  void _handleSubmit(BuildContext context) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;
    } else {
      form.save();
      List<String> queries = ['INSERT INTO WORKOUTS (NAME, DESCRIPTION) VALUES (?, ?);'];
      queries.addAll(_workout.exercises.map((unused) => 'INSERT INTO WORKOUTS_EXERCISES VALUES ((SELECT ID FROM WORKOUTS WHERE NAME = ?), (SELECT ID FROM EXERCISES WHERE NAME = ?));'));
      List<List<dynamic>> params = [[_workout.name, _workout.description]];
      params.addAll(_workout.exercises.map((exercise) => [_workout.name, exercise.name]));
      new PlatformMethod()
          .runTransaction(queries, params, true)
          .then((json) {
        Navigator.of(context).pop(true);
      });
    }
  }

  String _validateName(String value) {
    if (value.isEmpty) {
      return 'Name is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: new ListView(
        padding: new EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new TextFormField(
            decoration: new InputDecoration(
              labelText: 'Name',
            ),
            onSaved: (String val) => _workout.name = val,
            validator: _validateName,
          ),
          new TextFormField(
            decoration: new InputDecoration(
              labelText: 'Description',
              hintText: 'Description (optional)',
            ),
            onSaved: (String val) => _workout.description = val,
          ),
          new ListView.builder(
            itemBuilder: (BuildContext context, int position) => new ExerciseListItem(_workout.exercises[position]),
            itemCount: _workout.exercises.length,
            shrinkWrap: true,
          ),
          new Container(
              alignment: new FractionalOffset(0.5, 0.5),
              padding: const EdgeInsets.all(16.0),
              child: new RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(
                      new MaterialPageRoute<List<Exercise>>(
                          builder: (
                              BuildContext context) => new SelectExercisesPage(_workout.exercises)
                      )).then((exercises) {
                    if (exercises != null) {
                      setState(() {
                        _workout.exercises = exercises;
                      });
                    }
                  });
                },
                child: new Row(children: <Widget>[
                  new Icon(Icons.add),
                  new Text('Add Exercise...'),
                ]),
              )),
          new Container(
            alignment: new FractionalOffset(0.5, 0.5),
            padding: const EdgeInsets.all(16.0),
            child: new RaisedButton(
              onPressed: () => this._handleSubmit(context),
              child: new Text('Submit'),
            ),
          )
        ],
      ),
    );
  }
}

class SelectExercisesPage extends StatefulWidget {

  List<Exercise> exercises;

  SelectExercisesPage(this.exercises);

  @override
  State<StatefulWidget> createState() => new SelectExercisesState();
}

class SelectExercisesState extends State<SelectExercisesPage> {

  ExerciseList _exercisesList;

  @override
  void initState() {
    super.initState();
    _exercisesList = new ExerciseList(config.exercises);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that
        // was created by the App.build method, and use it to set
        // our appbar title.
        title: new Text('Workouts'),
        actions: [
          new IconButton(
            icon: new Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_exercisesList.getExercises());
            },
          )
        ],
      ),
      body: _exercisesList,
    );
  }
}