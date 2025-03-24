import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import "../model/user_model.dart";
import '../controller/sleep_tracking_controller.dart';

class AddSleepEntryDialog extends StatefulWidget {
  final UserModel user;

  const AddSleepEntryDialog({Key? key, required this.user}) : super(key: key);

  @override
  _AddSleepEntryDialogState createState() => _AddSleepEntryDialogState();
}

class _AddSleepEntryDialogState extends State<AddSleepEntryDialog> {
  final TextEditingController _sleepHoursController = TextEditingController();
  final SleepTrackingController _sleepTrackingController = SleepTrackingController();

  void _submitSleepEntry() async {
    String enteredValue = _sleepHoursController.text.trim();

    if (enteredValue.isEmpty) {
      _showSnackbar("Please enter sleep hours.");
      return;
    }

    final double? sleepHours = double.tryParse(enteredValue);
    if (sleepHours == null || sleepHours <= 0 || sleepHours > 24) {
      _showSnackbar("Enter a valid number for sleep hours.");
      return;
    }

    try {
      String result = await _sleepTrackingController.submitSleepData(
          widget.user.userId,
          sleepHours,
          false, // isWearable (automatically handled in DB)
          null, // No need to send sleepStart
          null  // No need to send sleepEnd
      );

      _showSnackbar(result);

      if (result.contains('successfully')) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackbar('Error submitting sleep data: $e');
    }
  }



  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    String day = DateFormat('EEEE').format(DateTime.now()); // Get current day
    String date = DateFormat('d MMM y').format(DateTime.now()); // Get current date

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🗓 Day & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Day : $day", style: TextStyle(fontSize: 16)),
                Text("Date: $date", style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 20),

            //Sleep Input
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _sleepHoursController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Text("Hours Sleep", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),

            //Submit Button
            ElevatedButton(
              onPressed: _submitSleepEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0XFF3674B5),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
            SizedBox(height: 20),

            //OR Divider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Divider(thickness: 1, color: Colors.black54)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Or", style: TextStyle(fontSize: 16)),
                ),
                Expanded(child: Divider(thickness: 1, color: Colors.black54)),
              ],
            ),
            SizedBox(height: 10),

            //Get From Wearable Device Button
            ElevatedButton(
              onPressed: () {
                print("Fetching data from wearable device...");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey),
                ),
                elevation: 3,
              ),
              child: Text("Get From Wearable Device", style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sleepHoursController.dispose();
    super.dispose();
  }
}