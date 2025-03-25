import 'package:flutter/material.dart';
import 'chatbotpage.dart';
import 'custom_nav_bar.dart';
import 'homepage.dart';
import 'profilepage.dart';
import '../model/user_model.dart';

class MainNavigationScreen extends StatefulWidget {
  final int selectedIndex;
  final UserModel user; 

    const MainNavigationScreen({super.key, this.selectedIndex = 0, required this.user});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(user: widget.user),
      ChatbotPage(),
      ProfilePage(user: widget.user),
    ];

    return Scaffold(
      body: _pages[_selectedIndex], 
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
