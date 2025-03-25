import 'package:intl/intl.dart';
import '../../db_connection.dart';

class CognitivegamesTrackingController {
  final DatabaseConnection dbConnection = DatabaseConnection();

  Future<Map<String, dynamic>> getStreakData(String userId) async {
    try {
      // Ensure connection is established before querying
      if (dbConnection.connection.isClosed) {
        print("🔄 Reconnecting to database...");
        await dbConnection.connectToDatabase();
      }

      List<List<dynamic>> results = await dbConnection.connection.query(
        '''
      SELECT current_streak, longest_streak, last_played_date 
      FROM cognitive_assistance 
      WHERE users_id = @userId
      ''',
        substitutionValues: {'userId': userId},
      );

      if (results.isNotEmpty) {
        var row = results.first;
        return {
          'current_streak': row[0] as int,
          'longest_streak': row[1] as int,
          'last_played_date': row[2] as DateTime,
        };
      } else {
        return {
          'current_streak': 0,
          'longest_streak': 0,
          'last_played_date': null,
        };
      }
    } catch (e) {
      print("Error fetching streak data: $e");
      return {};
    }
  }


  Future<void> updateStreakData(String userId) async {
    try {
      await dbConnection.connectToDatabase();

      DateTime today = DateTime.now();
      DateTime yesterday = today.subtract(Duration(days: 1));
      String todayFormatted = DateFormat('yyyy-MM-dd').format(today);
      String yesterdayFormatted = DateFormat('yyyy-MM-dd').format(yesterday);

      print("Today: $todayFormatted");
      print("Yesterday: $yesterdayFormatted");

      // Check if user already has a record in cognitive_assistance
      var result = await dbConnection.connection.query(
        '''
      SELECT current_streak, longest_streak, last_played_date 
      FROM cognitive_assistance 
      WHERE users_id = @userId
      ''',
        substitutionValues: {'userId': userId},
      );

      if (result.isEmpty) {
        // New player → Insert a new record
        print("New player detected! Creating initial record...");
        await dbConnection.connection.query(
          '''
        INSERT INTO cognitive_assistance (users_id, current_streak, longest_streak, last_played_date)
        VALUES (@userId, 1, 1, @today)
        ''',
          substitutionValues: {'userId': userId, 'today': todayFormatted},
        );
        print("New player record created!");
      } else {
        // 🔄 Returning player → Update streak
        var row = result.first;
        int currentStreak = row[0] as int;
        int longestStreak = row[1] as int;
        DateTime? lastPlayedDate = row[2] as DateTime?;

        print("Existing player detected! Last played: ${lastPlayedDate != null ? DateFormat('yyyy-MM-dd').format(lastPlayedDate) : 'Never'}");

        if (lastPlayedDate != null && DateFormat('yyyy-MM-dd').format(lastPlayedDate) == yesterdayFormatted) {
          currentStreak += 1;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
          print("Continuing streak: $currentStreak days");
        } else {
          currentStreak = 1; // Reset streak if last played date isn't yesterday
          print("Streak reset to 1");
        }

        // Update existing record
        var updateResult = await dbConnection.connection.query(
          '''
        UPDATE cognitive_assistance
        SET current_streak = @currentStreak,
            longest_streak = @longestStreak,
            last_played_date = @today
        WHERE users_id = @userId
        ''',
          substitutionValues: {
            'currentStreak': currentStreak,
            'longestStreak': longestStreak,
            'today': todayFormatted,
            'userId': userId,
          },
        );

        print("Query executed! Rows affected: ${updateResult.affectedRowCount}");
        print("Streak updated successfully!");
      }
    } catch (e) {
      print("Error updating streak: $e");
    }
  }

}
