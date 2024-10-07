import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatId; // Unique ID for the chat session.
  final String storeId; // Store ID of the store being chatted with.
  final String storeName; // Name of the store.
  final String customerName; // Name of the customer.

  ChatScreen({
    required this.chatId,
    required this.storeId,
    required this.storeName,
    required this.customerName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  // Function to send a message.
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return; // Don't send an empty message
    }

    String message = _messageController.text.trim();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the current chat document to get the existing customer name if available
    DocumentSnapshot chatDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    // If the chat does not exist or the customerName is null, fetch the customer name
    String? customerName = chatDoc['customerName'];
    if (customerName == null && userId != widget.storeId) {
      // Fetch customer name if the sender is a customer
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();
      customerName = userDoc['name'] ?? 'Unknown Customer';
    }

    // Send message to Firestore
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'message': message,
      'senderId': userId,
      'timestamp': FieldValue.serverTimestamp(), // Server timestamp
    });

    // Update the chat metadata in the main `chats` collection without modifying participants
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .set({
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
      'storeId': widget.storeId,
      'storeName': widget.storeName,
      'customerName': customerName, // Keep the customer name consistent
    }, SetOptions(merge: true));

    _messageController.clear(); // Clear the input field after sending
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle =
        FirebaseAuth.instance.currentUser!.uid == widget.storeId
            ? 'Chat with ${widget.customerName}'
            : 'Chat with ${widget.storeName}';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Display chat messages.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Show the latest message at the bottom.
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] ==
                        FirebaseAuth.instance.currentUser!.uid;

                    // Handle missing timestamp gracefully.
                    var timestamp = message['timestamp'] != null
                        ? (message['timestamp'] as Timestamp).toDate()
                        : DateTime
                            .now(); // Use the current time if the timestamp is missing.

                    return ListTile(
                      title: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          '${timestamp.hour}:${timestamp.minute}', // Show the message timestamp.
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input area for messages.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage, // Send the message.
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
