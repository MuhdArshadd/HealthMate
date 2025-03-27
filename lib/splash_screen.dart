import 'package:flutter/material.dart';
import 'dart:async';

import 'view/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  late AnimationController _fadeController;
  late Animation<double> _heartOpacity;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    // ECG Wave Draw Animation (Revealing from Left to Right)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));

    _waveController.forward().then((_) {
      _fadeController.forward(); // Fade in heart & text after wave is drawn
    });

    // Heart & Text Fade-in Animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _heartOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Navigate to home screen after full animation
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Heart Appears FIRST (Behind the Wave)
                FadeTransition(
                  opacity: _heartOpacity,
                  child: Image.asset(
                    "assets/heart.png",
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.contain, // Ensures it scales proportionally
                  ),
                ),

                // ECG Wave Animation (Draws from Left to Right)
                AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return ClipRect(
                      clipper: ECGClipper(_waveAnimation.value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    "assets/ecg_wave.png",
                    width: double.infinity, // Ensures full width
                    fit: BoxFit.cover, // Fills entire screen
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // "HelpMate" Text Appears Last
            FadeTransition(
              opacity: _textOpacity,
              child: const Text(
                "HealthMate",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Clipper to animate the ECG wave from left to right
class ECGClipper extends CustomClipper<Rect> {
  final double progress;

  ECGClipper(this.progress);

  @override
  Rect getClip(Size size) {
    double start = 0; // Exact left edge
    double end = size.width * progress; // Scale to full width
    return Rect.fromLTRB(start, 0, end, size.height);
  }

  @override
  bool shouldReclip(ECGClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
