

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sellers_app/authScreens/auth_screen.dart';



class MySplashScreen extends StatefulWidget {
  const MySplashScreen ({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreen();
}

class _MySplashScreen extends State<MySplashScreen>
{

  //? creation de la methode d'initialisation du compteur
  iniTimer()
  {
    Timer(const Duration(seconds: 3), () async
    {
      Navigator.push(context, MaterialPageRoute(builder: (c) => AuthScreen()));

    });
  }
  
  //! ici appel de la methode d'initialisation du compteur
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // appel de la methode des 3secondes
    iniTimer();
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
                  color: Colors.grey,
    ),

            ),
          ],
        ),
      ),



    );
  }
}
