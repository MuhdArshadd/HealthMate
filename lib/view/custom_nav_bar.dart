import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  // ignore: library_private_types_in_public_api
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  double _positionX = 0.0;
  double _iconOpacity = 1.0; // Controls icon visibility

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFloatingPosition(widget.currentIndex, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _updateFloatingPosition(widget.currentIndex);
    }
  }

  void _updateFloatingPosition(int index, {bool animate = true}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double newPosition = index == 0
        ? screenWidth / 6 - 30
        : index == 1
        ? screenWidth / 2 - 30
        : screenWidth * 5 / 6 - 30;

    if (animate) {
      setState(() {
        _iconOpacity = 0.0; // Fade out icon immediately when movement starts
        _positionX = newPosition;
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _iconOpacity = 1.0; // Fade in icon after reaching target
          });
        }
      });
    } else {
      setState(() {
        _positionX = newPosition;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF3674B5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.chat, "Chatbot", 1),
              _buildNavItem(Icons.person, "Profile", 2),
            ],
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: _positionX,
          top: -20,
          child: _buildFloatingItem(widget.currentIndex),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: index == widget.currentIndex ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: index == widget.currentIndex ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingItem(int index) {
    IconData icon = index == 0
        ? Icons.home
        : index == 1
        ? Icons.chat
        : Icons.person;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF3674B5), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100), // Faster disappearance
          opacity: _iconOpacity,
          child: Icon(icon, color: const Color(0xFF3674B5), size: 30),
        ),
      ),
    );
  }
}
