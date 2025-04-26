import 'package:flutter/material.dart';
import 'package:project_kel_5/home.dart';
import 'package:project_kel_5/profile.dart';
import 'package:project_kel_5/signin.dart';
import 'package:project_kel_5/signup.dart';
import 'package:project_kel_5/landingMenu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_kel_5/firebase_test.dart';
import 'firebase_options.dart';
import 'package:project_kel_5/chat_list_page.dart';
import 'profile_barang.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return MaterialApp(
      title: 'Flutter E-commerce UI',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Or your preferred theme color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins', // Example: Use a custom font if desired
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/firebase_test': (context) => const FirebaseTestPage(),
        '/profile_barang': (context) => ProfileBarang(),
      },
    );
  }
}
