import 'package:flutter/material.dart';
import 'package:project_kel_5/home.dart';
import 'package:project_kel_5/profile.dart';
import 'package:project_kel_5/signin.dart';
import 'package:project_kel_5/signup.dart';
import 'package:project_kel_5/landingMenu.dart';
import 'package:project_kel_5/chat_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter E-commerce UI',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Or your preferred theme color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins', // Example: Use a custom font if desired
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/landingMenu',
      routes: {
        '/landingMenu': (context) => const LandingMenu(),
        '/chatscreen': (context) => const ChatListPage(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
