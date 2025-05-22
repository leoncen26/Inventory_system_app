import 'package:flutter/material.dart';
import 'package:inventory_system/user/login_page.dart';
import 'package:inventory_system/user/registration_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  
  //show login page
  bool showLoginPage = true;

  void toggleScreens(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return LoginPage(showRegisterPage:toggleScreens);
    } else{
      return RegistrationPage(showLoginPage:toggleScreens);
    }
  }
}