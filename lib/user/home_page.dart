import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_system/admin/barang_keluar.dart';
import 'package:inventory_system/admin/barang_masuk.dart';
import 'package:inventory_system/user/user_inventory.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  // Fungsi untuk mengambil username dari Firestore
  Future<void> fetchUsername() async {
    try {
      if (user?.email != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user!.email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          setState(() {
            username = data['username'] ?? 'User';
          });
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
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
              Color.fromARGB(255, 44, 179, 190),
              Colors.grey,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildWelcomeSection(),
            Expanded(
              child: _buildMenuList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            username.isNotEmpty ? username : 'Loading...',
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _buildMenuItem(Icons.inventory_2, 'Inventory', UserInventoryPage()),
        _buildMenuItem(Icons.shopping_cart, 'Order', BarangKeluarPage()),
        _buildMenuItem(Icons.local_shipping, 'Suppliers', BarangMasukPage()),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Widget destinationPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blueGrey),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
