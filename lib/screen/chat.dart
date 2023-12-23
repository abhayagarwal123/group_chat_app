import 'package:chat_app/widget/chat_message.dart';
import 'package:chat_app/widget/new_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'authScreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setpushnotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
  }

  @override
  void initState() {
    super.initState();

    setpushnotification(); //push notification return future but we cant async initstate so create new function
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 130, 109, 180),
        title: Text('ChatterBox'),
        actions: [
          IconButton(
              onPressed: () {
                firebase.signOut();
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: Column(children: [
        Expanded(child: ChatMessage(), flex: 7),
        Expanded(
          child: NewMessage(),
          flex: 1,
        )
      ]),
    );
  }
}
