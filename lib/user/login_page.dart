import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_system/admin/main_page_admin.dart';
import 'package:inventory_system/user/forgot_pass_page.dart';
import 'package:inventory_system/user/main_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;

  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> signIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final email = userCredential.user?.email;

      if (email != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final userData = snapshot.docs.first.data();
          final role = userData['role'];

          if (role == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminMainPage()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          }
        } else {
          throw Exception("User data not found in Firestore");
        }
      }
    } catch (e) {
      print('Login Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // Color(0xFF0051BA), // Blue from logo
              // Color(0xFF4CAF50), // Green from logo
              // Color(0xFFB0BEC5),
              Color.fromARGB(255, 27, 52, 71),
              Color.fromARGB(255, 44, 179, 190), // Grey from logo
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/LogoApps.png', // Path to your logo
                    height: 250,
                  ),
                  const SizedBox(height: 20),

                  // Sign In Text
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email input field
                  _buildTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 20),

                  // Password input field with visibility toggle
                  _buildPasswordField(_passwordController, 'Password'),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign In Button
                  GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 27, 52, 71),
                            Color.fromARGB(255, 44, 179, 190),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Sign Up Prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200], // Ganti warna menjadi abu-abu terang
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: controller,
          style:
              const TextStyle(color: Colors.black), // Ubah teks menjadi hitam
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.black), // Ikon berwarna hitam
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  icon: const Icon(Icons.lock, color: Colors.black),
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
