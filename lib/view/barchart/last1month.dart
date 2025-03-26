import 'package:flutter/material.dart';

class Last1MonthBarChart extends StatelessWidget {
  final List<double> sleepData;
  final double maxSleepHours;
  final List<String> daysOfWeek;

  const Last1MonthBarChart({
    Key? key,
    required this.sleepData,
    required this.maxSleepHours,
    this.daysOfWeek = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          sleepData.length,
          (index) {
            final double heightPercentage = maxSleepHours > 0
                ? (sleepData[index] / maxSleepHours) * 150
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
                              content: Text("${sleepData[index].toStringAsFixed(1)} hours of sleep"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Tooltip(
                          message: "${sleepData[index].toStringAsFixed(1)} hours",
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
                      daysOfWeek[index % 7],
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