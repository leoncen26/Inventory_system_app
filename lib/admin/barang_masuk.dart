import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarangMasukPage extends StatefulWidget {
  const BarangMasukPage({Key? key}) : super(key: key);

  @override
  _BarangMasukPageState createState() => _BarangMasukPageState();
}

class _BarangMasukPageState extends State<BarangMasukPage> {
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addBarangMasuk(
      String namaBarang, int jumlah, String supplier, DateTime tanggal) async {
    try {
      QuerySnapshot productQuery = await _firestore
          .collection('products')
          .where('name', isEqualTo: namaBarang)
          .get();

      if (productQuery.docs.isNotEmpty) {
        DocumentSnapshot productDoc = productQuery.docs.first;
        int stokLama = productDoc['stock'] as int;
        int stokBaru = stokLama + jumlah;

        await _firestore.collection('products').doc(productDoc.id).update({
          'stock': stokBaru,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('barang_masuk').add({
          'tanggal': Timestamp.fromDate(tanggal),
          'nama_barang': namaBarang,
          'jumlah': jumlah,
          'supplier': supplier,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Barang masuk berhasil ditambahkan. Stok diperbarui menjadi $stokBaru.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Nama barang tidak ditemukan. Tambahkan produk dulu.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan. Coba lagi nanti.')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildBarangMasukList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('barang_masuk')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada data barang masuk.'));
        }

        final barangMasukDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: barangMasukDocs.length,
          itemBuilder: (context, index) {
            final data = barangMasukDocs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.white.withOpacity(0.9),
              shadowColor: Colors.blueAccent,
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.inventory, color: Colors.blueAccent),
                title: Text('Nama Barang: ${data['nama_barang']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jumlah: ${data['jumlah']}',
                        style: const TextStyle(color: Colors.black87)),
                    Text('Supplier: ${data['supplier']}',
                        style: const TextStyle(color: Colors.black87)),
                    Text(
                      'Tanggal: ${DateFormat('dd-MM-yyyy HH:mm:ss').format((data['tanggal'] as Timestamp).toDate())}',
                      style: const TextStyle(color: Colors.black54),
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

  void _showAddBarangMasukDialog() {
    String? selectedProductId;
    Map<String, dynamic>? selectedProduct;

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
                    'Tambah Barang Masuk',
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
                    const SizedBox(height: 15),
                    TextField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Barang Masuk',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _supplierController,
                      decoration: InputDecoration(
                        labelText: 'Supplier',
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
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (selectedProductId != null &&
                        _jumlahController.text.isNotEmpty &&
                        int.tryParse(_jumlahController.text.trim()) != null &&
                        _supplierController.text.trim().isNotEmpty) {
                      final jumlah =
                          int.tryParse(_jumlahController.text.trim()) ?? 0;
                      final supplier = _supplierController.text.trim();
                      addBarangMasuk(
                        selectedProduct!['name'],
                        jumlah,
                        supplier,
                        _selectedDate,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mohon isi semua field dengan benar.'),
                        ),
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
          _selectedDate.second,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Daftar Barang Masuk',
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
        decoration: const BoxDecoration(
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
            children: [
              const Text(
                'Daftar Barang Masuk',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              _buildBarangMasukList(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _showAddBarangMasukDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Barang Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
