import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_app_bar.dart';
import 'custom_nav_bar.dart';
import 'main_navigation_screen.dart';
import 'sleep_popup.dart';

import '../AuthProvider/Auth_provider.dart';
import '../model/user_model.dart';
import '../controller/sleep_tracking_controller.dart';

import 'barchart/last1month.dart';
import 'barchart/last7days.dart';

class SleepTrackingPage extends StatefulWidget {
  @override
  _SleepTrackingPageState createState() => _SleepTrackingPageState();
}

class _SleepTrackingPageState extends State<SleepTrackingPage> {
  bool showLast7Days = true; // Default to "Last 7 Days"
  List<double> last7DaysData = List.filled(7, 0.0);
  List<double> last1MonthData = List.filled(30, 0.0);
  bool _isLoading = true;

  final List<String> daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final SleepTrackingController _sleepTrackingController = SleepTrackingController();

  @override
  void initState() {
    super.initState();
    _fetchSleepData();
  }

  Future<void> _fetchSleepData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (user != null) {
      try {
        // Fetch last 7 days sleep data
        List<Map<String, dynamic>> sleepData = await _sleepTrackingController.getLast7DaysSleepData(user.userId);
        
        setState(() {
          // Map the fetched data to last7DaysData
          last7DaysData = List.filled(7, 0.0);
          for (var data in sleepData) {
            int index = _getDayIndex(data['day_of_week']);
            last7DaysData[index] = double.parse(data['total_sleep_hours'].toString());
          }
          _isLoading = false;
        });
      } catch (e) {
        print("Error fetching sleep data: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

int _getDayIndex(String dayOfWeek) {
  switch (dayOfWeek) {
    case 'M': return 0;
    case 'Tu': return 1; // Tuesday
    case 'W': return 2;
    case 'Th': return 3; // Thursday
    case 'F': return 4;
    case 'Sa': return 5; // Saturday
    case 'Su': return 6; // Sunday
    default: return 0;
  }
}


  void _showAddSleepEntryDialog() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    showDialog(
      context: context,
      builder: (context) => AddSleepEntryDialog(user: user!), 
    ).then((_) {
      // Refresh sleep data after adding a new entry
      _fetchSleepData();
    });
  }

  // Function for grouping last 1 month data by weekday (cumulative sum per weekday)
  List<double> _groupDataByWeekday(List<double> monthData) {
    List<double> weeklySum = List.filled(7, 0.0);
    List<int> countPerDay = List.filled(7, 0);

    for (int i = 0; i < monthData.length; i++) {
      int dayIndex = i % 7;
      weeklySum[dayIndex] += monthData[i];
      countPerDay[dayIndex]++;
    }

    for (int i = 0; i < 7; i++) {
      if (countPerDay[i] > 0) {
        weeklySum[i] /= countPerDay[i];
      }
    }

    return weeklySum;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    final List<double> sleepData = showLast7Days ? last7DaysData : _groupDataByWeekday(last1MonthData);
  
    // Add null check and default value handling
    final double maxSleepHours = sleepData.isNotEmpty 
      ? (sleepData.reduce((a, b) => a > b ? a : b) > 0 
          ? sleepData.reduce((a, b) => a > b ? a : b) 
          : 8.0) // Default to 8 if no positive values
      : 10.0; // Default max if list is empty

    final List<double> validSleepData = last7DaysData.where((hours) => hours > 0).toList();
    final double averageSleep = validSleepData.isNotEmpty
        ? validSleepData.reduce((a, b) => a + b) / validSleepData.length
        : 0.0;


    final int highestSleepIndex = sleepData.isNotEmpty 
      ? sleepData.indexOf(sleepData.reduce((a, b) => a > b ? a : b)) 
      : 0;

    final List<String> fullDaysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final String highestSleepDay = fullDaysOfWeek[highestSleepIndex];


    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sleep Tracking Header
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFF6E3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Sleep Tracking",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Image.asset(
                    "assets/sleep.png",
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ),

            SizedBox(height: 35),

            // Blue Container Box (Filters + Graph)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0XFFC7D9DD),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Filter Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => showLast7Days = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: showLast7Days ? Color(0XFFD7D7D7) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text('Last 7 days', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => setState(() => showLast7Days = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: !showLast7Days ? Color(0XFFD7D7D7) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text('Last 1 month', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Bar Chart with Dynamic Scaling
                  showLast7Days
                    ? Last7DaysBarChart(
                      )
                    : Last1MonthBarChart(
                        sleepData: _groupDataByWeekday(last1MonthData),
                        maxSleepHours: maxSleepHours,
                        daysOfWeek: daysOfWeek,
                      ),

                ],
              ),
            ),

            SizedBox(height: 30),

            if (showLast7Days) ...[
              Text(
                " Average Sleep (daily): ${averageSleep.toStringAsFixed(1)} Hours",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              Text(
                " Highest Sleep Time: $highestSleepDay",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                " Average Sleep (daily): ${averageSleep.toStringAsFixed(1)} Hours",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // Keeps Home highlighted
        onTap: (index) {
          // Navigate back to MainNavigationScreen with the correct index
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigationScreen(user: user!, selectedIndex: index),
            ),
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: _showAddSleepEntryDialog,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Center(child: Icon(Icons.add, size: 50, color: Colors.black)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}