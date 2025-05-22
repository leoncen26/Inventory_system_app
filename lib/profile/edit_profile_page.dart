import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _docId; // To store the document ID from Firestore

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page opens
  }

  // Function to load user data from Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final userData = snapshot.docs.first;
          _docId = userData.id;

          // Fill fields with user data
          setState(() {
            _usernameController.text = userData['username'];
            _emailController.text = userData['email'];
            _phoneController.text = userData['phone'];
            _selectedGender = userData['gender'];
            _selectedDate = DateTime.tryParse(userData['dob'] ?? '');
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User document not found')),
          );
        }
      } catch (e) {
        print('Error fetching user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    }
  }

  // Function to update user data in Firestore
  Future<void> updateUser(String username, String email, String phone,
      String gender, String dob, String? password) async {
    if (_docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document ID found')),
      );
      return;
    }

    try {
      final dataToUpdate = {
        'username': username,
        'email': email,
        'phone': phone,
        'gender': gender,
        'dob': dob,
        'timestamp': Timestamp.now(),
      };

      if (password != null && password.isNotEmpty) {
        dataToUpdate['password'] = password; // Tambahkan password jika diubah
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_docId)
          .update(dataToUpdate);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Failed to update user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  // Function to reauthenticate and update password
  Future<void> updatePassword(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Ask the user for their current password
        String? currentPassword = await _showPasswordDialog();

        if (currentPassword == null) {
          // User canceled the dialog
          return;
        }

        // Create credentials using the current password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        // Reauthenticate the user
        await user.reauthenticateWithCredential(credential);

        // Update the password after reauthentication
        await user.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      } catch (e) {
        print('Failed to update password: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: $e')),
        );
      }
    }
  }

// Function to show a dialog for entering the current password
  Future<String?> _showPasswordDialog() async {
    final currentPasswordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reauthenticate'),
        content: TextField(
          controller: currentPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Current Password',
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(currentPasswordController.text), // Submit
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Function to validate input
  bool _validateInput() {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return false;
    }
    return true;
  }

  // Function to save changes
  Future<void> _saveChanges() async {
    if (_validateInput()) {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final gender = _selectedGender ?? 'Not Specified';
      final dob = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : 'Not Chosen';
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (password.isEmpty && confirmPassword.isEmpty) {
        // Jika password tidak diubah
        await updateUser(
          username,
          email,
          phone,
          gender,
          dob,
          null, // Kirimkan null sebagai parameter password
        );
      } else if (password == confirmPassword) {
        // Jika password baru valid
        await updateUser(
          username,
          email,
          phone,
          gender,
          dob,
          password,
        );
        await updatePassword(password);
      } else {
        // Jika password baru tidak cocok
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
      }
    }
  }

  // Function to select date of birth
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 27, 52, 71),
                Color.fromARGB(255, 44, 179, 190),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey[100], // Consistent background color
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      TextField(
                        controller: _emailController,
                        enabled: false, // Email cannot be changed
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        hint: const Text('Select Gender'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                              value: 'Female', child: Text('Female')),
                          DropdownMenuItem(
                              value: 'Not Specified',
                              child: Text('Prefer not to say')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.transgender),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: TextEditingController(
                              text: _selectedDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate!)
                                  : 'Select Date of Birth',
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                              255, 44, 179, 190), // Consistent button color
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
