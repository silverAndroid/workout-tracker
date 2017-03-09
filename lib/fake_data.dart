import 'models/day.dart';
import 'models/exercise.dart';
import 'models/workout.dart';

class Data {
  static List<Exercise> exercises = [
    new Exercise('Chin-Up', 'Back',
      '''
      Grab the pull-up bar with an underhanded grip. Place your hands shoulder-width apart. Pull yourself up until your chin is at or above the bar. Slowly lower yourself back down so that your arms are fully extended.
      ''', recommendedReps: 10, recommendedSets: 5,
    ),
    new Exercise('Curl (Cable)', 'Biceps',
      '''
      Stand up straight with your legs shoulder width apart. Use an underhand grip on the bar shoulder width apart. Hold the bar down in front of your thighs. Bend at the elbows (so that only your forearms are moving) to curl the bar towards your shoulders. Hold for a moment at the top of the motion before slowly lowering the bar back to the starting position.
      ''', recommendedSets: 2, recommendedReps: 20,
    ),
    new Exercise('Bench Press (Barbell)', 'Chest',
      '''
      Lie down with your back flat on the bench. Plant your feet on the ground. Grip the bar with your arms slightly wider than shoulder width apart. Lift the bar off the rack and bring it down to your chest. Push the bar upwards keeping tension on the chest.
      ''', recommendedReps: 10, recommendedSets: 5,
    ),
    new Exercise('Standing Calf Raise (Machine)', 'Calves',
      '''
      Adjust the height of the pads so that you can stand up straight with your shoulders under the pads. The balls of your feet should be on the platform with your heels hanging off. Raise your heels up while keeping your legs straight. Hold for a second then lower them back down.
      ''', recommendedReps: 5, recommendedSets: 3,
    ),
    new Exercise('Shrug (Smith)', 'Shoulders',
      '''
    Stand up straight and grab a barbell with an overhand grip. Keep your arms extended in front of you. Use your shoulders to lift the bar while keeping your arms extended. Hold for a second then release your shoulders back down.
    ''', recommendedSets: 2, recommendedReps: 10,
    ),
  ];

  static List<Workout> workouts = [
    new Workout('Workout 1', 'Back and Chest', [
      exercises[0],
      exercises[2],
    ],
      [
        Day.MONDAY,
        Day.FRIDAY,
      ],
    ),
    new Workout('Workout 2', 'Biceps, Calves and Shoulders', [
      exercises[1],
      exercises[3],
      exercises[4],
    ],
      [
        Day.THURSDAY,
        Day.TUESDAY,
      ],
    ),
    new Workout('Workout 3', 'Biceps, Chest and Calves', [
      exercises[2],
      exercises[1],
      exercises[3],
    ],
      [Day.SATURDAY],
    ),
  ];
}