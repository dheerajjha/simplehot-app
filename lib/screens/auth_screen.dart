// Input: None
// Output: Authentication screen that toggles between login and register

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  void _onAuthSuccess() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showLogin
        ? LoginScreen(
            onRegisterPressed: _toggleAuthMode,
            onLoginSuccess: _onAuthSuccess,
          )
        : RegisterScreen(
            onLoginPressed: _toggleAuthMode,
            onRegisterSuccess: _onAuthSuccess,
          );
  }
}
