import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerRequestsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Requests'),
        backgroundColor: Colors.blue,
      ),
      body: user == null
          ? Center(
              child: Text(
                'User not logged in',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('customers')
                  .doc(user.uid)
                  .collection('requests')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading requests',
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 18),
                    ),
                  );
                }

                final requests = snapshot.data!.docs;

                if (requests.isEmpty) {
                  return Center(
                    child: Text(
                      'No requests found',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request =
                        requests[index].data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.blue.shade50,
                      shadowColor: Colors.blue.shade100,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        title: Text(
                          request['productName'] ?? 'Unnamed Product',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6),
                            Text(
                              'Urgency: ${request['urgency']}',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade700),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Status: ${request['status']}',
                              style: TextStyle(
                                fontSize: 15,
                                color: request['status'] == 'Pending'
                                    ? Colors.orange
                                    : request['status'] == 'Accepted'
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
