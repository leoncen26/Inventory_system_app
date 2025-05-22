import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailUserPage extends StatelessWidget {
  final String userId;

  const DetailUserPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'Detail Pengguna',
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
          width: double.infinity,
          height: double.infinity,
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
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Data pengguna tidak ditemukan.',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Avatar dengan latar belakang gradient
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Color.fromARGB(255, 27, 52, 71),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Color.fromARGB(255, 44, 179, 190),
                          child: Text(
                            data['username']?.substring(0, 1).toUpperCase() ??
                                '?',
                            style: const TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nama pengguna sebagai judul
                      Text(
                        data['username'] ?? 'Tidak Ada Nama',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email pengguna
                      Text(
                        data['email'] ?? 'Tidak Ada Email',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const Divider(height: 40, thickness: 2),
                      // Informasi detail
                      _buildDetailCard('No. Telepon', data['phone']),
                      _buildDetailCard('Jenis Kelamin', data['gender']),
                      _buildDetailCard('Tanggal Lahir', data['dob']),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }

  Widget _buildDetailCard(String title, String? value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _getIconForDetail(title),
              size: 28,
              color: Colors.brown,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? 'Tidak ada data',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForDetail(String title) {
    switch (title) {
      case 'No. Telepon':
        return Icons.phone;
      case 'Jenis Kelamin':
        return Icons.person;
      case 'Tanggal Lahir':
        return Icons.cake;
      default:
        return Icons.info;
    }
  }
}
