 
// ce fichier est pour la gestion de l'authentification appeler aussi la busss logic
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:sellers_app/global/global_var.dart';
import 'package:sellers_app/views/mainScreens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel
{
  // Renamed to avoid duplicate definition
  void showPrivacyDialogV2(BuildContext context, VoidCallback onAccept) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text("Conditions de Confidentialité", style: TextStyle(color: Colors.yellow)),
        content: SingleChildScrollView(
          child: Text(
            """En vous inscrivant, vous acceptez de fournir vos informations personnelles. 
  Ces données sont utilisées pour vérifier votre identité et faciliter les échanges avec les clients et les livreurs.
  Nous protégeons vos données et ne les partageons pas sans votre consentement.""",
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          TextButton(
            child: Text("Refuser", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Accepter", style: TextStyle(color: Colors.green)),
            onPressed: () {
              onAccept();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
// ici on va mettre les methodes de connexion et d'inscription
// premiere etape: creer un compte validation formulaire qui recoit les donnees du formulaire
validateSignUpForm(
  XFile? imageXFile,
  String name,
  String phone,
  String email,
  String password,
  String confirmPassword,
  String locationAddress,
  bool termsAccepted,
  BuildContext context,
) async {
  // Trim des champs
  final trimmedname = name.trim();
  final trimmedphone = phone.trim();
  final trimmedemail = email.trim();
  final trimmedpassword = password.trim();
  final trimmedconfirm = confirmPassword.trim();
  final trimmedlocation = locationAddress.trim();

  // Vérifier l'acceptation des conditions
  if (!termsAccepted) {
    commonViewModel.showSnackbar("Veuillez accepter les conditions de confidentialité", context);
    return;
  }

  // Vérifier les champs obligatoires
  // Vérifier les champs obligatoires et lister ceux manquants pour faciliter le debug
  final List<String> missingFields = [];
  if (trimmedname.isEmpty) missingFields.add('Nom');
  if (trimmedphone.isEmpty) missingFields.add('Téléphone');
  if (trimmedemail.isEmpty) missingFields.add('Email');
  if (trimmedpassword.isEmpty) missingFields.add('Mot de passe');
  if (trimmedconfirm.isEmpty) missingFields.add('Confirmation du mot de passe');
  if (trimmedlocation.isEmpty) missingFields.add('Adresse');

  if (missingFields.isNotEmpty) {
    final msg = 'Champs manquants : ${missingFields.join(', ')}';
    commonViewModel.showSnackbar(msg, context);
    return;
  }

  // Vérification simple du format email
  final atIndex = trimmedemail.indexOf('@');
  final dotIndex = trimmedemail.lastIndexOf('.');
  if (atIndex <= 0 || dotIndex <= atIndex + 1 || dotIndex == trimmedemail.length - 1 || trimmedemail.contains(' ')) {
    commonViewModel.showSnackbar("Veuillez entrer une adresse email valide", context);
    return;
  }

  // Vérifier correspondance des mots de passe
  if (trimmedpassword != trimmedconfirm) {
    commonViewModel.showSnackbar("Les mots de passe ne correspondent pas", context);
    return;
  }

  // Vérifier longueur minimale du mot de passe
  if (trimmedpassword.length < 6) {
    commonViewModel.showSnackbar("Le mot de passe doit contenir au moins 6 caractères", context);
    return;
  }

  // Montrer progress
  commonViewModel.showProgressDialog("Création du compte en cours...", context);

  try {
    // Création utilisateur
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: trimmedemail, password: trimmedpassword);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Erreur lors de l'inscription";
      if (e.code == 'email-already-in-use') {
        errorMessage = "Cet email est déjà utilisé";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Email invalide";
      } else if (e.code == 'weak-password') {
        errorMessage = "Mot de passe trop faible";
      }
      commonViewModel.hideProgressDialog(context);
      commonViewModel.showSnackbar(errorMessage, context);
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      commonViewModel.hideProgressDialog(context);
      commonViewModel.showSnackbar("Impossible de créer l'utilisateur", context);
      return;
    }
    final uid = currentUser.uid;

    // Upload photo only if provided by the caller (AddPhotoProfilePage or signup screen)
    String? imageUrl;
    if (imageXFile != null) {
      try {
        imageUrl = await uploadImageToStorage(imageXFile);
      } catch (e, st) {
        commonViewModel.hideProgressDialog(context);
        debugPrint('Error uploading image: $e');
        debugPrint('$st');
        commonViewModel.showSnackbar("Erreur lors de l'upload de l'image", context);
        return;
      }
    } else {
      imageUrl = null;
    }

    // Enregistrement dans Firestore (collection 'sellers')
    try {
      await FirebaseFirestore.instance.collection('sellers').doc(uid).set({
        'uid': uid,
        'name': name,
        // Store both keys for backward compatibility
        'telephone': phone,
        'phone': phone,
        'email': email,
        // Prefer imageUrl; some older code might read 'image'
        'imageUrl': imageUrl,
        'image': imageUrl,
        'role': 'client',
        'type': 'client',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        "status": "approved",
        "earnings": 0.0,
        "ratings": 0.0,
        "shopOpen": true,
        // Save both lat/latitude keys for compatibility
        "lat": position!.latitude,
        "latitude": position!.latitude,
        "lng": position!.longitude,
        // Save both address/completAddress keys for compatibility
        "address": trimmedlocation,
        "completAddress": trimmedlocation,
      });
    } catch (e, st) {
      commonViewModel.hideProgressDialog(context);
      debugPrint('Error writing user to Firestore: $e');
      debugPrint('$st');
      commonViewModel.showSnackbar("Erreur lors de l'enregistrement des données utilisateur", context);
      return;
    }

  commonViewModel.hideProgressDialog(context);
  // Afficher le message de succès avant la navigation
  commonViewModel.showSnackbar("Votre compte a été créé avec succès", context);
  // Navigation
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
  } catch (e) {
    commonViewModel.hideProgressDialog(context);
    commonViewModel.showSnackbar("Une erreur s'est produite. Veuillez réessayer", context);
  }
}
          // ici ce trouve les methodes implementer que j'appelle la haut(les methode recoivent les parametres definis toujours)
  // ici je vais creer une methode pour creer un utilisateur dans firebase auth
  creatUserInFirebaseAuth(String email, String password,BuildContext context) async
  {
    User? currentFirebaseUser;
     // ici je vais utiliser la methode de firebase auth pour creer un utilisateur
    // je vais utiliser le package firebase_auth
    await FirebaseAuth.instance
     .createUserWithEmailAndPassword(
       email: "",
       password: "").then((valueAuth){
       currentFirebaseUser = valueAuth.user;
       }).catchError((errorMsg){
        // ici je vais afficher un snackbar pour dire qu'il y a une erreur
        commonViewModel.showSnackbar(errorMsg, context);
       });
       // ici je vais ajouter une methode pour envoyer un email de verification aussi verifier si l'utilisateur est null
       if(currentFirebaseUser == null)
       {
        FirebaseAuth.instance.signOut();
        return;
         //
       }
       return currentFirebaseUser;
  }
  
    // ici je vais creer une methode pour stocker l'image dans firebase storage et recuperer le lien de l'image
    Future<String> uploadImageToStorage(XFile imageXFile) async {
      // ici je vais utiliser le package firebase_storage
      // je vais creer un identifiant unique pour chaque image
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File(imageXFile.path);
      debugPrint('uploadImageToStorage: image path = ${imageXFile.path}');
      if (!file.existsSync()) {
        debugPrint('uploadImageToStorage: file does not exist at path');
        throw Exception('Fichier introuvable: ${imageXFile.path}');
      }

      // Ensure each upload uses a unique object path inside sellersImages/
      final fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
          .ref()
          .child("sellersImages/$fileName.jpg");
      debugPrint('uploadImageToStorage: storage path = ${storageRef.fullPath}');

      try {
        final fStorage.UploadTask uploadTask = storageRef.putFile(file);
        final fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();
        debugPrint('uploadImageToStorage: downloadUrl = $downloadUrl');
        return downloadUrl;
      } catch (e, st) {
        debugPrint('uploadImageToStorage: exception during upload -> $e');
        debugPrint('$st');
        rethrow;
      }
    }
   saveUserDataToFirestore(currentFirebaseUser, name, email, password, locationAddress, phone, downloadUrl) async
  {
    // ici je vais utiliser le package cloud_firestore
    // je vais creer une instance de la collection users
   // je vais stocker les informations de l'utilisateur dans un document dont l'id est l'id de l'utilisateur
   // je vais utiliser la methode set pour stocker les informations de l'utilisateur
   // je vais creer un modele pour stocker les informations de l'utilisateur
   // mais pour l'instant je vais stocker les informations directement dans le document
   // je vais utiliser la methode FirebaseFirestore.instance.collection("users").doc(currentFirebaseUser.uid).set({})
   // mais pour l'instant je vais utiliser un id temporaire
                       //! store data in firestore
    FirebaseFirestore.instance.collection("sellers").doc(currentFirebaseUser.uid).set({
     "uid": currentFirebaseUser.uid,
     "name": name,
     "email": email,
     "image": downloadUrl,
     "address": locationAddress,
     "phone": phone,
     "status": "approved",
     "earnings": 0.0,
     "ratings": 0.0,
     "shopOpen": true,
     "lat": position!.latitude,
     "lng": position!.longitude,
    });
             // save localy store data in shared preferences
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
    await sharedPreferences!.setString("name", name);
    await sharedPreferences!.setString("email", email);
    await sharedPreferences!.setString("imageUrl", downloadUrl);
    await sharedPreferences!.setString("locationAddress", locationAddress);
    await sharedPreferences!.setString("phone", phone);
    await sharedPreferences!.setBool("shopOpen", true);
    }
    // ...existing methods...
Future<void> validateSigninForm(String email, String password, BuildContext context) async {
  if(email.isEmpty) {
    commonViewModel.showSnackbar("Veuillez entrer votre email", context);
  } else if(!email.contains("@")) {
    commonViewModel.showSnackbar("Veuillez entrer un email valide", context);
  } else if(password.isEmpty) {
    commonViewModel.showSnackbar("Veuillez entrer votre mot de passe", context);
  } else {
    commonViewModel.showProgressDialog("Connexion en cours...", context);
    User? currentFirebaseUser = await loginUser(email, password);
    if (currentFirebaseUser == null) {
      commonViewModel.hideProgressDialog(context);
      commonViewModel.showSnackbar("Échec de la connexion. Vérifiez vos identifiants.", context);
      return;
    }

    final ok = await readDataFromFirestoreAndSetDataLocally(currentFirebaseUser, context);
    if (ok) {
      commonViewModel.hideProgressDialog(context);
      commonViewModel.showSnackbar("Connexion réussie", context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      commonViewModel.hideProgressDialog(context);
    }
  }
}

Future<User?> loginUser(String email, String password) async {
  User? currentFirebaseUser;
  try {
    final valueAuth = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    currentFirebaseUser = valueAuth.user;
  } catch (errorMsg) {
    debugPrint("loginUser: ${errorMsg.toString()}");
  }
  return currentFirebaseUser;
}
Future<bool> readDataFromFirestoreAndSetDataLocally(User? currentUser, BuildContext context) async {
  if (currentUser == null) return false;
  try {
    final datasnapshot = await FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).get();
    if (!datasnapshot.exists) {
      commonViewModel.showSnackbar("Votre compte de vendeur n'existe pas.", context);
      debugPrint("readDataFromFirestoreAndSetDataLocally: No seller document found for uid ${currentUser.uid}");
      await FirebaseAuth.instance.signOut();
      return false;
    }

    final data = datasnapshot.data() as Map<String, dynamic>;
    if ((data["status"] ?? "") != "approved") {
      commonViewModel.showSnackbar("Votre compte n'est pas approuvé. Veuillez contacter le support.", context);
      debugPrint("readDataFromFirestoreAndSetDataLocally: Seller account not approved for uid ${currentUser.uid}");
      await FirebaseAuth.instance.signOut();
      return false;
    }

    // Ensure sharedPreferences instance exists
    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }

    final String uid = currentUser.uid;
    final String name = (data["name"] ?? "").toString();
    final String email = (data["email"] ?? "").toString();
    final String phone = (data["phone"] ?? data["telephone"] ?? "").toString();
    final String imageUrl = (data["imageUrl"] ?? data["image"] ?? "").toString();
    final String address = (data["address"] ?? data["completAddress"] ?? "").toString();
    final bool shopOpen = (data["shopOpen"] ?? true) == true;
    final String status = (data["status"] ?? "").toString();

    await sharedPreferences!.setString("status", status);
    await sharedPreferences!.setString("uid", uid);
    await sharedPreferences!.setString("name", name);
    await sharedPreferences!.setString("email", email);
    await sharedPreferences!.setString("phone", phone);
    await sharedPreferences!.setString("imageUrl", imageUrl);
    await sharedPreferences!.setString("locationAddress", address);
    await sharedPreferences!.setBool("shopOpen", shopOpen);
    return true;
  } catch (error) {
    debugPrint("readDataFromFirestoreAndSetDataLocally: Error fetching seller document: $error");
    return false;
  }
}
}





/// Authenticates a user using email and password, then checks if the user is a seller.
/// 
/// - [email]: The user's email address.
/// - [password]: The user's password.
/// - [context]: The BuildContext for showing dialogs and navigation.
/// 
/// Steps:
/// 1. Attempts to sign in the user with Firebase Authentication using the provided email and password.
/// 2. If sign-in fails, hides the progress dialog and shows an error message using a snackbar.
/// 3. If sign-in succeeds, retrieves the current user's information.
/// 4. Checks if a seller account exists in Firestore for the authenticated user.
///    - If a seller account exists:
///       - Hides the progress dialog.
///       - Shows a success message.
///       - Navigates to the HomeScreen.
///    - If no seller account is found:
///       - Hides the progress dialog.
///       - Shows an error message indicating no seller account was found.
///       - Signs out the user from Firebase Authentication.