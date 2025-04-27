import 'package:flutter/material.dart';
import 'package:project_kel_5/home.dart';
import 'package:project_kel_5/profile.dart';
import 'package:project_kel_5/signin.dart';
import 'package:project_kel_5/signup.dart';
import 'package:project_kel_5/landingMenu.dart';
import 'package:project_kel_5/ktp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
    return MaterialApp(
      title: 'Flutter E-commerce UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: FirebaseAuth.instance.currentUser != null ? '/home' : '/landingMenu',
      routes: {
        '/landingMenu': (context) => const LandingMenu(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/profile_barang': (context) => ProfileBarang(
            sellerId: FirebaseAuth.instance.currentUser?.uid ?? ''),
      },
    );
  }
}
