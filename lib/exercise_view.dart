import 'dart:async';
import 'dart:convert';

import 'package:WorkoutTracker/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'platform_method.dart';

class ExercisePage extends StatefulWidget {
  int exerciseID;

  ExercisePage(this.exerciseID);

  @override
  State<StatefulWidget> createState() => new ExercisePageState();
}

class ExercisePageState extends State<ExercisePage>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        bottom: new TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: [
            new Tab(text: 'Info'),
            new Tab(text: 'Log'),
          ],
        ),
        title: new Text('Workouts'),
      ),
      body: new TabBarView(
        children: [
          new ExerciseView(config.exerciseID),
          new ExerciseForm(config.exerciseID),
        ],
        controller: _controller,
      ),
    );
  }
}

class ExerciseView extends StatefulWidget {

  int exerciseID;

  ExerciseView(this.exerciseID);

  @override
  State<StatefulWidget> createState() => new ExerciseViewState();
}

class ExerciseViewState extends State<ExerciseView> {

  Exercise _exercise;

  @override
  void initState() {
    super.initState();
    loadExercise();
  }

  void openYouTubeVideo() {
    String youtubeURL = 'vnd.youtube://${_exercise.youtubeID}';
    new PlatformMethod().openURL(youtubeURL);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Widget body;

    if (_exercise == null) {
      body = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      List<Widget> instructionWidgets = [
        new Container(
          padding: new EdgeInsets.symmetric(vertical: 16.0),
          child: new Text(
            'Instructions',
            style: theme.textTheme.headline,
          ),
        ),
      ];
      instructionWidgets.addAll(
          _exercise.steps.map((step) => new Text(step)).toList());

      body = new Column(
        children: [
          new ListView(
            padding: new EdgeInsets.symmetric(horizontal: 16.0),
            children: instructionWidgets,
            shrinkWrap: true,
          ),
          new ListTile(
            title: new Text('View on YouTube'),
            trailing: new Icon(Icons.open_in_new),
            onTap: this.openYouTubeVideo,
          ),
        ],
      );
    }
    return body;
  }

  Future loadExercise() {
    return new PlatformMethod().rawQuery(
      'SELECT e.ID, e.NAME, e.DESCRIPTION, e.YOUTUBE_ID, bg.NAME as BODY_GROUP, es.STEP FROM EXERCISES e JOIN BODY_GROUPS bg ON bg.ID = e.PRIMARY_BODY_GROUP_ID JOIN EXERCISES_STEPS es ON es.EXERCISE_ID = e.ID WHERE e.ID = ? ORDER BY es.STEP_NUMBER ASC;',
      [
        config.exerciseID,
      ],
      false,
    ).then((res) {
      dynamic json = JSON.decode(res);
      dynamic row = json[0];
      _exercise = new Exercise(
          row['ID'], row['NAME'], row['BODY_GROUP'], row['DESCRIPTION'],
          youtubeID: row['YOUTUBE_ID']);
      _exercise.steps = json.map((step) => step['STEP']).toList();
    });
  }
}

class ExerciseForm extends StatefulWidget {

  int exerciseID;

  ExerciseForm(this.exerciseID);

  @override
  State<StatefulWidget> createState() => new ExerciseFormState();
}

class ExerciseFormState extends State<ExerciseForm> {
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
          [numReps, weight, config.exerciseID],
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
