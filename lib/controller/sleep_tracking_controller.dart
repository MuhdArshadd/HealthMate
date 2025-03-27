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

Future<List<Map<String, dynamic>>> getLast7DaysSleepData(String userId) async {
  try {
    print("Fetching sleep data for userId: $userId"); 

    await dbConnection.connectToDatabase();

    String query = '''
WITH week_days AS (
    SELECT 'M' AS day_of_week, 1 AS day_order UNION ALL
    SELECT 'Tue', 2 UNION ALL
    SELECT 'W', 3 UNION ALL
    SELECT 'Thu', 4 UNION ALL
    SELECT 'F', 5 UNION ALL
    SELECT 'Sat', 6 UNION ALL
    SELECT 'Sun', 7
)
SELECT 
    wd.day_of_week,
    COALESCE(SUM(st.hours_asleep), 0) AS total_sleep_hours
FROM week_days wd
LEFT JOIN (
    SELECT 
        CASE 
            WHEN TO_CHAR(created_at, 'Dy') = 'Mon' THEN 'M'
            WHEN TO_CHAR(created_at, 'Dy') = 'Tue' THEN 'Tue'
            WHEN TO_CHAR(created_at, 'Dy') = 'Wed' THEN 'W'
            WHEN TO_CHAR(created_at, 'Dy') = 'Thu' THEN 'Thu'
            WHEN TO_CHAR(created_at, 'Dy') = 'Fri' THEN 'F'
            WHEN TO_CHAR(created_at, 'Dy') = 'Sat' THEN 'Sat'
            WHEN TO_CHAR(created_at, 'Dy') = 'Sun' THEN 'Sun'
        END AS day_of_week,
        hours_asleep
    FROM sleep_tracking
    WHERE users_id = @userId
) st ON wd.day_of_week = st.day_of_week
GROUP BY wd.day_of_week, wd.day_order
ORDER BY wd.day_order;

    ''';

    List<List<dynamic>> results = await dbConnection.connection.query(
      query,
      substitutionValues: {'userId': userId},
    );

    List<Map<String, dynamic>> formattedResults = results.map((row) => {
      "day_of_week": row[0], 
      "total_sleep_hours": row[1]
    }).toList();

    print("Fetched Sleep Data:");
    for (var data in formattedResults) {
      print("Day: ${data['day_of_week']}, Sleep Hours: ${data['total_sleep_hours']}");
    }

    return formattedResults;
  } catch (e) {
    print("Error fetching sleep data: $e");
    return [];
  } finally {
    dbConnection.closeConnection();
  }
}

Future<List<Map<String, dynamic>>> getLast1MonthSleepData(String userId) async {
  try {
    print("Fetching 1 month sleep data for userId: $userId");

    await dbConnection.connectToDatabase();

    String query = '''
WITH last_30_days AS (
    SELECT generate_series(
        CURRENT_DATE - INTERVAL '30 days', 
        CURRENT_DATE, 
        INTERVAL '1 day'
    )::DATE AS sleep_date
)
SELECT 
    TO_CHAR(DATE_TRUNC('week', l30.sleep_date), 'YYYY-MM-DD') AS week_start,
    COALESCE(SUM(st.hours_asleep), 0) AS total_sleep_hours
FROM last_30_days l30
LEFT JOIN (
    SELECT 
        DATE(created_at) AS sleep_date,
        hours_asleep
    FROM sleep_tracking
    WHERE users_id = @userId
) st ON l30.sleep_date = st.sleep_date
GROUP BY DATE_TRUNC('week', l30.sleep_date)
ORDER BY week_start;
    ''';

    // print("Executing Query: $query");

    var results = await dbConnection.connection.query(query, 
      substitutionValues: {'userId': userId});

    List<Map<String, dynamic>> formattedResults = results.map((row) => {
      "week_start": row[0], 
      "total_sleep_hours": row[1]
    }).toList();

    print("\nQuery Results:");
    print("Total rows returned: ${results.length}");
    formattedResults.forEach((data) {
      print("Day: ${data['week_start']}, Sleep Hours: ${data['total_sleep_hours']}");
    });

    if (formattedResults.isEmpty) {
      print("WARNING: No sleep data found for the past 30 days.");
    }

    return formattedResults;
  } catch (e, stackTrace) {
    print("Error fetching 1-month sleep data: $e");
    print("Stack Trace: $stackTrace");
    return [];
  } finally {
    await dbConnection.closeConnection();
  }
}

