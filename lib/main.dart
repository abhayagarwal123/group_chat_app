import 'package:chat_app/screen/authScreen.dart';
import 'package:chat_app/screen/chat.dart';
import 'package:chat_app/screen/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FlutterChat',
        theme: ThemeData().copyWith(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 63, 17, 177)),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.connectionState==ConnectionState.waiting){
              return SplashScreen();
            }
            if(snapshot.hasData){
              return ChatScreen();
            }
            return AuthScreen();
          },
        ));
  }
}
