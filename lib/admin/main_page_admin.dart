import 'package:flutter/material.dart';
import 'package:inventory_system/admin/home_page_admin.dart';
import 'package:inventory_system/admin/product.dart';
import 'package:inventory_system/profile/profile_page.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  // Remove the 'const' keyword from the list and provide default values for BookingPage's required parameters.
  static final List<Widget> _pages = <Widget>[
    AdminHome(),
    ProductPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // Custom height for AppBar
        child: AppBar(
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
            'Inventory System',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.white,
            onPressed: () {
              // Handle menu action
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              color: Colors.white,
              onPressed: () {
                // Handle notifications action
              },
            ),
          ],
        ),
      ),
      body: Container(
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
        child: Center(
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.storage), label: 'Product'),
            // BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Checkout'),
            // BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.white70,
          backgroundColor: Colors.transparent, // Transparent to show gradient
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
