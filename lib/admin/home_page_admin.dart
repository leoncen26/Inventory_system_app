import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_system/admin/barang_keluar.dart';
import 'package:inventory_system/admin/barang_masuk.dart';
import 'package:inventory_system/admin/daftar_user.dart';
import 'package:inventory_system/admin/grafik_page.dart';
import 'package:inventory_system/admin/product.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String username = '';
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

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
            username = data['username'] ?? 'Admin';
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
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 27, 52, 71),
                  Color.fromARGB(255, 44, 179, 190),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Color.fromARGB(255, 27, 52, 71),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      username.isNotEmpty ? username : 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              itemCount: 5,
              itemBuilder: (context, index) {
                final items = [
                  _buildMenuItem(Icons.inventory_2, 'Inventory', ProductPage()),
                  _buildMenuItem(
                      Icons.shopping_cart, 'Order', BarangKeluarPage()),
                  _buildMenuItem(
                      Icons.bar_chart, 'Metrics & Analytics', GrafikMenuPage()),
                  _buildMenuItem(
                      Icons.local_shipping, 'Suppliers', BarangMasukPage()),
                  _buildMenuItem(Icons.person, 'List User', UserListPage()),
                ];
                return items[index];
              },
            ),
          ),
        ],
      ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 44, 179, 190),
              Color.fromARGB(255, 27, 52, 71),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
