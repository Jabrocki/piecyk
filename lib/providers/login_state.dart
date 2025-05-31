import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginState extends ChangeNotifier {
  late User _user;

  set user(User user) {
    _user = user;
    notifyListeners();
  }

  User get user => _user;
}