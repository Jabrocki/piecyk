import 'package:flutter/material.dart';

class ToggleMenuState extends ChangeNotifier {
  bool _isMenuVisible = false;

  bool get isMenuVisible => _isMenuVisible;

  void toggleMenu() {
    _isMenuVisible = !_isMenuVisible;
    notifyListeners();
  }

  void showMenu() {
    _isMenuVisible = true;
    notifyListeners();
  }

  void hideMenu() {
    _isMenuVisible = false;
    notifyListeners();
  }
}
