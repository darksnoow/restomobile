// ici je vais declarer les variables globales
  // ici je declare les variable pour la position
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Position? position;
  // ici je declare les variable pour les adresses pour la conversion des coordonnees en adresse
  List<Placemark>? placeMark;
  // ici je declare une variable pour stocker l'adresse complete
  String completeAddress = "";
  // ici je declare une variable pour stocker location les donnees de l'utilisateur
  SharedPreferences? sharedPreferences;
  // ici je declare une variable pour stocker l'id de l'utilisateur