import 'package:flutter/material.dart';

import '../../../view/custom_app_bar.dart';
import '../../../view/custom_nav_bar.dart';
import '../../../view/main_navigation_screen.dart';
import '../../utils/constants.dart';
import '../widgets/game_options.dart';

import 'package:provider/provider.dart';
import '../../../AuthProvider/Auth_provider.dart';
import "../../../model/user_model.dart";


class StartUpPage extends StatelessWidget {
  const StartUpPage({super.key});

  @override
  Widget build(BuildContext context) {

        final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  gameTitle,
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  gamePrompt,
                  style: TextStyle(fontSize: 18, color: Colors.black), // Slightly darker text
                  textAlign: TextAlign.center,
                ),
                GameOptions(),
              ]),
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
    );
  }
}