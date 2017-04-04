import 'day.dart';
import 'exercise.dart';

class Workout {
  String name;
  String description;
  List<Exercise> exercises = [];
  List<Day> days = [];

  Workout(this.name, this.description, {List<Exercise> exercises, List<Day> days}) {
    if (exercises != null)
      this.exercises.addAll(exercises);
    if (days != null)
      this.days.addAll(days);
  }
}