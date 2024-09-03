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

      // Show success message for deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully!')),
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
                  return Center(child: Text('No products added yet'));
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                        products[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(product['name'] ?? ''),
                      subtitle: Text(
                          '₹${product['price'] ?? ''}'), // Updated to use the Indian rupee symbol
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteProduct(products[index].id),
                      ),
                      onTap: () {
                        // Open ProductDetailsDialog for editing
                        showDialog(
                          context: context,
                          builder: (context) => ProductDetailsDialog(
                            product: {
                              ...product,
                              'id': products[index].id,
                            },
                            onSave: () {
                              setState(() {}); // Refresh the list
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open ProductDetailsDialog for adding a new product
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
