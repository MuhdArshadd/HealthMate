import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../AuthProvider/Auth_provider.dart';
import '../../controller/sleep_tracking_controller.dart';

class Last7DaysBarChart extends StatefulWidget {
  const Last7DaysBarChart({Key? key}) : super(key: key);

  @override
  _Last7DaysBarChartState createState() => _Last7DaysBarChartState();
}

class _Last7DaysBarChartState extends State<Last7DaysBarChart> {
  final SleepTrackingController _sleepTrackingController = SleepTrackingController();
  List<Map<String, dynamic>> last7DaysSleepData = [];
  bool _isLoading = true;
  double maxSleepHours = 8.0;

final List<String> daysOfWeek = ['M', 'Tue', 'W', 'Thu', 'F', 'Sat', 'Sun'];


  @override
  void initState() {
    super.initState();
    _fetchSleepData();
  }

  Future<void> _fetchSleepData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (user != null) {
      try {
        List<Map<String, dynamic>> sleepData = 
          await _sleepTrackingController.getLast7DaysSleepData(user.userId);
        
        setState(() {
          last7DaysSleepData = sleepData;

          // Convert and find max sleep hours
          maxSleepHours = sleepData.isNotEmpty
              ? sleepData
                  .map((e) => double.tryParse(e['total_sleep_hours'].toString()) ?? 0.0)
                  .reduce((a, b) => a > b ? a : b)
              : 8.0;

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          daysOfWeek.length,
          (index) {
            // Find the sleep data for the current day
            final dayData = last7DaysSleepData.firstWhere(
              (data) => data['day_of_week'] == daysOfWeek[index], 
              orElse: () => {'total_sleep_hours': 0.0}
            );

            // Convert to double safely
            final double sleepHours = double.tryParse(dayData['total_sleep_hours'].toString()) ?? 0.0;
            
            final double heightPercentage = maxSleepHours > 0
                ? (sleepHours / maxSleepHours) * 150
                : 0.0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${sleepHours.toStringAsFixed(1)} hours of sleep"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Tooltip(
                          message: "${sleepHours.toStringAsFixed(1)} hours",
                          triggerMode: TooltipTriggerMode.tap,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: heightPercentage > 0 ? heightPercentage : 1.0,
                            width: 15,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      daysOfWeek[index],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
