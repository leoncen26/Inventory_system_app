import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetUserProfile extends StatelessWidget {
  final String documentId;
  final user = FirebaseAuth.instance.currentUser!;

  GetUserProfile({required this.documentId});

  @override
  Widget build(BuildContext context) {
    // mengambil collection user
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Username: ${data['username']}',
                    style: TextStyle(fontSize: 16, color: Colors.black), // Sesuaikan ukuran font
                  ),
                  SizedBox(height: 8), // Jarak antar baris
                  Text(
                    'Email: ${user.email}',
                    style: TextStyle(fontSize: 16, color: Colors.black), // Sesuaikan ukuran font
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Phone: ${data['phone']}',
                    style: TextStyle(fontSize: 16, color: Colors.black), // Sesuaikan ukuran font
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gender: ${data['gender']}',
                    style: TextStyle(fontSize: 16, color: Colors.black), // Sesuaikan ukuran font
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Date of Birth: ${data['dob']}',
                    style: TextStyle(fontSize: 16, color: Colors.black), // Sesuaikan ukuran font
                  ),SizedBox(height: 8),
                  // Text(
                  //   'role: ${data['role']}',
                  //   style: TextStyle(fontSize: 16, color: Colors.black), // Sesuaikan ukuran font
                  // ),
                ],
              ),
            );
          }
          return Text('loading...');
        });
  }
}
