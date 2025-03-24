import 'package:flutter/material.dart';
import '../model/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  // bool login() {
  //   _isLoggedIn = true;
  //   notifyListeners();
  //   return _isLoggedIn;
  // }

  void login(UserModel user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}