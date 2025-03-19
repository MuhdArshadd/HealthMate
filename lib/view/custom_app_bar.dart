import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthmate/controller/user_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthmate/AuthProvider/Auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:healthmate/view/login_page.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn signIn = GoogleSignIn(); 

    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF3674B5),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF3674B5),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.only(top: 70, left: 16, right: 16, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "15 Mac 2025",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  print("Language icon tapped!"); 
                  bool confirmLogout = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false), 
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true), 
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
                  );

                  if (confirmLogout == true) {
                    await signIn.signOut(); 
                    Provider.of<AuthProvider>(context, listen: false).logout(); 
                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  }
                },
                child: const Icon(Icons.language, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
