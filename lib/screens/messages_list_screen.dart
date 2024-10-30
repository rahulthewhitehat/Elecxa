import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesListScreen extends StatelessWidget {
  final String userId;

  MessagesListScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return Center(
              child: Text(
                'No chats available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              var chat = chats[index];
              var lastMessage = chat['lastMessage'] ?? 'No messages yet';
              var timestamp = chat['timestamp'] != null
                  ? (chat['timestamp'] as Timestamp).toDate()
                  : null;

              String otherParticipantName = chat['storeId'] == userId
                  ? chat['customerName'] ?? 'Unknown Customer'
                  : chat['storeName'] ?? 'Unknown Store';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chat.id,
                        storeId: chat['storeId'],
                        storeName: chat['storeName'],
                        customerName: chat['customerName'],
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade600,
                      child: Icon(Icons.chat, color: Colors.white),
                    ),
                    title: Text(
                      otherParticipantName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    trailing: timestamp != null
                        ? Text(
                            '${timestamp.hour}:${timestamp.minute}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          )
                        : null,
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
