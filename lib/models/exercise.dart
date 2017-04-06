import 'set.dart';

class Exercise {
  int id;
  String name;
  String bodyGroup;
  String description;
  List<WorkoutSet> sets;
  int recommendedReps = -1; // recommended reps per set
  int recommendedSets = -1;

  Exercise(this.id, this.name, this.bodyGroup, this.description,
      {this.recommendedReps, this.recommendedSets}) : sets = [];
}