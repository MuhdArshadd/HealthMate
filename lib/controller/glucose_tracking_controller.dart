import '../../db_connection.dart';

class GlucoseTrackingController {
  final DatabaseConnection dbConnection = DatabaseConnection();

  Future<String> submitGlucoseData(
      String userId, double glucoseIntake, bool isWearable) async {
    try {
      await dbConnection.connectToDatabase();

      String query;
      Map<String, dynamic> substitutionValues = {
        'userId': userId,
        'glucoseLevel': glucoseIntake,
        'isWearable': isWearable,
      };

      if (isWearable) {
        query = '''
        INSERT INTO glucose_tracking (users_id, glucose_level, iswearable_dev) 
        VALUES (@userId, @glucoseLevel, @isWearable)
        ''';

      } else {
        query = '''
        INSERT INTO glucose_tracking (users_id, glucose_level, iswearable_dev) 
        VALUES (@userId, @glucoseLevel, @isWearable)
        ''';
      }

      int affectedRows = await dbConnection.connection.execute(
        query,
        substitutionValues: substitutionValues,
      );

      if (affectedRows > 0) {
        print("Glucose data successfully inserted for User ID: $userId, Glucose level: $glucoseIntake");
        return "Sleep data submitted successfully";
      } else {
        print("Failed to insert Glucose data.");
        return "Error: Glucose data insertion failed";
      }
    } catch (e) {
      print("Error inserting Glucose data: $e");
      return "Error submitting Glucose data: $e";
    } finally {
      dbConnection.closeConnection();
    }
  }
}
