import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../AuthProvider/Auth_provider.dart';
import '../../controller/sleep_tracking_controller.dart';
import 'package:intl/intl.dart'; 

class Last1MonthBarChart extends StatefulWidget {
  const Last1MonthBarChart({Key? key}) : super(key: key);

  @override
  _Last1MonthBarChartState createState() => _Last1MonthBarChartState();
}

class _Last1MonthBarChartState extends State<Last1MonthBarChart> {
  final SleepTrackingController _sleepTrackingController = SleepTrackingController();
  List<Map<String, dynamic>> last1MonthSleepData = [];
  bool _isLoading = true;
  double maxSleepHours = 8.0;

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
            await _sleepTrackingController.getLast1MonthSleepData(user.userId);

            print("Sleep data inside fetchsleepdata: $sleepData");

        setState(() {
          last1MonthSleepData = sleepData;
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

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: last1MonthSleepData.map((sleepEntry) {
            final String sleepDate = sleepEntry['week_start'] ?? 'Unknown';
            final double sleepHours =
                double.tryParse(sleepEntry['total_sleep_hours'].toString()) ?? 0.0;

            final double heightPercentage = maxSleepHours > 0
                ? (sleepHours / maxSleepHours) * 150
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$sleepHours hours of sleep on $sleepDate"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Tooltip(
                        message: "$sleepHours hours",
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
                  DateFormat("dd MMM").format(DateTime.parse(sleepDate)), 
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
