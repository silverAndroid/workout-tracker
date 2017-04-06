import 'dart:async';
import 'dart:convert';

import 'package:WorkoutTracker/models/exercise.dart';
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
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;

  void _handleSubmit(BuildContext context) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;
    } else {
      form.save();
      new PlatformMethod().rawQuery(
          'INSERT INTO SETS (NUM_REPS, WEIGHT, EXERCISE_ID) VALUES (?, ?, ?)',
          [numReps, weight, 0],
          true);
    }
  }

  String _validateNumReps(String value) {
    if (value.isEmpty) {
      return 'Number of reps cannot be empty.';
    }
    try {
      int reps = int.parse(value);
      if (reps < 0)
        return 'Reps cannot be less than 0.';
      return null;
    } on FormatException {
      return 'Invalid number, please enter a valid one.';
    }
  }

  String _validateWeight(String value) {
    if (value.isEmpty) {
      return 'Weight cannot be empty.';
    }
    try {
      int weight = int.parse(value);
      if (weight < 0)
        return 'Weight cannot be less than 0.';
      return null;
    } on FormatException {
      return 'Invalid number, please enter a valid one.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: new ListView(
        padding: new EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          new TextFormField(
            onSaved: (String value) => numReps = int.parse(value),
            decoration: new InputDecoration(
              labelText: 'Reps',
            ),
            keyboardType: TextInputType.number,
            validator: _validateNumReps,
          ),
          new TextFormField(
            onSaved: (String value) => weight = int.parse(value),
            decoration: new InputDecoration(
              labelText: 'Weight',
            ),
            keyboardType: TextInputType.number,
            validator: _validateWeight,
          ),
          new RaisedButton(
            onPressed: () => _handleSubmit(context),
            child: new Text('Submit'),
          )
        ],
      ),
    );
  }
}

class ExerciseList extends StatefulWidget {

  List<Exercise> _selectedExercises = [];

  @override
  State<StatefulWidget> createState() => new _ExerciseListState();

  List<Exercise> getExercises() {
    return _selectedExercises;
  }

  _onSelected(String exerciseName, bool selected) {
    if (selected) {
      new PlatformMethod().rawQuery(
        'SELECT e.ID, e.NAME, e.DESCRIPTION, bg.NAME as BODY_GROUP FROM EXERCISES e JOIN BODY_GROUPS bg ON bg.ID = e.PRIMARY_BODY_GROUP_ID WHERE e.NAME = ?;',
        [exerciseName],
        false,
      ).then((res) {
        var exercise = JSON.decode(res)[0];
        _selectedExercises.add(new Exercise(
          exercise['ID'],
          exercise['NAME'],
          exercise['BODY_GROUP'],
          exercise['DESCRIPTION'],
        ));
        getExercises();
      });
    } else {
      // TODO: Remove exercise from list
    }
  }
}

class _ExerciseListState extends State<ExerciseList> {
  List<BodyGroup> _bodyGroups;
  List<Exercise> _exercises;

  _ExerciseListState();

  @override
  void initState() {
    super.initState();
    loadBodyGroups();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_bodyGroups == null) {
      body = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      body = new SingleChildScrollView(
        child: new Container(
          child: new ExpansionPanelList(
              children: buildBodyGroupList(),
              expansionCallback: (int index, bool expanded) {
                setState(() {
                  _bodyGroups[index].isExpanded = !expanded;
                });
              }),
        ),
      );
    }
    return body;
  }

  List<ExpansionPanel> buildBodyGroupList() {
    return _bodyGroups
        .map((bodyGroup) =>
    new ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return new Container(
          child: new Center(
            child: new Text(bodyGroup.name),
          ),
        );
      },
      body: new _ExerciseExpansionPanelBody(bodyGroup, config._onSelected),
      isExpanded: bodyGroup.isExpanded,
    ))
        .toList();
  }

  Future loadBodyGroups() {
    return new PlatformMethod()
        .rawQuery('SELECT NAME FROM BODY_GROUPS;', [], false)
        .then((res) {
      setState(() {
        _bodyGroups = JSON
            .decode(res)
            .map((bodyGroup) => new BodyGroup(bodyGroup['NAME']))
            .toList();
      });
    });
  }
}

class _ExerciseExpansionPanelBody extends StatefulWidget {
  BodyGroup _bodyGroup;
  ExerciseSelected _onSelected;

  _ExerciseExpansionPanelBody(this._bodyGroup, this._onSelected);

  @override
  State<StatefulWidget> createState() => new _ExerciseExpansionPanelBodyState();
}

class _ExerciseExpansionPanelBodyState
    extends State<_ExerciseExpansionPanelBody> {
  List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    if (_exercises == null && config._bodyGroup.isExpanded) {
      loadExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_exercises == null) {
      body = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      body = new ListView.builder(
        itemBuilder: (BuildContext context, int position) =>
        new ExerciseListItem(
            _exercises[position], onSelected: config._onSelected),
        itemCount: _exercises.length,
        shrinkWrap: true,
      );
    }
    return body;
  }

  Future loadExercises() {
    return new PlatformMethod()
        .rawQuery(
        'SELECT e.ID, e.NAME, e.DESCRIPTION, bg.NAME as BODY_GROUP FROM EXERCISES e JOIN BODY_GROUPS bg ON bg.ID = e.PRIMARY_BODY_GROUP_ID WHERE bg.NAME = ?;',
        [config._bodyGroup.name],
        false)
        .then((res) {
      setState(() {
        _exercises = JSON
            .decode(res)
            .map((exercise) =>
        new Exercise(
          exercise['ID'],
          exercise['NAME'],
          exercise['DESCRIPTION'],
          exercise['BODY_GROUP'],
        ))
            .toList();
      });
    });
  }
}

class ExerciseListItem extends StatefulWidget {
  Exercise _exercise;
  ExerciseSelected _onSelected;

  ExerciseListItem(this._exercise, {onSelected}) {
    this._onSelected = onSelected;
  }

  @override
  State<StatefulWidget> createState() => new _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {
  bool _selected = false;

  _ExerciseListItemState();

  void setSelected(bool value) {
    config._onSelected(config._exercise.name, value);
    setState(() => _selected = value);
  }

  @override
  Widget build(BuildContext context) {
    if (config._onSelected == null) {
      return new ListTile(
        title: new Text(config._exercise.name),
      );
    } else {
      return new ListTile(
        title: new Text(config._exercise.name),
        leading: new Checkbox(
          value: _selected,
          onChanged: this.setSelected,
        ),
        selected: _selected,
        onTap: () {
          this.setSelected(!_selected);
        },
      );
    }
  }
}

class BodyGroup {
  String name;
  bool isExpanded;

  BodyGroup(this.name, {this.isExpanded = false});
}

typedef void ExerciseSelected(String exerciseName, bool selected);
