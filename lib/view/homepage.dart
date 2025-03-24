import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'activitypage.dart';
import 'cognitiveassistantpage.dart';
import 'custom_app_bar.dart';
import 'glucosetrackingpage.dart';
import 'sleeptrackingpage.dart';
import 'languagebar.dart';
import "../model/user_model.dart";


class HomePage extends StatefulWidget {

  final UserModel user;

  const HomePage({super.key, required this.user});



  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final double lessThan6Hours = 100; // Example values
  final double moreThan7Hours = 200;


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    double totalsleep = lessThan6Hours + moreThan7Hours;
    double lessThan6HoursPercentage = (lessThan6Hours / totalsleep) * 100;
    double moreThan7HoursPercentage = (moreThan7Hours / totalsleep) * 100;
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Greeting Section
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage("assets/user.png"), // Replace with actual image
                  radius: 30,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi ${widget.user.username}!",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text("Good morning, what will you do today?",
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sleep Tracking Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular Progress Box
                  Container(
                    width: 120, // Fixed width
                    height: 130, // Fixed height for consistency
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: lessThan6HoursPercentage / 100,
                            strokeWidth: 6,
                            backgroundColor: Colors.red,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12), // Consistent spacing

                  // Sleep Data Box (Responsive)
                  Expanded( // This prevents overflow
                    child: Container(
                      height: 130, // Same height as circular box
                      padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 12.0), // Less top padding
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and "See All" Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Sleep",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle "See All" action
                                  },
                                  child: Text(
                                    "See All",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      decoration: TextDecoration.none, // Default no underline
                                    ),
                                  ),
                                ),
                                onHover: (event) {
                                  // Change text to have an underline on hover
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Sleep Data with Right-Aligned Percentages
                          Row(
                            children: [
                              const Expanded(
                                child: Text("< 6 Hours"),
                              ),
                              Text(
                                //value less than 6 hours aku declare kat atas
                                "${lessThan6HoursPercentage.toStringAsFixed(0)} %",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(
                                child: Text("> 7 Hours"),
                              ),
                              Text(
                                //value more than 7 hours aku declare kat atas
                                "${moreThan7HoursPercentage.toStringAsFixed(0)} %",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Average Text
                          const Text(
                            "Average: Good",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Today's Activity Section
            // Horizontal Scrollable Activity Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Activity",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ActivityPage(fromHome: true,)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3674B5), // Background color
                          foregroundColor: Colors.white, // Text color
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduce padding
                          minimumSize: const Size(70, 30), // Set a smaller height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Adjust corner radius if needed
                          ),
                        ),
                        child: const Text(
                          "See All",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),
                  SizedBox(
                    height: 160,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildActivityCard("Sleep Tracking", "assets/sleep.png", Color(0xFFFFF6E3), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SleepTrackingPage()),
                            );
                          }),
                          _buildActivityCard("Cognitive Assistant", "assets/cognitive.png", Colors.lightBlue.shade100, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CognitiveAssistantPage()),
                            );
                          }),
                          _buildActivityCard("Glucose Tracking", "assets/glucose.png", Colors.lightGreen.shade100, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GlucoseTrackingPage()),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "AI Chat",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 100, // Same height as circular box
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 12.0), // Less top padding
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      "AI chatbox description",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3674B5)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, String imagePath, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Container(
          width: 130, // Adjusted for better proportion
          height: 140,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title above the image
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Image inside box
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain, // Ensures proper fit
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}