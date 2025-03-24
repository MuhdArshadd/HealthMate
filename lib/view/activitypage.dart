import 'package:flutter/material.dart';

import 'cognitiveassistantpage.dart';
import 'custom_app_bar.dart';
import 'custom_nav_bar.dart';
import 'glucosetrackingpage.dart';
import 'main_navigation_screen.dart';
import 'sleeptrackingpage.dart';

import 'package:provider/provider.dart';
import '../AuthProvider/Auth_provider.dart';
import "../model/user_model.dart";

class ActivityPage extends StatelessWidget {
  final bool fromHome; // Flag to indicate navigation from HomePage

  const ActivityPage({super.key, required this.fromHome});

  

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
      appBar: CustomAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 50),
          _buildActivityItem("Sleep Tracking", "assets/sleep.png", Color(0xFFFFF6E3), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SleepTrackingPage()),
            );
          }),
          const SizedBox(height: 30),
          _buildActivityItem("Cognitive Assistant", "assets/cognitive.png", Colors.lightBlue.shade100, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CognitiveAssistantPage()),
            );
          }),
          const SizedBox(height: 30),
          _buildActivityItem("Glucose Tracking", "assets/glucose.png", Colors.lightGreen.shade100, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GlucoseTrackingPage()),
            );
          }),
          // Add more activities as needed
        ],
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
    );
  }

  Widget _buildActivityItem(String title, String imagePath, Color containerColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 100, // Increased width for the image container
                height: 100, // Increased height for the image container
                alignment: Alignment.center,
                child: Image.asset(
                  imagePath,
                  width:100, // Increased image width
                  height: 100, // Increased image height
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}