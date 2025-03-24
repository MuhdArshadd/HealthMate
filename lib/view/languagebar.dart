import 'package:flutter/material.dart';

class LanguageDrawer extends StatefulWidget {
  const LanguageDrawer({super.key});

  @override
  _LanguageDrawerState createState() => _LanguageDrawerState();
}

class _LanguageDrawerState extends State<LanguageDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, -1), // Start off-screen (top)
      end: const Offset(0, 0), // Slide down to visible position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(); // Start animation
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity, // FULL-WIDTH
            height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF3674B5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.language, color: Colors.white, size: 30),
                const SizedBox(height: 10),
                _buildLanguageOption(context, "Bahasa Melayu"),
                const SizedBox(height: 10),
                _buildLanguageOption(context, "English"),
                const SizedBox(height: 10),
                _buildLanguageOption(context, "Mandarin"),
                const SizedBox(height: 10),
                _buildLanguageOption(context, "Tamil"),
                const SizedBox(height: 10),
                _buildLanguageOption(context, "Indon"),
                const SizedBox(height: 10), // Extra spacing at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language) {
    return GestureDetector(
      onTap: () {
        _controller.reverse().then((_) => Navigator.pop(context)); // Close with animation
        print("Selected: $language");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12), // Increase spacing
        child: Text(
          language,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}