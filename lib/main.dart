import 'package:flutter/material.dart';
import 'package:sellers_app/splashScreen/splash_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellers App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MySplashScreen(),
    );
  }
}
