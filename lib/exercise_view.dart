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

  void submit() {
    new PlatformMethod().rawQuery(
        'INSERT INTO SETS (NUM_REPS, WEIGHT, EXERCISE_ID) VALUES (?, ?, ?)',
        [numReps, weight, 0],
        true);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      child: new Column(
        children: [
          new TextField(
            onChanged: (String value) {
              if (value.isNotEmpty) numReps = int.parse(value);
            },
            decoration: new InputDecoration(
              labelText: 'Reps',
            ),
            keyboardType: TextInputType.number,
          ),
          new TextField(
            onChanged: (String value) {
              if (value.isNotEmpty) weight = int.parse(value);
            },
            decoration: new InputDecoration(
              labelText: 'Weight',
            ),
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

class ExerciseList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  List<BodyGroup> _bodyGroups;

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
      body: new _ExerciseExpansionPanelBody(bodyGroup),
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

  _ExerciseExpansionPanelBody(this._bodyGroup);

  @override
  State<StatefulWidget> createState() =>
      new _ExerciseExpansionPanelBodyState(_bodyGroup);
}

class _ExerciseExpansionPanelBodyState
    extends State<_ExerciseExpansionPanelBody> {
  List<Exercise> _exercises;
  BodyGroup _bodyGroup;

  _ExerciseExpansionPanelBodyState(this._bodyGroup);

  @override
  void initState() {
    super.initState();
    if (_exercises == null && _bodyGroup.isExpanded) {
      loadExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Widget body;
    if (_exercises == null) {
      body = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      body = new ListView.builder(
        itemBuilder: (BuildContext context, int position) =>
        new _ExerciseListItem(_exercises[position]),
        itemCount: _exercises.length,
        shrinkWrap: true,
      );
    }
    return body;
  }

  List<_ExerciseListItem> buildExerciseList() {
    return _exercises
        .map((exercise) => new _ExerciseListItem(exercise))
        .toList();
  }

  Future loadExercises() {
    return new PlatformMethod()
        .rawQuery(
        'SELECT e.NAME, e.DESCRIPTION, bg.NAME as BODY_GROUP FROM EXERCISES e JOIN BODY_GROUPS bg ON bg.ID = e.PRIMARY_BODY_GROUP_ID WHERE bg.NAME = ?;',
        [_bodyGroup.name],
        false)
        .then((res) {
      setState(() {
        _exercises = JSON
            .decode(res)
            .map((exercise) =>
        new Exercise(exercise['NAME'],
            exercise['DESCRIPTION'], exercise['BODY_GROUP']))
            .toList();
      });
    });
  }
}

class _ExerciseListItem extends StatefulWidget {
  Exercise _exercise;

  _ExerciseListItem(this._exercise);

  @override
  State<StatefulWidget> createState() => new _ExerciseListItemState(_exercise);
}

class _ExerciseListItemState extends State<_ExerciseListItem> {
  Exercise _exercise;
  bool _selected = false;

  _ExerciseListItemState(this._exercise);

  void setSelected(bool value) {
    setState(() => _selected = value);
  }

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(_exercise.name),
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

class BodyGroup {
  String name;
  bool isExpanded;

  BodyGroup(this.name, {this.isExpanded = false});
}
