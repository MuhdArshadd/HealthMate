import 'package:postgres/src/execution_context.dart';

import '../../db_connection.dart';

class SleepTrackingController {
  final DatabaseConnection dbConnection = DatabaseConnection();

  Future<String> submitSleepData(
      String userId, double sleepHours, bool isWearable, DateTime? sleepStart, DateTime? sleepEnd) async {
    try {
      await dbConnection.connectToDatabase();

      String query;
      Map<String, dynamic> substitutionValues = {
        'userId': userId,
        'sleepHours': sleepHours,
        'isWearable': isWearable,
      };

      if (isWearable) {

        DateTime now = DateTime.now();
        sleepStart ??= now.subtract(Duration(hours: sleepHours.toInt()));
        sleepEnd ??= now;

        query = '''
        INSERT INTO sleep_tracking (users_id, hours_asleep, iswearable_dev, sleep_start, sleep_end) 
        VALUES (@userId, @sleepHours, @isWearable, @sleepStart, @sleepEnd)
        ''';

        substitutionValues['sleepStart'] = sleepStart;
        substitutionValues['sleepEnd'] = sleepEnd;
      } else {
        // No timestamps for manual input
        query = '''
        INSERT INTO sleep_tracking (users_id, hours_asleep, iswearable_dev) 
        VALUES (@userId, @sleepHours, @isWearable)
        ''';
      }

      int affectedRows = await dbConnection.connection.execute(
        query,
        substitutionValues: substitutionValues,
      );

      if (affectedRows > 0) {
        print("Sleep data successfully inserted for User ID: $userId, Sleep Hours: $sleepHours");
        return "Sleep data submitted successfully";
      } else {
        print("Failed to insert sleep data.");
        return "Error: Sleep data insertion failed";
      }
    } catch (e) {
      print("Error inserting sleep data: $e");
      return "Error submitting sleep data: $e";
    } finally {
      dbConnection.closeConnection();
    }
  }
}