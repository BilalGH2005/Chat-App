import 'dart:io';

import 'package:chat_practice/firebase_options.dart';
import 'package:chat_practice/screens/auth.dart';
import 'package:chat_practice/screens/chat.dart';
import 'package:chat_practice/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      // systemNavigationBarColor: Colors.blue, // navigation bar color
      statusBarColor: Color(0xFF1D1B1F), // status bar color
    ),
  );
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  ChatApp({super.key});

  var _hasSignedup = false;
  String _username = '';
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1A1428)),
        scaffoldBackgroundColor: Color(0xFF1D1B1F),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (!snapshot.hasData) {
            return AuthScreen(
              onSignUp: (signedUp, username, selectedImage) {
                _hasSignedup = signedUp;
                _username = username;
                _selectedImage = selectedImage;
              },
            );
          }
          if (_selectedImage == null) {
            return ChatScreen();
          }
          return ChatScreen.withSignUp(
            hasSignedUp: _hasSignedup,
            username: _username,
            selectedImage: _selectedImage!,
            resetHasSignedUp: () => _hasSignedup = false,
          );
        },
      ),
    );
  }
}
