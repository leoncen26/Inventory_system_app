import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  // CREATE: Add a new product with ID, stok, and kategori
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock, // Tambahkan stok
    required String imageUrl,
    required String category, // Tambahkan kategori
  }) async {
    QuerySnapshot allProducts = await products.get();
    int newIdNumber = allProducts.docs.length + 1;

    String productId = 'P${newIdNumber.toString().padLeft(2, '0')}';

    return products.doc(productId).set({
      'id': productId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock, // Tambahkan stok
      'category': category, // Tambahkan kategori
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: Get all products
  Stream<QuerySnapshot> getProductsStream() {
    return products.orderBy('timestamp', descending: true).snapshots();
  }

  // READ: Get single product
  Future<Map<String, dynamic>> getProduct(String productId) async {
    DocumentSnapshot doc = await products.doc(productId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      throw Exception("Product not found");
    }
  }

  // UPDATE: Update product data
  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock, // Tambahkan stok
    required String category, // Tambahkan kategori
    required String imageUrl,
  }) async {
    Map<String, dynamic> updatedData = {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock, // Tambahkan stok
      'category': category, // Tambahkan kategori
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    };

    return products.doc(productId).update(updatedData);
  }

  // DELETE: Delete product
  Future<void> deleteProduct(String productId) async {
    return products.doc(productId).delete();
  }

  // Future<void> addBarangMasuk({
  //   required String namaBarang,
  //   required int jumlah,
  //   required String supplier,
  //   required DateTime tanggal,
  // }) async {
  //   try {
  //     // Ambil semua dokumen dalam koleksi 'barang_masuk'
  //     QuerySnapshot allBarangMasuk =
  //         await FirebaseFirestore.instance.collection('barang_masuk').get();

  //     // Hitung ID baru berdasarkan jumlah dokumen
  //     int newIdNumber = allBarangMasuk.docs.length + 1;

  //     // Format ID menjadi "BM01", "BM02", dst
  //     String barangMasukId = 'BM${newIdNumber.toString().padLeft(2, '0')}';

  //     // Tambahkan data ke Firestore dengan ID yang sudah diformat
  //     await FirebaseFirestore.instance
  //         .collection('barang_masuk')
  //         .doc(barangMasukId)
  //         .set({
  //       'id': barangMasukId, // Simpan ID di dokumen
  //       'tanggal': Timestamp.fromDate(tanggal),
  //       'nama_barang': namaBarang,
  //       'jumlah': jumlah,
  //       'supplier': supplier,
  //       'created_at': FieldValue.serverTimestamp(),
  //       'updated_at': FieldValue.serverTimestamp(),
  //     });

  //     print('Barang masuk dengan ID $barangMasukId berhasil ditambahkan.');
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Future<void> addBarangMasuk({
    required String namaBarang,
    required int jumlah,
    required String supplier,
    required DateTime tanggal,
  }) async {
    try {
      // Ambil semua dokumen dalam koleksi 'barang_masuk'
      QuerySnapshot allBarangMasuk =
          await FirebaseFirestore.instance.collection('barang_masuk').get();

      // Hitung ID baru berdasarkan jumlah dokumen
      int newIdNumber = allBarangMasuk.docs.length + 1;

      // Format ID menjadi "BM01", "BM02", dst
      String barangMasukId = 'BM${newIdNumber.toString().padLeft(2, '0')}';

      // Periksa apakah waktu di `tanggal` tersedia, jika tidak, tambahkan waktu sekarang
      if (tanggal.hour == 0 && tanggal.minute == 0 && tanggal.second == 0) {
        tanggal = DateTime(
          tanggal.year,
          tanggal.month,
          tanggal.day,
          DateTime.now().hour,
          DateTime.now().minute,
          DateTime.now().second,
        );
      }

      // Tambahkan data ke Firestore dengan ID yang sudah diformat
      await FirebaseFirestore.instance
          .collection('barang_masuk')
          .doc(barangMasukId)
          .set({
        'id': barangMasukId, // Simpan ID di dokumen
        'tanggal': Timestamp.fromDate(tanggal), // Tanggal dan waktu lengkap
        'nama_barang': namaBarang,
        'jumlah': jumlah,
        'supplier': supplier,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('Barang masuk dengan ID $barangMasukId berhasil ditambahkan.');
    } catch (e) {
      print('Error: $e');
    }
  }

//   Future<void> addBarangKeluar({
//   required String namaBarang,
//   required int jumlah,
//   required String tujuan, // Tujuan barang keluar
//   required DateTime tanggal,
// }) async {
//   try {
//     // Ambil semua dokumen dalam koleksi 'barang_keluar'
//     QuerySnapshot allBarangKeluar =
//         await FirebaseFirestore.instance.collection('barang_keluar').get();

//     // Hitung ID baru berdasarkan jumlah dokumen
//     int newIdNumber = allBarangKeluar.docs.length + 1;

//     // Format ID menjadi "BK01", "BK02", dst
//     String barangKeluarId = 'BK${newIdNumber.toString().padLeft(2, '0')}';

//     // Tambahkan data ke Firestore dengan ID yang sudah diformat
//     await FirebaseFirestore.instance
//         .collection('barang_keluar')
//         .doc(barangKeluarId)
//         .set({
//       'id': barangKeluarId, // Simpan ID di dokumen
//       'tanggal': Timestamp.fromDate(tanggal),
//       'nama_barang': namaBarang,
//       'jumlah': jumlah,
//       'tujuan': tujuan, // Tambahkan tujuan barang keluar
//       'created_at': FieldValue.serverTimestamp(),
//       'updated_at': FieldValue.serverTimestamp(),
//     });

//     print('Barang keluar dengan ID $barangKeluarId berhasil ditambahkan.');
//   } catch (e) {
//     print('Error: $e');
//   }
// }

  Future<void> addBarangKeluar({
    required String namaBarang,
    required int jumlah,
    required String tujuan,
    required DateTime tanggal,
  }) async {
    try {
      // Ambil semua dokumen dalam koleksi 'barang_keluar'
      QuerySnapshot allBarangKeluar =
          await FirebaseFirestore.instance.collection('barang_keluar').get();

      // Hitung ID baru berdasarkan jumlah dokumen
      int newIdNumber = allBarangKeluar.docs.length + 1;

      // Format ID menjadi "BK01", "BK02", dst
      String barangKeluarId = 'BK${newIdNumber.toString().padLeft(2, '0')}';

      // Buat DateTime dengan waktu sekarang jika waktu tidak disertakan
      if (tanggal.hour == 0 && tanggal.minute == 0 && tanggal.second == 0) {
        tanggal = DateTime(
          tanggal.year,
          tanggal.month,
          tanggal.day,
          DateTime.now().hour,
          DateTime.now().minute,
          DateTime.now().second,
        );
      }

      // Tambahkan data ke Firestore dengan ID yang sudah diformat
      await FirebaseFirestore.instance
          .collection('barang_keluar')
          .doc(barangKeluarId)
          .set({
        'id': barangKeluarId,
        'tanggal': Timestamp.fromDate(tanggal), // Tanggal dan waktu lengkap
        'nama_barang': namaBarang,
        'jumlah': jumlah,
        'tujuan': tujuan,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('Barang keluar dengan ID $barangKeluarId berhasil ditambahkan.');
    } catch (e) {
      print('Error: $e');
    }
  }
}
