import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String storeId;
  final String storeName;
  final String customerName;

  ChatScreen({
    required this.chatId,
    required this.storeId,
    required this.storeName,
    required this.customerName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String message = _messageController.text.trim();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Sending the message
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'message': message,
      'senderId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Updating the last message in chat list
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .set({
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
      'storeId': widget.storeId,
      'storeName': widget.storeName,
      'customerName': widget.customerName,
    }, SetOptions(merge: true));

    _messageController.clear();
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] ==
                        FirebaseAuth.instance.currentUser!.uid;

                    DateTime timestamp =
                        (message['timestamp'] as Timestamp?)?.toDate() ??
                            DateTime.now();
                    String timeDisplay = DateFormat('h:mm a').format(timestamp);

                    // Determines if we need a day divider
                    String dateLabel = _getDateLabel(
                      timestamp,
                      index == messages.length - 1
                          ? null
                          : (messages[index + 1]['timestamp'] as Timestamp?)
                              ?.toDate(),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (dateLabel.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(
                              child: Text(
                                dateLabel,
                                style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color:
                                        isMe ? Colors.blue : Colors.grey[300],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomLeft:
                                          Radius.circular(isMe ? 16 : 0),
                                      bottomRight:
                                          Radius.circular(isMe ? 0 : 16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        message['message'],
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      if (isMe)
                                        Icon(
                                          Icons.done_all,
                                          size: 16,
                                          color: Colors.white70,
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    timeDisplay,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Enter your message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime current, DateTime? previous) {
    final now = DateTime.now();
    if (previous != null &&
        previous.year == current.year &&
        previous.month == current.month &&
        previous.day == current.day) {
      return '';
    }
    final differenceInDays = now.difference(current).inDays;

    if (differenceInDays == 0 && current.day == now.day) {
      return 'Today';
    } else if (differenceInDays == 1) {
      return 'Yesterday';
    } else if (differenceInDays < 7) {
      return DateFormat.EEEE().format(current);
    } else {
      return DateFormat.yMMMd().format(current);
    }
  }
}
