import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to update the request status for both the store owner's notifications and customer's requests collections
  Future<void> _updateRequestStatus(
      String requestId, String status, String customerId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Update the store owner's notifications collection
        await _firestore
            .collection('storeOwners')
            .doc(user.uid)
            .collection('notifications')
            .doc(requestId)
            .update({'status': status});

        // Update the customer's requests collection
        await _firestore
            .collection('customers')
            .doc(customerId)
            .collection('requests')
            .doc(requestId)
            .update({'status': status});

        // Show a success message in the app
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $status')),
        );
      } catch (e) {
        // Log the error in case of failure
        print('Error updating request status in both collections: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update request status.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Requests'),
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
                  .collection('storeOwners')
                  .doc(user.uid)
                  .collection('notifications')
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
                      'No new requests',
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
                    final requestId = requests[index].id;
                    final customerId = request['customerId'];

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
                              'Requested by: ${request['customerName']}',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade700),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Urgency: ${request['urgency']}',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Status: ${request['status'] ?? 'Pending'}',
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
                        trailing: request['status'] == 'Pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check),
                                    color: Colors.green,
                                    tooltip: 'Accept',
                                    onPressed: () => _updateRequestStatus(
                                        requestId, 'Accepted', customerId),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    color: Colors.red,
                                    tooltip: 'Reject',
                                    onPressed: () => _updateRequestStatus(
                                        requestId, 'Rejected', customerId),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
