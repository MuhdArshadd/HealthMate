import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthmate/AuthProvider/Auth_provider.dart';
import 'login_page.dart';
import 'homepage.dart';
import 'chatbotpage.dart';
import 'profilepage.dart';
import 'custom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ChatbotPage(),
    const ProfilePage(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Redirect to login if the user is not logged in
    if (!authProvider.isLoggedIn) {
      return LoginPage();
    }

    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
