import 'package:flutter/material.dart';
import 'package:sellers_app/authScreens/signin_screen.dart';
import 'package:sellers_app/authScreens/signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController
    (
      length: 2,
      child: Scaffold(
        // ici dans le appbar se trouve les boutton 
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                "Astro Seller",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white
                ),
              ),
              centerTitle: true,
              bottom:  const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.lock ,color: Colors.white,),
                    text: "Login",

                  ),
                  Tab(
                    icon: Icon(Icons.person ,color: Colors.white,),
                    text: "Signup",

                  )
                ],
                // ceci represente l'indicateur sous les icons lock-person
                indicatorColor: Colors.white38,
                indicatorWeight: 5,
                ),
            ),
        // dans le body le code de redirection vers les pages signin-signup
            body: Container(
              color: Colors.black87,
              // vue que tout est dans le tabar on recupere dans le tabar view
              child: const TabBarView(
                children:[
                  //this code link signin tab button
                    SigninScreen(),
                     //this code link signup tab button
                    SignupScreen(),

                ]


              ),

            ),
      )
      
      );
  }
}