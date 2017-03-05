import 'exercise.dart';
import 'day.dart';

class Workout {
  String name;
  String description;
  List<Exercise> exercises = [];
  List<Day> days = [];

  Workout(this.name, this.description, List<Exercise> exercises, List<Day> days) {
    this.exercises.addAll(exercises);
    this.days.addAll(days);
  }
}