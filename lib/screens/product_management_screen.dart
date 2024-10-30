import 'package:elecxa/screens/product_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageProductsScreen extends StatefulWidget {
  @override
  _ManageProductsScreenState createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _deleteProduct(String productId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('storeOwners')
          .doc(user.uid)
          .collection('products')
          .doc(productId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
        backgroundColor: Colors.blue,
      ),
      body: user == null
          ? Center(child: Text('User not logged in'))
          : StreamBuilder(
              stream: _firestore
                  .collection('storeOwners')
                  .doc(user.uid)
                  .collection('products')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('An error occurred'));
                }

                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No products added yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                        products[index].data() as Map<String, dynamic>;

                    // Use the first available image or a default icon
                    final imageUrl = product['imageUrl1'] ?? '';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: Icon(Icons.shopping_bag,
                                    color: Colors.blue.shade700),
                              ),
                        title: Text(
                          product['name'] ?? 'Unnamed Product',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '₹${product['price'] ?? ''}',
                          style: TextStyle(
                              fontSize: 16, color: Colors.blue.shade600),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(products[index].id),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ProductDetailsDialog(
                              product: {...product, 'id': products[index].id},
                              onSave: () {
                                setState(() {}); // Refresh the list
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ProductDetailsDialog(
              onSave: () {
                setState(() {}); // Refresh the list
              },
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