Future<double> getAverageDailySleepLast30Days(String userId) async {
  try {
    print("Fetching average daily sleep for the last 30 days for userId: $userId");

    await dbConnection.connectToDatabase();

    String query = '''
    WITH last_30_days AS (
        SELECT generate_series(
            CURRENT_DATE - INTERVAL '29 days', 
            CURRENT_DATE, 
            INTERVAL '1 day'
        )::DATE AS sleep_date
    )
    SELECT 
        COALESCE(ROUND(AVG(total_sleep_hours), 2), 0) AS avg_sleep_hours
    FROM (
        SELECT 
            l30.sleep_date AS date,
            COALESCE(SUM(st.hours_asleep), 0) AS total_sleep_hours
        FROM last_30_days l30
        LEFT JOIN (
            SELECT 
                DATE(created_at) AS sleep_date,
                hours_asleep
            FROM sleep_tracking
            WHERE users_id = @userId
        ) st ON l30.sleep_date = st.sleep_date
        GROUP BY l30.sleep_date
    ) daily_sleep;
    ''';

    var result = await dbConnection.connection.query(query, 
      substitutionValues: {'userId': userId});

    print("Raw Query Result: $result");

    double avgSleepHours = result.isNotEmpty && result.first[0] != null 
        ? double.tryParse(result.first[0].toString()) ?? 0.0
        : 0.0;

    print("Average Daily Sleep (Last 30 Days): $avgSleepHours hours");

    return avgSleepHours;
  } catch (e, stackTrace) {
    print("Error fetching average sleep for last 30 days: $e");
    print("Stack Trace: $stackTrace");
    return 0.0;
  } finally {
    await dbConnection.closeConnection();
  }
}




Future<String> getDayWithHighestSleep(String userId) async {
  try {
    print("Fetching day with highest sleep for userId: $userId");

    await dbConnection.connectToDatabase();

    String query = '''
    WITH last_30_days AS (
        SELECT generate_series(
            CURRENT_DATE - INTERVAL '29 days', 
            CURRENT_DATE, 
            INTERVAL '1 day'
        )::DATE AS sleep_date
    ),
    daily_sleep AS (
        SELECT 
            l30.sleep_date AS date,
            COALESCE(SUM(st.hours_asleep), 0) AS total_sleep_hours
        FROM last_30_days l30
        LEFT JOIN (
            SELECT 
                DATE(created_at) AS sleep_date,
                hours_asleep
            FROM sleep_tracking
            WHERE users_id = @userId
        ) st ON l30.sleep_date = st.sleep_date
        GROUP BY l30.sleep_date
    )
    SELECT 
        TO_CHAR(date, 'Day') AS highest_sleep_day
    FROM daily_sleep
    ORDER BY total_sleep_hours DESC
    LIMIT 1;
    ''';

    // print("Executing Query: $query");

    var result = await dbConnection.connection.query(query, 
      substitutionValues: {'userId': userId});

    print("Raw Query Result for Highest Sleep Day: $result");


    String highestSleepDay = result.isNotEmpty ? (result.first[0] as String).trim() : "No Data";

    print("Day with Highest Sleep: $highestSleepDay");

    return highestSleepDay;
  } catch (e, stackTrace) {
    print("Error fetching highest sleep day: $e");
    print("Stack Trace: $stackTrace");
    return "Error";
  } finally {
    await dbConnection.closeConnection();
  }
}





}