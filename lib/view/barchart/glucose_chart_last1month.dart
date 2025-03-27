import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../AuthProvider/Auth_provider.dart';
import '../../controller/glucose_tracking_controller.dart';

class GlucoseLast1MonthBarChart extends StatefulWidget {
  const GlucoseLast1MonthBarChart({Key? key}) : super(key: key);

  @override
  _GlucoseLast1MonthBarChartState createState() => _GlucoseLast1MonthBarChartState();
}

class _GlucoseLast1MonthBarChartState extends State<GlucoseLast1MonthBarChart> {
  final GlucoseTrackingController _glucoseTrackingController = GlucoseTrackingController();
  List<Map<String, dynamic>> last1MonthGlucoseData = [];
  bool _isLoading = true;
  double maxGlucoseLevel = 10.0;

  // Generate week labels based on the data
  List<String> _generateWeekLabels() {
    return last1MonthGlucoseData
        .map((data) => data['week_start'].toString().substring(5, 10)) // MM-DD format
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchGlucoseData();
  }

  Future<void> _fetchGlucoseData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (user != null) {
      try {
        List<Map<String, dynamic>> glucoseData = 
          await _glucoseTrackingController.getLast1MonthGlucoseData(user.userId);

        print("1 Month Glucose data: $glucoseData");
        
        setState(() {
          last1MonthGlucoseData = glucoseData;

          maxGlucoseLevel = glucoseData.isNotEmpty
              ? glucoseData
                  .map((e) => e['average_glucose_level'] as double)
                  .reduce((a, b) => a > b ? a : b)
              : 10.0;

          _isLoading = false;
        });
      } catch (e) {
        print("Error fetching 1 month glucose data: $e");
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

    final List<String> weekLabels = _generateWeekLabels();

    return Container(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          weekLabels.length,
          (index) {
            final weekData = last1MonthGlucoseData[index];

            final double glucoseLevel = (weekData['average_glucose_level'] is num)
                ? (weekData['average_glucose_level'] as num).toDouble()
                : double.tryParse(weekData['average_glucose_level'].toString()) ?? 0.0;
            
            final double heightPercentage = maxGlucoseLevel > 0
                ? (glucoseLevel / maxGlucoseLevel) * 150
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
                              content: Text("${glucoseLevel.toStringAsFixed(1)} glucose level"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Tooltip(
                          message: "${glucoseLevel.toStringAsFixed(1)} level",
                          triggerMode: TooltipTriggerMode.tap,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: heightPercentage > 0 ? heightPercentage : 1.0,
                            width: 15,
                            decoration: BoxDecoration(
                              color: _getColorForGlucoseLevel(glucoseLevel),
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
                      weekLabels[index],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
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

  // Helper method to color-code glucose levels
  Color _getColorForGlucoseLevel(double glucoseLevel) {
    if (glucoseLevel < 4.0) {
      return const Color.fromARGB(255, 0, 0, 0); // Low glucose
    } else if (glucoseLevel >= 4.0 && glucoseLevel <= 7.0) {
      return const Color.fromARGB(255, 0, 0, 0); // Normal range
    } else {
      return const Color.fromARGB(255, 0, 0, 0); // High glucose
    }
  }
}