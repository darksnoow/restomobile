import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sellers_app/global/global_var.dart';
import 'package:sellers_app/views/splashScreen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

  // Assurez-vous que les liaisons Flutter sont initialisées
Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisez Firebase
    await Firebase.initializeApp();
  // initialiser SharedPreferences
   sharedPreferences = await SharedPreferences.getInstance();
  // assignez l'instance de SharedPreferences a la variable globale


  // ici on demande la permission de la localisation au demarrage de l'application
  await Permission.locationWhenInUse.isDenied.then( (valueOfPermission){
    if(valueOfPermission)
    {
      Permission.locationWhenInUse.request();
    }
  } );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellers App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.lightBlue,
      ),
      debugShowCheckedModeBanner: false,
      home: MySplashScreen(),
    );
  }
}
