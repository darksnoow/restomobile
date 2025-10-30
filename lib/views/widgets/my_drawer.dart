import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_var.dart';
import 'package:sellers_app/views/mainScreens/home_screen.dart';
import 'package:sellers_app/views/splashScreen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.only(top: 25, bottom: 10),
            child: Column(
              children: [

                // image du vendeur
                Material(
              borderRadius: BorderRadius.circular(81),
              elevation: 8,
              child: SizedBox(
              height: 160,
              width: 160,
              child: CircleAvatar(
              backgroundImage: NetworkImage(sharedPreferences!.getString("imageUrl")!
              ),
            ),
          ),
          ),

                const SizedBox(height: 12,),
                // nom du vendeur
                Text(
                  sharedPreferences!.getString("name").toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

            const SizedBox(height: 12,),
           // body du drawer
          Container(
                  child: Column(
                    children: [
                      const Divider(
                        height: 10,
                        color: Colors.grey,
                        thickness: 2,
                      ),
                      ListTile(
                        leading: const Icon(Icons.home, color: Colors.white,),
                        title: const Text(
                          "Accueil",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: ()
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.monetization_on, color: Colors.white,),
                        title: const Text(
                          "Mes Gains",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: ()
                        {
                          // Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.reorder, color: Colors.white,),
                        title: const Text(
                          "New Orders",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: ()
                        {
                          // Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.history, color: Colors.white,),
                        title: const Text(
                          "Historique des commandes",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: (){

                        }
                      ),

                        ListTile(
                        leading: const Icon(Icons.local_shipping, color: Colors.white,),
                        title: const Text(
                          "New Orders",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: ()
                        {
                          // Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
                        },
                      ),

                        ListTile(
                        leading: const Icon(Icons.share_location, color: Colors.white,),
                        title: const Text(
                          "Update My Address",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: ()
                        {
                           commonViewModel.updateLocationAtDatabase("address");
                           commonViewModel.showSnackbar("Adresse mise a jour avec succes.", context);
                           //Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
                        },
                      ),
                        ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white,),
                        title: const Text(
                          "Se deconnecter",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () async
                        {
                          
                        },
                  ),
                  ],
                ),
                ),

        ],
      ),
    );
  }
}