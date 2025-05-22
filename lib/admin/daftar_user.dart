import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_system/admin/detail_user_page.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pengguna',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 44, 179, 190),
              Colors.grey,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada pengguna yang ditemukan.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final data = users[index].data() as Map<String, dynamic>;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 44, 179, 190),
                      child: Text(
                        data['username']?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      data['username'] ?? 'Tidak Ada Nama',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(data['email'] ?? 'Tidak Ada Email'),
                    onTap: () {
                      // Navigasi ke DetailUserPage ketika seluruh item ditekan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailUserPage(userId: users[index].id),
                        ),
                      );
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
