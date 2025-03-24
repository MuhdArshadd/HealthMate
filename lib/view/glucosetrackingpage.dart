import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'custom_nav_bar.dart';
import 'glucose_popup.dart';
import 'main_navigation_screen.dart';
import 'sleep_popup.dart';

class GlucoseTrackingPage extends StatefulWidget {
  @override
  _GlucoseTrackingPageState createState() => _GlucoseTrackingPageState();
}

class _GlucoseTrackingPageState extends State<GlucoseTrackingPage> {
  bool showLast7Days = true; // Default to "Last 7 Days"

  // Sample glucose data (mg/dL)
  final List<double> last7DaysData = [80, 110, 95, 130, 85, 70, 120];
  final List<double> last1MonthData = [
    40, 100, 120, 110, 95, 105, 40,
    85, 110, 115, 95, 120, 85, 100,
    105, 90, 130, 125, 110, 115, 105,
    90, 85, 100, 110, 105, 120, 95,
    100, 110
  ];

  final List<String> daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  void _showAddGlucoseEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddGlucoseEntryDialog(),
    );
  }

  // Function for grouping last 1 month data by weekday (currently averaging)
  List<double> _groupDataByWeekday(List<double> monthData) {
    List<double> weeklySum = List.filled(7, 0.0);

    for (int i = 0; i < monthData.length; i++) {
      int dayIndex = i % 7;
      weeklySum[dayIndex] += monthData[i]; // Summing instead of averaging
    }

    return weeklySum; // Returns cumulative sum instead of averages
  }


  @override
  Widget build(BuildContext context) {
    final List<double> glucoseData = showLast7Days ? last7DaysData : _groupDataByWeekday(last1MonthData);
    final double maxGlucose = glucoseData.reduce((a, b) => a > b ? a : b);
    // Calculate the correct average based on the view
    final double avgGlucose = showLast7Days
        ? last7DaysData.reduce((a, b) => a + b) / last7DaysData.length
        : last1MonthData.reduce((a, b) => a + b) / last1MonthData.length;

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
                color: Colors.lightGreen.shade100,
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
                      "Glucose Tracking",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Image.asset(
                    "assets/glucose.png",
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
                        glucoseData.length,
                            (index) {
                          final double heightPercentage = (glucoseData[index] / maxGlucose) * 150;
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
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                                  ),
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

            SizedBox(height: 20),
            // Average Glucose
            Text(
              "Average Glucose (daily): ${avgGlucose.toStringAsFixed(1)} mg/dL",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
              builder: (context) => MainNavigationScreen(selectedIndex: index),
            ),
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: _showAddGlucoseEntryDialog,
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