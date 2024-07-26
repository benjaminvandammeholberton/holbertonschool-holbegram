import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  MessagesScreenState createState() => MessagesScreenState();
}


class MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          
          final messages = snapshot.data!.docs;

          
          if (messages.isEmpty) {
            return const Center(
              child: Text(
                'No messages available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              return MessageTile(message: message);
            },
          );
        },
      ),
    );
  }
}


class MessageTile extends StatelessWidget {
  final QueryDocumentSnapshot message;
  const MessageTile({super.key, required this.message});

  void deleteMessage(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('messages')
        .doc(message.id)
        .delete();

    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message deleted')),
    );
  }

  
  void replyToMessage(BuildContext context, String senderId) async {
    TextEditingController replyController = TextEditingController();

    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Message'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: 'Enter your reply'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(senderId)
                    .collection('messages')
                    .add({
                  'senderId': currentUser.uid,
                  'content': replyController.text,
                  'timestamp': Timestamp.now(),
                  'read': false,
                });

                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reply sent successfully')),
                );

                
                Navigator.of(context).pop();
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(message['senderId'])
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            title: Text('Anonymous'),
            subtitle: Text('Loading...'),
          );
        }

        
        var sender = snapshot.data!.data() as Map<String, dynamic>;
        var senderName = sender['username'];
        var senderPhotoUrl = sender['photoUrl'];

        if (message['read'] == false) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('messages')
              .doc(message.id)
              .update({'read': true});
        }

        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 45.0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(senderPhotoUrl),
              ),
              title: Text(senderName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(message['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.reply, color: Colors.blue),
                    onPressed: () =>
                        replyToMessage(context, message['senderId']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteMessage(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
