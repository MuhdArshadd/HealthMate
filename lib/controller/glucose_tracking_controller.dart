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
        print(
            "Glucose data successfully inserted for User ID: $userId, Glucose level: $glucoseIntake");
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

  Future<List<Map<String, dynamic>>> getLast7DaysGlucoseData(
      String userId) async {
    try {
      print("Fetching glucose data for userId: $userId");

      await dbConnection.connectToDatabase();

      String query = '''
        WITH week_days AS (
            SELECT 'M' AS day_of_week, 1 AS day_order UNION ALL
            SELECT 'Tu', 2 UNION ALL
            SELECT 'W', 3 UNION ALL
            SELECT 'Th', 4 UNION ALL
            SELECT 'F', 5 UNION ALL
            SELECT 'Sa', 6 UNION ALL
            SELECT 'Su', 7
        )
        SELECT 
            wd.day_of_week,
            COALESCE(SUM(gt.glucose_level), 0) AS total_glucose_level
        FROM week_days wd
        LEFT JOIN (
            SELECT 
                CASE 
                    WHEN TO_CHAR(created_at, 'Dy') = 'Mon' THEN 'M'
                    WHEN TO_CHAR(created_at, 'Dy') = 'Tue' THEN 'Tu'
                    WHEN TO_CHAR(created_at, 'Dy') = 'Wed' THEN 'W'
                    WHEN TO_CHAR(created_at, 'Dy') = 'Thu' THEN 'Th'
                    WHEN TO_CHAR(created_at, 'Dy') = 'Fri' THEN 'F'
                    WHEN TO_CHAR(created_at, 'Dy') = 'Sat' THEN 'Sa'
                    WHEN TO_CHAR(created_at, 'Dy') = 'Sun' THEN 'Su'
                END AS day_of_week,
                glucose_level
            FROM glucose_tracking
            WHERE users_id = @userId
        ) gt ON wd.day_of_week = gt.day_of_week
        GROUP BY wd.day_of_week, wd.day_order
        ORDER BY wd.day_order;
    ''';

      List<List<dynamic>> results = await dbConnection.connection.query(
        query,
        substitutionValues: {'userId': userId},
      );

      List<Map<String, dynamic>> formattedResults = results
          .map((row) => {
                "day_of_week": row[0] as String,
                "total_glucose_level":
                    double.tryParse(row[1].toString()) ?? 0.0,
              })
          .toList();

      print("Fetched Glucose Data:");
      for (var data in formattedResults) {
        print(
            "Day: ${data['day_of_week']}, Total Glucose Level: ${data['total_glucose_level']}");
      }

      return formattedResults;
    } catch (e) {
      print("Error fetching glucose data: $e");
      return [];
    } finally {
      dbConnection.closeConnection();
    }
  }

  Future<List<Map<String, dynamic>>> getLast1MonthGlucoseData(String userId) async {
  try {
    print("Fetching 1 month glucose data for userId: $userId");

    await dbConnection.connectToDatabase();

    String query = '''
      WITH last_30_days AS (
          SELECT generate_series(
              CURRENT_DATE - INTERVAL '30 days',
              CURRENT_DATE,
              INTERVAL '1 day'
          )::DATE AS glucose_date
      )
      SELECT 
          TO_CHAR(DATE_TRUNC('week', l30.glucose_date), 'YYYY-MM-DD') AS week_start,
          COALESCE(SUM(gt.glucose_level), 0) AS total_glucose_level
      FROM last_30_days l30
      LEFT JOIN (
          SELECT 
              DATE(created_at) AS glucose_date,
              glucose_level
          FROM glucose_tracking
          WHERE users_id = '11'
      ) gt ON l30.glucose_date = gt.glucose_date
      GROUP BY DATE_TRUNC('week', l30.glucose_date)
      ORDER BY week_start;
    ''';

    print("Executing Query: $query");

    var results = await dbConnection.connection.query(query, 
      substitutionValues: {'userId': userId});

    List<Map<String, dynamic>> formattedResults = results.map((row) => {
      "week_start": row[0], 
      "average_glucose_level": row[1]
    }).toList();

    print("\nQuery Results:");
    print("Total rows returned: ${results.length}");
    formattedResults.forEach((data) {
      print("Week: ${data['week_start']}, Avg Glucose: ${data['average_glucose_level']}");
    });

    if (formattedResults.isEmpty) {
      print("WARNING: No glucose data found for the past 30 days.");
    }

    return formattedResults;
  } catch (e, stackTrace) {
    print("Error fetching 1-month glucose data: $e");
    print("Stack Trace: $stackTrace");
    return [];
  } finally {
    await dbConnection.closeConnection();
  }
}


