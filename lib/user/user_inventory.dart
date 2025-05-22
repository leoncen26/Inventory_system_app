import 'package:flutter/material.dart';
import 'package:inventory_system/service/firestore.dart';

class UserInventoryPage extends StatefulWidget {
  const UserInventoryPage({super.key});

  @override
  State<UserInventoryPage> createState() => _UserInventoryPageState();
}

class _UserInventoryPageState extends State<UserInventoryPage> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> filteredProductList = [];

  @override
  void initState() {
    super.initState();

    // Listen to product updates from Firestore
    firestoreService.getProductsStream().listen((snapshot) {
      setState(() {
        productList = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'data': doc.data() as Map<String, dynamic>,
          };
        }).toList();
        filteredProductList = productList; // Default display all products
      });
    });

    // Add listener for search functionality
    searchController.addListener(_filterProducts);
  }

  // Function to filter products by name
  void _filterProducts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredProductList = productList
          .where((product) =>
              product['data']['name'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  void _showProductDetails(String productId) async {
    try {
      // Ambil detail produk dari Firestore
      Map<String, dynamic> productData =
          await firestoreService.getProduct(productId);

      // Tampilkan bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gambar produk full
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9, // Proporsi gambar (16:9)
                    child: Image.network(
                      productData['imageUrl'],
                      width: double.infinity,
                      fit: BoxFit.cover, // Gambar memenuhi area tanpa terpotong
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nama produk
                Center(
                  child: Text(
                    productData['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),

                // Kategori produk
                Center(
                  child: Text(
                    "Category: ${productData['category']}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Divider(height: 32, thickness: 1),

                // Deskripsi produk
                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  productData['description'],
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),

                // Harga produk
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Price",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Rp${productData['price']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stok produk
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Stock",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${productData['stock']} pcs",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tombol "Close"
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 44, 179, 190),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Tutup bottom sheet
                    },
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      // Tampilkan pesan error jika detail produk gagal dimuat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading product details: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                "User Inventory",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search by Product Name',
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredProductList.isEmpty
                  ? const Center(
                      child: Text(
                        "No Products Found",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredProductList.length,
                      itemBuilder: (context, index) {
                        var product = filteredProductList[index];
                        var productData = product['data'];
                        String productId = product['id'];

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.all(10),
                          color: const Color.fromARGB(255, 44, 179, 190),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                productData['imageUrl'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              productData['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              "Category: ${productData['category']} | Stock: ${productData['stock']}\nPrice: Rp${productData['price']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () => _showProductDetails(
                                productId), // Show details on tap
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
