import 'package:flutter/material.dart';

import 'package:carman/pages/login_page.dart';
import 'package:carman/pages/register_page.dart';

class WelcomeShell extends StatelessWidget {
  const WelcomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPage(onSignUpTap: () => _navigateToRegister(context));
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }
}
