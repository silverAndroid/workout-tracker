import 'dart:async';

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
  Form _form;

  _CreateWorkoutFormState() {
    _workout = new Workout('', '', [], []);
    _formKey = new GlobalKey<FormState>();
  }

  Future _handleSubmit(BuildContext context) async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;
    } else {
      form.save();
      await new PlatformMethod().rawQuery(
          'INSERT INTO WORKOUTS (NAME, DESCRIPTION) VALUES (?, ?)',
          [_workout.name, _workout.description], 
          true
      );
      print('Query complete');
      Navigator.of(context).pop(true);
      print('pop');
    }
  }

  String _validateName(InputValue value) {
    if (value.text.isEmpty) {
      return 'Name is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _form = new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: new ListView(
        padding: new EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new TextField(
            labelText: 'Name',
            onSaved: (InputValue val) => _workout.name = val.text,
            validator: _validateName,
          ),
          new TextField(
            labelText: 'Description',
            hintText: 'Description (optional)',
            onSaved: (InputValue val) => _workout.description = val.text,
          ),
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

    return _form;
  }
}