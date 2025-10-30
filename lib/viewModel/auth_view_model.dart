 
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
  String completeAddress,
  bool termsAccepted,
  BuildContext context,
) async {
  // Trim des champs
  final trimmedname = name.trim();
  final trimmedphone = phone.trim();
  final trimmedemail = email.trim();
  final trimmedpassword = password.trim();
  final trimmedconfirm = confirmPassword.trim();
  final trimmedlocation = completeAddress.trim();

  // Vérifier l'acceptation des conditions
  if (!termsAccepted) {
    commonViewModel.showSnackbar("Veuillez accepter les conditions de confidentialité", context);
    return;
  }

  // Vérifier les champs obligatoires et lister ceux manquants pour faciliter le debug
  final List<String> missingFields = [];
  if (trimmedname.isEmpty) missingFields.add('Nom');
  if (trimmedphone.isEmpty) missingFields.add('Téléphone');
  if (trimmedemail.isEmpty) missingFields.add('Email');
  if (trimmedpassword.isEmpty) missingFields.add('Mot de passe');
  if (trimmedconfirm.isEmpty) missingFields.add('Confirmation du mot de passe');
  if (trimmedlocation.isEmpty) missingFields.add('Adresse');
  if (imageXFile == null) missingFields.add('Photo de profil');

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
  // L'image est requise (déjà contrôlée dans missingFields)

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

    // Récupérer l'utilisateur courant créé ci-dessus
    final User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
    if (currentFirebaseUser == null) {
      commonViewModel.hideProgressDialog(context);
      commonViewModel.showSnackbar("Impossible de récupérer l'utilisateur après la création", context);
      return;
    }

    // Uploader l'image (non nulle car validée plus haut)
    final String downloadUrl = await uploadImageToStorage(imageXFile);

    // Sauvegarder les données utilisateur dans Firestore et localement
    await saveUserDataToFirestore(
      currentFirebaseUser,
      trimmedname,
      trimmedemail,
      trimmedpassword,
      trimmedlocation,
      trimmedphone,
      downloadUrl,
    );

     await readDataFromFirestoreAndSetDataLocally(currentFirebaseUser, context);

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
       email: email,
       password: password).then((valueAuth){
       currentFirebaseUser = valueAuth.user;
       }).catchError((errorMsg){
        // ici je vais afficher un snackbar pour dire qu'il y a une erreur
        commonViewModel.showSnackbar(errorMsg, context);
       });
       // ici je vais ajouter une methode pour envoyer un email de verification aussi verifier si l 'utilisateur est null
       if(currentFirebaseUser == null)
       {
        FirebaseAuth.instance.signOut();
        return;
         //
       }
       return currentFirebaseUser;
  }
  // ici je vais creer une methode pour stocker l'image dans firebase storage et recuperer le lien de l'image
  uploadImageToStorage(XFile? imageXFile) async {
      // ici je vais utiliser le package firebase_storage
      // je vais creer un identifiant unique pour chaque image
      String downloadUrl = "";

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference storageRef = fStorage.FirebaseStorage.instance.ref().child("sellersImages").child(fileName);
      fStorage.UploadTask uploadTask = storageRef.putFile(File(imageXFile!.path));
      fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      await taskSnapshot.ref.getDownloadURL().then((imageUrl)
      {
        downloadUrl = imageUrl;
        
      });
      return downloadUrl;
     
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
    await FirebaseFirestore.instance.collection("sellers").doc(currentFirebaseUser.uid)
    .set(
      {
     "uid": currentFirebaseUser.uid,
     "name": name,
     "email": email,
     // stocker les deux clés pour compatibilité
     "image": downloadUrl,
     "imageUrl": downloadUrl,
     "address": locationAddress,
     "completAddress": locationAddress,
     "phone": phone,
     "telephone": phone,
     "status": "approved",
     "earnings": 0.0,
     "ratings": 0.0,
     "shopOpen": true,
     // dupliquer lat/lng pour compatibilité
     "latitude": position!.latitude,
     "longitude": position!.longitude,
     "lat": position!.latitude,
     "lng": position!.longitude,
    });
             // save localy store data in shared preferences
   // ici je vais mettre appeler la methode shared preferences pour stocker les informations de l'utilisateur en local
   sharedPreferences ??= await SharedPreferences.getInstance();
   await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
   await sharedPreferences!.setString("name", name);
   await sharedPreferences!.setString("email", email);
   await sharedPreferences!.setString("imageUrl", downloadUrl);
  
  }
 
 
 validateSigninForm(String email, String password, BuildContext context) async {
   
    if(email.isEmpty || !email.contains("@"))
    {
      commonViewModel.showSnackbar("Veuillez entrer une adresse email valide", context);
    }
    else if(password.isEmpty)
    {
      commonViewModel.showSnackbar("Veuillez entrer votre mot de passe", context);
      return;
    }
    else
    {
      // afficher le progress dialog
      commonViewModel.showProgressDialog("Connexion en cours...", context);
     User? currentFirebaseUser = await loginUser(email, password, context);

     await readDataFromFirestoreAndSetDataLocally(currentFirebaseUser, context);
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
 
    }
  }


  loginUser(String email, String password, BuildContext context) async {
      User? currentFirebaseUser;
    await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password)
      .then((valueAuth) {
        currentFirebaseUser = valueAuth.user;
      }).catchError((errorMsg) {


        commonViewModel.hideProgressDialog(context);
        commonViewModel.showSnackbar("Erreur lors de la connexion: $errorMsg", context);
      });

      if(currentFirebaseUser == null)
      {
        FirebaseAuth.instance.signOut();
        commonViewModel.hideProgressDialog(context);
        commonViewModel.showSnackbar("Impossible de se connecter. Veuillez réessayer.", context);
        return;
      }
      
     return currentFirebaseUser;

  }

  readDataFromFirestoreAndSetDataLocally(User? currentFirebaseUser,BuildContext context) async {
        await FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentFirebaseUser!.uid)
        .get().then((dataSnapshot) async
        {
          if(dataSnapshot.exists){

            if(dataSnapshot.data()!["status"] == "approved")
            {
              // stocker les donnees localement
                await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
                await sharedPreferences!.setString("name", dataSnapshot.data()!["name"]);
                await sharedPreferences!.setString("email", dataSnapshot.data()!["email"]);
                await sharedPreferences!.setString("imageUrl", dataSnapshot.data()!["image"]);
            }
            else
            {
              commonViewModel.hideProgressDialog(context);
              commonViewModel.showSnackbar("Votre compte n'est pas encore approuvé. Veuillez contacter l'administrateur:thinkerteamgui@gmail.com.", context);
              FirebaseAuth.instance.signOut();
              return;
            }
          }
          else
          {
              commonViewModel.showSnackbar("Cette Utilisateur n'existe pas.", context);
              FirebaseAuth.instance.signOut();
                return;
              }
            
            });

         
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