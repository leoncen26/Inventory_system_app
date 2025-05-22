import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inventory_system/admin/main_page_admin.dart';
import 'package:inventory_system/firebase_options.dart';
import 'package:inventory_system/user/auth_page.dart';
import 'package:inventory_system/user/main_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory System',
      theme: ThemeData(
        primaryColor: const Color(0xFF6200EE),
        primarySwatch: Colors.deepOrange,
        hintColor: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _getUserRole(User? user) async {
    if (user == null) return null;

    try {
      // Ambil data user dari Firestore berdasarkan email
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final role = snapshot.docs.first.data()['role'];
        return role;
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: _getUserRole(snapshot.data), // Ambil role user
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (roleSnapshot.hasData) {
                // Arahkan halaman sesuai role
                if (roleSnapshot.data == 'admin') {
                  return const AdminMainPage(); // Halaman Admin
                } else {
                  return const MainPage(); // Halaman User
                }
              } else {
                return const Center(child: Text('Failed to fetch user role.'));
              }
            },
          );
        } else {
          return const AuthPage(); // Jika belum login
        }
      },
    );
  }
}
