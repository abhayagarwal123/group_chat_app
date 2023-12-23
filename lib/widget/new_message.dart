import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final messagecontroller = TextEditingController();
  @override
  void dispose() {
    messagecontroller.dispose();
    super.dispose();
  }

  void submitmessage() async {
    final enteredmessage = messagecontroller.text;
    if (enteredmessage.trim().isEmpty) {
      return;
    }
    setState(() {
      messagecontroller.clear();
      FocusScope.of(context).unfocus();
    });
    final user = FirebaseAuth.instance.currentUser!;
    //retrieving of data from firestore to userdata
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get(); //sending request to database

    //adding to firestore from userdata
    await FirebaseFirestore.instance.collection('chat').add({
      'message': enteredmessage,
      'time': Timestamp.now(),
      'userId': user.uid,
      'username':
          userdata.data()!['username'],    //userdata.data()!['required data']
      'userimage': userdata.data()!['image_url']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(children: [
        Expanded(
          child: TextField( textAlign: TextAlign.justify,
            controller: messagecontroller,
            decoration: const InputDecoration(
                labelText: 'New Message',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(50),
                        left: Radius.circular(50)))),
          ),
        ),
        IconButton(
          onPressed: () {
            submitmessage();
          },
          icon: const Icon(Icons.send_outlined),
          iconSize: 35,
        ),
      ]),
    );
  }
}
