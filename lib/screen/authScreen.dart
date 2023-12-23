import 'dart:io';
import 'package:chat_app/widget/imagepicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebase = FirebaseAuth.instance;
final storage = FirebaseStorage.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  File? selectedimage;
  var islogin = true;
  var isauthenticating = false;
  final formkey = GlobalKey<FormState>();
  String enteredEmail = '';
  String username = '';
  String enteredPassword = '';
  void submit() async {
    bool isvalid = formkey.currentState!.validate();
    if (!isvalid || !islogin && selectedimage == null) {
      return;
    }

    formkey.currentState!.save();
    try {
      setState(() {
        isauthenticating = true;
      });
      if (islogin) {
        final UserCredential = await firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
      } else {
        final UserCredential = await firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
//storing image in storage
        final storageref = storage
            .ref()
            .child('user_images')
            .child('${UserCredential.user!.uid}.jpeg');
        await storageref.putFile(selectedimage!);
        final imageurl = await storageref.getDownloadURL();


//storing data in firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(UserCredential.user!.uid)
            .set({
          'username': username,
          'email': enteredEmail,
          'image_url': imageurl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
      setState(() {
        isauthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  margin:
                      EdgeInsets.only(top: 10, right: 15, left: 15, bottom: 10),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!islogin)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Getimage(
                                onpickimage: (pickedimage) {
                                  setState(() {
                                    selectedimage = pickedimage;
                                  });
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              onSaved: (value) {
                                enteredEmail = value!;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter valid email address';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              decoration: const InputDecoration(
                                labelText: 'Enter E-mail',
                                icon: Icon(Icons.email),
                              ),
                            ),
                          ),
                          if(!islogin)
                          TextFormField(
                            onSaved: (value) {
                              username = value!;
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty||value.trim().length<4) {
                                return 'enter valid username';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Enter username',
                              icon: Icon(Icons.account_circle),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              onSaved: (value) {
                                enteredPassword = value!;
                              },
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be 6 character long';
                                }
                                return null;
                              },
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: const InputDecoration(
                                labelText: 'Enter Password',
                                icon: Icon(Icons.password),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          isauthenticating
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor),
                                  onPressed: () {
                                    submit();
                                  },
                                  child: Text(
                                    islogin ? 'Login' : 'Sign Up',
                                    style: TextStyle(color: Colors.white),
                                  )),
                          isauthenticating
                              ? CircularProgressIndicator()
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      islogin = !(islogin);
                                    });
                                  },
                                  child: Text(islogin
                                      ? 'Create an account'
                                      : 'I already have an account')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
