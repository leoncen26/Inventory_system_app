import 'package:flutter/material.dart';
import 'package:inventory_system/service/firestore.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final FirestoreService firestoreService = FirestoreService();

  final List<String> categories = [
    'Tables',
    'Chairs',
    'Beds',
    'Wardrobes',
    'Sofas'
  ];

  final _formKey = GlobalKey<FormState>();

  // Controllers untuk form input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final TextEditingController searchController = TextEditingController();

  String? _selectedCategory;
  String? _editingProductId; // Untuk mengedit produk

  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> filteredProductList = [];

  @override
  void initState() {
    super.initState();
    // Ambil daftar produk dari Firestore
    firestoreService.getProductsStream().listen((snapshot) {
      setState(() {
        productList = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'data': doc.data() as Map<String, dynamic>,
          };
        }).toList();
        filteredProductList = productList; // Default tampilkan semua produk
      });
    });

    // Listener untuk pencarian
    searchController.addListener(_filterProducts);
  }

  // Fungsi untuk memfilter produk berdasarkan nama
  void _filterProducts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredProductList = productList
          .where((product) =>
              product['data']['name'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  // Fungsi untuk membuka dialog Add/Edit Product
  void _openProductDialog(
      {Map<String, dynamic>? productData, String? productId}) {
    if (productData != null) {
      // Jika dalam mode edit, isi data ke dalam form
      _nameController.text = productData['name'];
      _descriptionController.text = productData['description'];
      _priceController.text = productData['price'].toString();
      _stockController.text = productData['stock'].toString();
      _imageUrlController.text = productData['imageUrl'];
      _selectedCategory = productData['category'];
      _editingProductId = productId;
    } else {
      // Reset form untuk mode tambah
      _formKey.currentState?.reset();
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _stockController.clear();
      _imageUrlController.clear();
      _selectedCategory = null;
      _editingProductId = null;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productData == null ? "Add Product" : "Edit Product",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 27, 52, 71),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: const Icon(Icons.shopping_bag),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || double.tryParse(value) == null
                                ? 'Valid price is required'
                                : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: 'Stock',
                          prefixIcon: const Icon(Icons.storage),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || int.tryParse(value) == null
                                ? 'Valid stock is required'
                                : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) =>
                            value == null ? 'Category is required' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'Image URL',
                          prefixIcon: const Icon(Icons.image),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Image URL is required'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_editingProductId == null) {
                            // Add product
                            await firestoreService.addProduct(
                              name: _nameController.text,
                              description: _descriptionController.text,
                              price: double.parse(_priceController.text),
                              stock: int.parse(_stockController.text),
                              category: _selectedCategory!,
                              imageUrl: _imageUrlController.text,
                            );
                          } else {
                            // Update product
                            await firestoreService.updateProduct(
                              productId: _editingProductId!,
                              name: _nameController.text,
                              description: _descriptionController.text,
                              price: double.parse(_priceController.text),
                              stock: int.parse(_stockController.text),
                              category: _selectedCategory!,
                              imageUrl: _imageUrlController.text,
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 44, 179, 190),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        _editingProductId == null ? "Add" : "Update",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menghapus produk dengan konfirmasi
  void _deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          // Tombol Cancel
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          // Tombol Delete
          TextButton(
            onPressed: () async {
              // Lakukan penghapusan jika user menekan Yes
              Navigator.pop(context); // Tutup dialog
              await firestoreService.deleteProduct(productId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Product deleted successfully"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              "Yes, Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 44, 179, 190),
                  Color.fromARGB(255, 27, 52, 71),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "Products",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 250,
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search by Product Name',
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    filled: true,
                    fillColor: Color.fromARGB(255, 44, 179, 190),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openProductDialog(),
          backgroundColor: const Color.fromARGB(255, 44, 179, 190),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 44, 179, 190),
                Color.fromARGB(255, 27, 52, 71),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: filteredProductList.isEmpty
              ? const Center(
                  child: Text(
                    "No Products Found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredProductList.length,
                  itemBuilder: (context, index) {
                    var product = filteredProductList[index];
                    var productData = product['data'];
                    String productId = product['id'];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
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
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Category: ${productData['category']}\nStock: ${productData['stock']} | Price: \Rp${productData['price']}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openProductDialog(
                                  productData: productData,
                                  productId: productId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(productId),
                            ),
                          ],
                        ),
                        onTap: () =>
                            _showUpdateStockBottomSheet(productId, productData),
                      ),
                    );
                  },
                ),
        ));
  }

  void _showUpdateStockBottomSheet(
      String productId, Map<String, dynamic> productData) {
    int updatedStock = productData['stock'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, bottomSheetSetState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    productData['imageUrl'],
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  productData['name'],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        bottomSheetSetState(() {
                          if (updatedStock > 0) updatedStock--;
                        });
                      },
                      icon: const Icon(Icons.remove_circle,
                          color: Colors.red, size: 30),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      updatedStock.toString(),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {
                        bottomSheetSetState(() {
                          updatedStock++;
                        });
                      },
                      icon: const Icon(Icons.add_circle,
                          color: Colors.green, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await firestoreService.updateProduct(
                      productId: productId,
                      name: productData['name'],
                      description: productData['description'],
                      price: productData['price'],
                      stock: updatedStock,
                      category: productData['category'],
                      imageUrl: productData['imageUrl'],
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                          content: Text("Stock updated successfully")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 44, 179, 190),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
