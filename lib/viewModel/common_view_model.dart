// ce fichier est pour la gestion des fonctionnalités communes de l'application entre diverses ecrans
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sellers_app/global/global_var.dart';

class CommonViewModel extends ChangeNotifier {
 
  // ici on va mettre les methodes communes
    getCurrentLocation() async
  {
    // ici je vais utiliser la methode de la classe geolocator pour recuperer la position de l'utilisateur
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    position = cPosition;
    // ici je vais afficher la position dans le text field
    // ici je vais utiliser la methode de la classe geocoding pour convertir les coordonne en adresse
    placeMark = await placemarkFromCoordinates(cPosition.latitude, cPosition.longitude);
    // ici j'indexe le premier element de la liste des adresses
    Placemark placeMarkVar = placeMark![0];
    // ici je vais recuperer les different element de l'adresse
    completeAddress = "${placeMarkVar.subThoroughfare} ${placeMarkVar.thoroughfare}, ${placeMarkVar.subLocality} ${placeMarkVar.locality}, ${placeMarkVar.subAdministrativeArea}, ${placeMarkVar.administrativeArea} ${placeMarkVar.postalCode}, ${placeMarkVar.country}";
    // ici je vais afficher l'adresse dans le text field
   return completeAddress;

  }
  // ici je vais creer une methode pour afficher un snackbar a chaque fois qu'il y a une erreur
  showSnackbar(String message, BuildContext context)
  {
    // ici je vais afficher un snackbar 
    final snackBar = SnackBar(
      content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ici je vais creer une methode pour afficher un progress dialog
  showProgressDialog(String message, BuildContext context)
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c)
      {
        return AlertDialog(
          content: SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),),
                SizedBox(height: 20,),
                Text(message, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),),
              ],
            ),
          ),
        );
      }
      );
  }
  hideProgressDialog(BuildContext context)
  {
    Navigator.pop(context); // pour fermer le dialog  
  }

// ici je vais creer une methode pour mettre a jour l'adresse dans la base de donnee
  updateLocationAtDatabase(String address) async
  {
    // ici je vais appeler la methode get current location pour recuperer la position actuelle mise a jour
   String address = await getCurrentLocation();

    // ici je vais mettre a jour l'adresse dans la base de donnee
   await FirebaseFirestore.instance
    .collection("sellers")
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .update({
      "address": address,
      "latitude": position!.latitude,
      "longitude": position!.longitude,
    });
  }
  }