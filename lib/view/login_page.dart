import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/user_controller.dart';
import 'forgot_password.dart';
import 'main_navigation_screen.dart';
import 'package:provider/provider.dart';
import '../AuthProvider/Auth_provider.dart' as local_auth;
import 'package:google_sign_in/google_sign_in.dart';
import "../model/user_model.dart";

import 'signup_form.dart';
// import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DraggableScrollableController _forgotPasswordController = DraggableScrollableController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final UserController _userController = UserController();
  GoogleSignIn signIn = GoogleSignIn();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void googleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await signIn.signOut();
      final user = await signIn.signIn();

      if (user != null) {
        print("Sign in successful!");
        print("User data: $user");

        final String displayName = user.displayName ?? "User";
        final String email = user.email;

        UserModel? response = await _userController.handleGoogleSignIn(displayName, email);

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (response != null) {
          // Provider.of<local_auth.AuthProvider>(context, listen: false).login();
          Provider.of<local_auth.AuthProvider>(context, listen: false).login(response);
          print("AuthProvider State: Logged in -> ${Provider.of<local_auth.AuthProvider>(context, listen: false).isLoggedIn}");

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Success"),
              content: const Text("Google Sign-In Successful!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MainNavigationScreen(user: response),
                      ),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: Text(response?.message ?? "An unknown error occurred."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        print("Sign in canceled or failed");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Sign in failed with error: $e");

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Sign in failed: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      print("Login Failed: Username or password is empty");
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Please enter both username and password."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    UserModel? response = await _userController.login(username, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response != null) {
      print("Login Successful: User $username has logged in.");
      Provider.of<local_auth.AuthProvider>(context, listen: false).login(response);
      print("AuthProvider State: Logged in -> ${Provider.of<local_auth.AuthProvider>(context, listen: false).isLoggedIn}");

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Login Successful!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainNavigationScreen(user: response),
                  ),
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      print("Login Failed: $response");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(response?.message ?? "An unknown error occurred."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3674B5),
      body: Stack(
        children: [
          Column(
            children: [
              //const SizedBox(height: 10),
              Container(
                color: const Color(0xFF3674B5),
                height: 260.0,
                width: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/icon.png',
                        height: 255,
                      ),
                      //const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Username",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  _sheetController.animateTo(
                                    0.8,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      color: Color(0xFF3674B5),
                                      fontFamily: 'Inter'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 143, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _login,
                              child: const Text(
                                "LOG IN",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'Inter'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Don’t have an account? ",
                                  style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _sheetController.animateTo(
                                      0.8,
                                      duration:
                                      const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up ',
                                    style: TextStyle(
                                      color: Color(0xFF3674B5),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.black54,
                                    thickness: 1,
                                    endIndent: 10,
                                  ),
                                ),
                                Text(
                                  "Or",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.black54,
                                    thickness: 1,
                                    indent: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: googleSignIn,
                              child: Container(
                                width: 40, // Square shape
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/googleicon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SignUpForm(sheetController: _sheetController),
          ForgotPasswordForm(sheetController: _forgotPasswordController),
        ],
      ),
    );
  }
}
