import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RegistrationPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegistrationPage({
    Key? key,
    required this.showLoginPage,
  }) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPage();
}

class _RegistrationPage extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneController = TextEditingController();
  // final _roleController = TextEditingController(text: 'user');

  String? _selectedGender;
  DateTime? _selectedDate;

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future signUp() async {
    if (passwordConfirmed()) {
      try {
        // Mendaftarkan pengguna menggunakan Firebase Authentication
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Menyimpan data pengguna ke Firestore, termasuk role sebagai 'user'
        await addUserDetails(
          _userNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _phoneController.text.trim(),
          _selectedGender ?? 'Not Chosen',
          _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : 'Not Chosen',
          role: 'user',
        );

        // Beralih ke halaman login setelah berhasil mendaftar
        widget.showLoginPage();
      } catch (e) {
        // Menangkap dan mencetak error
        print(e.toString());
      }
    }
  }

  // Fungsi `addUserDetails` diperbarui
  Future addUserDetails(String username, String email, String password,
      String phone, String gender, String dob,
      {String role = 'user'}) async {
    await FirebaseFirestore.instance.collection('users').add({
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'role': role,
    });
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 27, 52, 71),
            Color.fromARGB(255, 44, 179, 190), // Purple-ish shade
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
                // Logo or Icon
                Image.asset(
                  'assets/LogoApps.png', // Replace with your logo path
                  height: 150,
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  'Create Account',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Username Field
                _buildTextField('Username', _userNameController, Icons.person),
                const SizedBox(height: 20),

                // Email Field
                _buildTextField('Email', _emailController, Icons.email),
                const SizedBox(height: 20),

                // Phone Field
                _buildTextField('Phone Number', _phoneController, Icons.phone),
                const SizedBox(height: 20),

                // Password Field
                _buildPasswordField(
                    'Password', _passwordController, _passwordVisible, () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                }),
                const SizedBox(height: 20),

                // Confirm Password Field
                _buildPasswordField('Confirm Password',
                    _confirmPasswordController, _confirmPasswordVisible, () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                }),
                const SizedBox(height: 20),

                // Gender Dropdown
                _buildDropdown('Select Gender', _selectedGender, (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                }),
                const SizedBox(height: 20),

                // Date of Birth Picker
                _buildDatePicker('Select Date of Birth'),

                const SizedBox(height: 30),

                // // Role Field (Non-editable)
                // _buildRoleField(),

                // const SizedBox(height: 20),

                // Sign Up Button
                GestureDetector(
                  onTap: signUp,
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
                        'SIGN UP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Already a member? Login now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: const Text(
                        ' Login',
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
    ));
  }

  Widget _buildTextField(
      String hintText, TextEditingController controller, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.black),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // // Role Field (Non-editable)
  // Widget _buildRoleField() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.black,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.grey),
  //     ),
  //     padding: const EdgeInsets.symmetric(horizontal: 10),
  //     child: TextField(
  //       controller: _roleController, // Assign the controller
  //       enabled: false, // Prevent user from editing
  //       style: const TextStyle(color: Colors.white),
  //       decoration: InputDecoration(
  //         icon: const Icon(Icons.person, color: Colors.white),
  //         hintText: 'Role',
  //         hintStyle: const TextStyle(color: Colors.grey),
  //         border: InputBorder.none,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPasswordField(String hintText, TextEditingController controller,
      bool isVisible, VoidCallback toggleVisibility) {
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
                obscureText: !isVisible,
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
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String hint, String? value, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButton<String>(
        dropdownColor: Colors.grey[200],
        value: value,
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        isExpanded: true,
        underline: Container(),
        items: const [
          DropdownMenuItem(
              value: 'Male',
              child: Text('Male', style: TextStyle(color: Colors.black))),
          DropdownMenuItem(
              value: 'Female',
              child: Text('Female', style: TextStyle(color: Colors.black))),
          DropdownMenuItem(
              value: 'Not Chosen',
              child: Text('Prefer not to say',
                  style: TextStyle(color: Colors.black))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(String hint) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              _selectedDate == null
                  ? hint
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
