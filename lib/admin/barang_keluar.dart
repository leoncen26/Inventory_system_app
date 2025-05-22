import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarangKeluarPage extends StatefulWidget {
  const BarangKeluarPage({Key? key}) : super(key: key);

  @override
  _BarangKeluarPageState createState() => _BarangKeluarPageState();
}

class _BarangKeluarPageState extends State<BarangKeluarPage> {
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk menambahkan barang keluar
  Future<void> addBarangKeluar(
      String namaBarang, int jumlah, String tujuan, DateTime tanggal) async {
    try {
      // 1. Cek apakah barang ada di koleksi "products"
      QuerySnapshot productQuery = await _firestore
          .collection('products')
          .where('name', isEqualTo: namaBarang)
          .get();

      if (productQuery.docs.isNotEmpty) {
        // Jika produk ditemukan, update stok
        DocumentSnapshot productDoc = productQuery.docs.first;
        int stokLama = productDoc['stock'] as int;
        int stokBaru = stokLama - jumlah;

        if (stokBaru >= 0) {
          await _firestore.collection('products').doc(productDoc.id).update({
            'stock': stokBaru,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // 2. Tambahkan transaksi ke koleksi "barang_keluar"
          await _firestore.collection('barang_keluar').add({
            'tanggal': Timestamp.now(),
            'nama_barang': namaBarang,
            'jumlah': jumlah,
            'tujuan': tujuan,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

          Navigator.pop(context); // Tutup pop-up
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Barang keluar berhasil ditambahkan. Stok diperbarui menjadi $stokBaru.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stok tidak mencukupi.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama barang tidak ditemukan.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan. Coba lagi nanti.')),
      );
    }
  }

  // Widget untuk menampilkan daftar barang keluar
  Widget _buildBarangKeluarList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('barang_keluar')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada data barang keluar.'));
        }

        final barangKeluarDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: barangKeluarDocs.length,
          itemBuilder: (context, index) {
            final data = barangKeluarDocs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.remove_shopping_cart),
                title: Text('Nama Barang: ${data['nama_barang']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jumlah: ${data['jumlah']}'),
                    Text('Tujuan: ${data['tujuan']}'),
                    // Text('Tanggal: ${(data['tanggal'] as Timestamp).toDate()}'),
                    Text(
                      'Tanggal: ${DateFormat('dd-MM-yyyy HH:mm:ss').format((data['tanggal'] as Timestamp).toDate())}',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddBarangKeluarDialog() {
    String? selectedProductId; // Menyimpan ID produk yang dipilih
    Map<String, dynamic>? selectedProduct; // Menyimpan data produk yang dipilih

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 44, 179, 190),
                      Color.fromARGB(255, 27, 52, 71),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'Tambah Barang Keluar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('products').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('Tidak ada produk tersedia.');
                        }

                        final productDocs = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Pilih Produk',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          value: selectedProductId,
                          hint: const Text('Pilih Produk'),
                          items: productDocs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(data['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedProductId = value;
                              selectedProduct = productDocs
                                  .firstWhere((doc) => doc.id == value)
                                  .data() as Map<String, dynamic>;
                            });
                          },
                        );
                      },
                    ),
                    if (selectedProduct != null) ...[
                      const SizedBox(height: 15),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  selectedProduct!['imageUrl'],
                                  height: 150, // Set a specific height
                                  width: 150, // Set a specific width
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Nama: ${selectedProduct!['name']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text('ID Produk: ${selectedProductId!}'),
                              Text('Stok: ${selectedProduct!['stock']}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Barang Keluar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                    ),
                    TextField(
                      controller: _tujuanController,
                      decoration: InputDecoration(
                        labelText: 'Tujuan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tanggal: ${_selectedDate.toLocal()}'.split(' ')[0],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: _pickDate,
                          child: const Text(
                            'Pilih Tanggal',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (selectedProductId != null &&
                        _jumlahController.text.isNotEmpty &&
                        int.tryParse(_jumlahController.text.trim()) != null &&
                        _tujuanController.text.trim().isNotEmpty) {
                      final jumlah =
                          int.tryParse(_jumlahController.text.trim()) ?? 0;
                      final tujuan = _tujuanController.text.trim();

                      if (jumlah > 0 && jumlah <= selectedProduct!['stock']) {
                        addBarangKeluar(
                          selectedProduct!['name'],
                          jumlah,
                          tujuan,
                          _selectedDate,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Jumlah tidak valid atau stok tidak mencukupi.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Mohon isi semua field dengan benar.')),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 44, 179, 190),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget untuk memilih tanggal
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Daftar Barang Keluar',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 27, 52, 71),
              Color.fromARGB(255, 44, 179, 190),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              const Center(
                child: Text(
                  'Daftar Barang Keluar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Daftar Barang Keluar
              _buildBarangKeluarList(),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _showAddBarangKeluarDialog,
                  icon: const Icon(Icons.remove_shopping_cart),
                  label: const Text('Tambah Barang Keluar'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
