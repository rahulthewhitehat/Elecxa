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
              child: Text('No chats available.'),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];
              var lastMessage = chat['lastMessage'] ?? 'No messages yet';
              var timestamp = chat['timestamp'] != null
                  ? (chat['timestamp'] as Timestamp).toDate()
                  : null;

              String otherParticipantName = '';

              // Determine if the current user is the customer or the store owner
              if (chat['storeId'] == userId) {
                // Store owner is logged in, display the customer's name
                otherParticipantName =
                    chat['customerName'] ?? 'Unknown Customer';
              } else {
                // Customer is logged in, display the store's name
                otherParticipantName = chat['storeName'] ?? 'Unknown Store';
              }

              return ListTile(
                title: Text('Chat with $otherParticipantName'),
                subtitle: Text(lastMessage),
                trailing: timestamp != null
                    ? Text(
                        '${timestamp.hour}:${timestamp.minute}',
                        style: TextStyle(color: Colors.grey),
                      )
                    : null,
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
              );
            },
          );
        },
      ),
    );
  }
}
