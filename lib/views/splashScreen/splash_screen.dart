

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/views/authScreens/auth_screen.dart';
import 'package:sellers_app/views/mainScreens/home_screen.dart';
import 'package:sellers_app/global/global_instances.dart';



class MySplashScreen extends StatefulWidget {
  const MySplashScreen ({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreen();
}

class _MySplashScreen extends State<MySplashScreen> {
  Future<void> _start() async {
    // Optionnel: petit délai pour l'animation
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (user == null) {
      // Pas connecté -> aller vers Auth
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      return;
    }

     if(FirebaseAuth.instance.currentUser == null){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                  "images/sellers.webp"
              ),
            ),

           const Text(
              "Sellers App",
               textAlign: TextAlign.center,
               style: TextStyle(
                  letterSpacing: 3,
                  fontSize: 26,
                  color: Colors.black38,
    ),

            ),
          ],
        ),
      ),



    );
  }
}
