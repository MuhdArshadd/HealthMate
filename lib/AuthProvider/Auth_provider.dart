import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  bool login() {
    _isLoggedIn = true; 
    notifyListeners();
    return _isLoggedIn; 
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
