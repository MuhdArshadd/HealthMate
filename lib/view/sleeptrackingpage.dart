import 'package:flutter/material.dart';

import 'custom_app_bar.dart';
import 'custom_nav_bar.dart';
import 'main_navigation_screen.dart';
import 'sleep_popup.dart';

import 'package:provider/provider.dart';
import '../AuthProvider/Auth_provider.dart';
import "../model/user_model.dart";

class SleepTrackingPage extends StatefulWidget {
  @override
  _SleepTrackingPageState createState() => _SleepTrackingPageState();
}

class _SleepTrackingPageState extends State<SleepTrackingPage> {
  bool showLast7Days = true; // Default to "Last 7 Days"

  // Sample sleep data
  final List<double> last7DaysData = [5.2, 6.5, 4.8, 8.0, 5.3, 3.5, 7.2];

  final List<double> last1MonthData = [
    4.5, 6.0, 7.5, 5.2, 3.8, 6.7, 4.9,
    5.1, 7.2, 4.3, 6.8, 5.6, 8.0, 5.9,
    3.7, 7.0, 4.2, 6.3, 5.8, 4.6, 7.1,
    5.0, 6.9, 4.4, 5.5, 6.2, 4.7, 6.1,
    7.4, 5.7
  ];

  final List<String> daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  void _showAddSleepEntryDialog() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    showDialog(
      context: context,
      builder: (context) => AddSleepEntryDialog(user: user!),
    );
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
    final double maxSleepHours = sleepData.isNotEmpty ? sleepData.reduce((a, b) => a > b ? a : b) : 10;
    final double averageSleep = sleepData.isNotEmpty ? (sleepData.reduce((a, b) => a + b) / sleepData.length) : 0.0;
    final int highestSleepIndex = sleepData.indexOf(sleepData.reduce((a, b) => a > b ? a : b));
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
                  Container(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        sleepData.length,
                            (index) {
                          final double heightPercentage = (sleepData[index] / maxSleepHours) * 150;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: heightPercentage,
                                    width: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(daysOfWeek[index % 7],
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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