Future<double> getLast7DaysAverageDailyGlucose(String userId) async {
  try {
    print("Fetching average daily glucose for userId: $userId");

    await dbConnection.connectToDatabase();

    String query = '''
      WITH last_7_days AS (
          SELECT generate_series(
              CURRENT_DATE - INTERVAL '7 days',
              CURRENT_DATE,
              INTERVAL '1 day'
          )::DATE AS glucose_date
      )
      SELECT 
          COALESCE(AVG(gt.glucose_level), 0) AS average_daily_glucose
      FROM last_7_days l7
      LEFT JOIN (
          SELECT 
              DATE(created_at) AS glucose_date,
              glucose_level
          FROM glucose_tracking
          WHERE users_id = @userId
            AND created_at >= CURRENT_DATE - INTERVAL '7 days'
      ) gt ON l7.glucose_date = gt.glucose_date;
    ''';

    print("Executing Query: $query");

    var results = await dbConnection.connection.query(query, 
      substitutionValues: {'userId': userId});

    // Extract the average daily glucose level
    double averageDailyGlucose = results.isNotEmpty 
      ? double.tryParse(results[0][0].toString()) ?? 0.0 
      : 0.0;

    print("Average Daily Glucose (Last 7 Days): $averageDailyGlucose mg/dL");

    return averageDailyGlucose;
  } catch (e, stackTrace) {
    print("Error fetching average daily glucose: $e");
    print("Stack Trace: $stackTrace");
    return 0.0;
  } finally {
    await dbConnection.closeConnection();
  }
}

Future<double> getLast1MonthAverageDailyGlucose(String userId) async {
  try {
    print("Fetching average daily glucose for the last 1 month for userId: $userId");

    await dbConnection.connectToDatabase();

    String query = '''
      WITH last_30_days AS (
          SELECT generate_series(
              CURRENT_DATE - INTERVAL '30 days',
              CURRENT_DATE,
              INTERVAL '1 day'
          )::DATE AS glucose_date
      )
      SELECT 
          COALESCE(AVG(gt.glucose_level), 0) AS average_daily_glucose
      FROM last_30_days l30
      LEFT JOIN (
          SELECT 
              DATE(created_at) AS glucose_date,
              glucose_level
          FROM glucose_tracking
          WHERE users_id = @userId
            AND created_at >= CURRENT_DATE - INTERVAL '30 days'
      ) gt ON l30.glucose_date = gt.glucose_date;
    ''';

    print("Executing Query: $query");

    var results = await dbConnection.connection.query(query, 
      substitutionValues: {'userId': userId});

    double averageDailyGlucose = results.isNotEmpty 
      ? double.tryParse(results[0][0].toString()) ?? 0.0 
      : 0.0;

    print("Average Daily Glucose (Last 30 Days): $averageDailyGlucose mg/dL");

    return averageDailyGlucose;
  } catch (e, stackTrace) {
    print("Error fetching average daily glucose: $e");
    print("Stack Trace: $stackTrace");
    return 0.0;
  } finally {
    await dbConnection.closeConnection();
  }
}

}
