import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_system/profile/edit_profile_page.dart';
import 'package:inventory_system/profile/get_user_profile.dart';
import 'package:inventory_system/user/auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;

  // Document IDs
  List<String> docIDs = [];

  // Get docIDs
  Future<void> getDocId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach((document) {
            docIDs.add(document.reference.id);
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 27, 52, 71),
              Color.fromARGB(255, 44, 179, 190),
              Colors.grey,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profil pengguna
            // CircleAvatar(
            //   radius: 60,
            //   backgroundImage: NetworkImage(user.photoURL ??
            //       'https://via.placeholder.com/150'), // Placeholder jika foto tidak tersedia
            // ),
            const SizedBox(height: 15),
            Text(
              user.email ?? "User Name",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              user.email!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // Menampilkan profil pengguna
            Expanded(
              child: FutureBuilder(
                future: getDocId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Error fetching data.",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docIDs.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white70,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ListTile(
                            title: GetUserProfile(documentId: docIDs[index]),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Baris tombol untuk Edit Profil dan Keluar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Edit Profil
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 44, 179, 190),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Tombol Keluar
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AuthPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
