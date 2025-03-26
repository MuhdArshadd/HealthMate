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

Future<List<Map<String, dynamic>>> getLast7DaysSleepData(String userId) async {
  try {
    print("Fetching sleep data for userId: $userId"); // Log the user ID being queried

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

    // Convert results to a list of maps
    List<Map<String, dynamic>> formattedResults = results.map((row) => {
      "day_of_week": row[0], 
      "total_sleep_hours": row[1]
    }).toList();

    // Log the fetched results
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
    WITH month_days AS (
        SELECT generate_series(1, 31) AS day_of_month
    )
    SELECT 
        md.day_of_month,
        COALESCE(SUM(st.hours_asleep), 0) AS total_sleep_hours
    FROM month_days md
    LEFT JOIN (
        SELECT 
            EXTRACT(DAY FROM created_at) AS day_of_month,
            hours_asleep
        FROM sleep_tracking
        WHERE 
            users_id = @userId AND 
            created_at >= DATE_TRUNC('month', CURRENT_DATE) AND 
            created_at < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
    ) st ON md.day_of_month = st.day_of_month
    GROUP BY md.day_of_month
    ORDER BY md.day_of_month;
    ''';

    // Print the full query for debugging
    print("Executing Query:");
    print(query);
    print("User ID: $userId");

    List<List<dynamic>> results = await dbConnection.connection.query(
      query,
      substitutionValues: {'userId': userId},
    );

    // Convert results to a list of maps
    List<Map<String, dynamic>> formattedResults = results.map((row) => {
      "day_of_month": row[0].toString(), 
      "total_sleep_hours": row[1]
    }).toList();

    // Detailed logging of query results
    print("\nQuery Results:");
    print("Total rows returned: ${results.length}");
    print("Formatted Results:");
    for (var data in formattedResults) {
      print("Day: ${data['day_of_month']}, Sleep Hours: ${data['total_sleep_hours']}");
    }

    // Additional debugging information
    if (formattedResults.isEmpty) {
      print("WARNING: No sleep data found for the current month.");
    }

    return formattedResults;
  } catch (e) {
    print("Error fetching 1 month sleep data: $e");
    
    // Print stack trace for more detailed error information
    print("Stack Trace: $StackTrace");
    
    return [];
  } finally {
    dbConnection.closeConnection();
  }
}

// Future<List<Map<String, dynamic>>> get1MonthSleepDataWithCustomRange(
//   String userId, DateTime startDate, DateTime endDate) async {
//   try {
//     print("Fetching sleep data for userId: $userId from $startDate to $endDate");

//     await dbConnection.connectToDatabase();

//     String query = '''
//     WITH daily_sleep AS (
//         SELECT 
//             DATE(created_at) AS sleep_date,  
//             SUM(hours_asleep) AS total_sleep_per_day
//         FROM sleep_tracking
//         WHERE users_id = @userId
//             AND created_at >= @startDate
//             AND created_at < @endDate
//         GROUP BY sleep_date  
//     ),
//     monthly_sleep AS (
//         SELECT 
//             DATE_TRUNC('month', sleep_date) AS month_start,
//             SUM(total_sleep_per_day) AS total_sleep_hours
//         FROM daily_sleep
//         GROUP BY month_start
//     ),
//     months AS (
//         SELECT generate_series(
//             DATE_TRUNC('month', @startDate),  
//             DATE_TRUNC('month', @endDate),  
//             INTERVAL '1 month'
//         ) AS month_start
//     )
//     SELECT 
//         TO_CHAR(months.month_start, 'Mon') AS month_start_date,
//         COALESCE(monthly_sleep.total_sleep_hours, 0) AS total_sleep_hours
//     FROM months
//     LEFT JOIN monthly_sleep 
//         ON monthly_sleep.month_start = months.month_start
//     ORDER BY months.month_start;
//     ''';

//     List<List<dynamic>> results = await dbConnection.connection.query(
//       query,
//       substitutionValues: {
//         'userId': userId,
//         'startDate': startDate,
//         'endDate': endDate,
//       },
//     );

//     // Convert results into a list of maps
//     List<Map<String, dynamic>> formattedResults = results.map((row) => {
//           "month_start_date": row[0], // YYYY-MM format
//           "total_sleep_hours": row[1]
//         }).toList();

//     print("Fetched Monthly Sleep Data:");
//     formattedResults.forEach((data) {
//       print("Month: ${data['month_start_date']}, Sleep Hours: ${data['total_sleep_hours']}");
//     });

//     return formattedResults;
//   } catch (e) {
//     print("Error fetching sleep data: $e");
//     return [];
//   } finally {
//     dbConnection.closeConnection();
//   }
// }






}


