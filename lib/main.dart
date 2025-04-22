import 'package:flutter/material.dart';
import 'package:project_kel_5/home.dart';

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
      home: const HomeScreen(),
    );
  }
}
