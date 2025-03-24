// import 'package:flutter/material.dart';
//
// import 'custom_app_bar.dart';
// import 'custom_nav_bar.dart';
// import 'main_navigation_screen.dart';
//
// class CognitiveGamePage extends StatefulWidget {
//   @override
//   _CognitiveGamePageState createState() => _CognitiveGamePageState();
// }
//
// class _CognitiveGamePageState extends State<CognitiveGamePage> {
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: CustomAppBar(),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Sleep Tracking Header
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.lightBlue.shade100,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: Offset(0, 3),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "Time Taken: 0.08",
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Image.asset(
//                     "assets/cognitive.png",
//                     width: 100,
//                     height: 100,
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 35),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               padding: const EdgeInsets.all(16),
//               height: 300,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFD3E0E3),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//
//                 ],
//               ),
//             ),
//
//             //Restart button section
//             // Restart Button (Bottom Right)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Align(
//                 alignment: Alignment.bottomRight,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Restart game logic
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => CognitiveGamePage(),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFD3E0E3),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: Text(
//                     'Restart',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: 0, // Keeps Home highlighted
//         onTap: (index) {
//           // Navigate back to MainNavigationScreen with the correct index
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => MainNavigationScreen(selectedIndex: index),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }