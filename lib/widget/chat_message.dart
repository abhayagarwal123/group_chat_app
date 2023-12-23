import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticateduser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('time', descending: true) //latest message at bottom
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Messages Found...'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something Went wrong...'),
          );
        }
        final loadedmessage = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 40),
          reverse: true,
          itemBuilder: (context, index) {
            final chatmessage = loadedmessage[index].data();
            final nextchatmessage = index + 1 < loadedmessage.length
                ? loadedmessage[index + 1].data()
                : null;

            final currentmessageuserid = chatmessage['userId'];
            final nextmessageuserid =
                nextchatmessage != null ? nextchatmessage['userId'] : null;

            final nextuserissame =
                nextmessageuserid == currentmessageuserid ? true : false;
            if (nextuserissame) {
              return MessageBubble.next(
                  message: chatmessage['message'],
                  isMe: authenticateduser.uid == currentmessageuserid
                      ? true
                      : false);
            }
            return MessageBubble.first(userImage: chatmessage['userimage'], username: chatmessage['username'],message: chatmessage['message'],
                isMe: authenticateduser.uid == currentmessageuserid
                    ? true
                    : false);
          },
          itemCount: loadedmessage.length,
        );
      },
    );
  }
}
