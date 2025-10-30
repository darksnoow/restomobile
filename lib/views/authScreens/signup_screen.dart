import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global_instances.dart';
// removed unused import
import 'package:sellers_app/views/widgets/custom_text_field.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}


class _SignupScreenState extends State<SignupScreen> 
{
  // acceptance des conditions
  bool termsAccepted = false;
  // je vais creer une instance de la classe pour implementer le  image picker
  XFile? imageFile;
  // je dois initialiser la cle du formulaire
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  // ici j'initialise les controler pour chaque text field ou les variable globale
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  
  // ici j'initialise l'objet image picker
  final ImagePicker _picker = ImagePicker();

  // ici je place toutes mes methodes 

  // ici je jappel la methode pour recuperer l'image
  pickImageFrompGalerie() async
  {
    // ici la methode pour recuperer l'image assigner a l'objet imageFile
    imageFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      // pour rafraichir l'interface et afficher l'image donc on appel le setState et on passe l'objet imageFile
      imageFile;
    });
  }
 


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
            
           const SizedBox(height: 11,),
           InkWell(
            onTap: () {
              // donc ici on appel la methode pour recuperer l'image qui est creer en haut quand on tape sur le circle avatar
              pickImageFrompGalerie();
            },
            child: CircleAvatar(
              // best way to ajuste resposonve ui to the phone screen size
              radius: MediaQuery.of(context).size.width * 0.20,
              backgroundColor: Colors.white,
              // ici on verifie si l'image est null ou pas pour afficher l'icon ou l'image
              backgroundImage: imageFile == null ? null : FileImage(
                // ici on converti l'image en file image pour l'afficher
                // ignore: unnecessary_null_comparison
                File(imageFile!.path),
              ),
              // si l'image est null on affiche l'icon sinon on affiche l'image
              child: imageFile == null 
              ? Icon(
                Icons.add_photo_alternate,
                size: MediaQuery.of(context).size.width * 0.20,
                color: Colors.grey,
                )
              : null,
            ),
           ),
            const SizedBox(height: 11,),
            const Text(
              "Add Image",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 11,
            ),
            Form(
              // ici je passe la clé du formulaire
              key: formkey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    //ici j'utilise la le widget creer contenant toutes les parametres preablement creer appeler CustomTextField
                     CustomTextField(
                      //on appel d'abort les contronller puis on pass a la valeur voulu comme avec l'email-le mot de pass l'icon
                        textEditingController: nameTextEditingController,
                        iconData: Icons.person,
                        hintString: "Name",
                        isObscure: false, //pour permettre a l'utilisateur de voir ce qu'il tape
                        enabled: true,
                     ),
                     const SizedBox(height: 11,
                     ),
                
                     CustomTextField(
                       textEditingController: emailTextEditingController,
                       iconData: Icons.email,
                       hintString: "Email",
                       isObscure: false,
                       enabled: true,
                     ),
                     const SizedBox(height: 11,
                     ),
                
                     CustomTextField(
                       textEditingController: passwordTextEditingController,
                       iconData: Icons.lock,
                       hintString: "Password",
                       isObscure: true,
                       enabled: true,
                     ),
                      const SizedBox(height: 11,
                      ),
                
                      CustomTextField(
                        textEditingController: confirmPasswordTextEditingController,
                        iconData: Icons.lock,
                        hintString: "Confirm Password",
                        isObscure: true,
                        enabled: true,
                      ),
                      const SizedBox(height: 11,
                      ),
                
                      CustomTextField(
                        textEditingController: phoneTextEditingController,
                        iconData: Icons.phone,
                        hintString: "Phone",
                        isObscure: false,
                        enabled: true,
                      ),
                      const SizedBox(height: 11,
                      ),
                
                      CustomTextField(
                        textEditingController: locationTextEditingController,
                        iconData: Icons.my_location,
                        hintString: "Café/Resto Location",
                        isObscure: false,
                        enabled: true,
                      ),
                      const SizedBox(height: 11,
                      ),
                      // Checkbox personnalisée pour accepter les conditions
                      Row(
                        children: [
                          Checkbox(
                            value: termsAccepted,
                            onChanged: (value) {
                              if (value == true) {
                                authViewModel.showPrivacyDialogV2(
                                  context,
                                  () => setState(() => termsAccepted = true),
                                );
                              } else {
                                setState(() => termsAccepted = false);
                              }
                            },
                            activeColor: Colors.yellow,
                            checkColor: Colors.black,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                authViewModel.showPrivacyDialogV2(
                                  context,
                                  () => setState(() => termsAccepted = true),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "J'accepte les ",
                                  style: TextStyle(color: Colors.white70),
                                  children: [
                                    TextSpan(
                                      text: "conditions de confidentialité",
                                      style: TextStyle(color: Colors.yellow, decoration: TextDecoration.underline),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11,
                      ),
                      // ici j'ajoute un bouton pour recuperer la position de l'utilisateur
                      Container(
                       width: 398,
                       height: 39,
                       alignment: Alignment.center,
                       child: ElevatedButton.icon(
                        onPressed: () async {
                        // ici je vais ajouter la methode pour l'inscription et aussi la validation du formulaire
                // ici je vais appeler la methode get current location de la classe common view model
                 String address = await commonViewModel.getCurrentLocation();
                 // ici j'affecte l'adresse recuperer dans le text field de l'adresse
                  setState(() {
                    // pour rafraichir l'interface et afficher l'adresse dans le text field
                    locationTextEditingController.text = address;
                  });
                
                        },
                        icon: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        label:  Text(
                          "Get my current location",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,  
                        ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                       ),
                      ),
                   ],
                 ), 
              ),
            ),
            const SizedBox(height: 11,),
            ElevatedButton(
              onPressed: () async
              {
                final name = nameTextEditingController.text.trim();
                final phone = phoneTextEditingController.text.trim();
                final email = emailTextEditingController.text.trim();
                final password = passwordTextEditingController.text.trim();
                final confirm = confirmPasswordTextEditingController.text.trim();
                final location = locationTextEditingController.text.trim();

                // Debug log to inspect values passed to validateSignUpForm
                debugPrint('DEBUG signUp args: name="${name}" len=${name.length}, phone="${phone}" len=${phone.length}, emailLen=${email.length}, passwordLen=${password.length}, confirmLen=${confirm.length}, locationLen=${location.length}, image=${imageFile != null}');

                await authViewModel.validateSignUpForm(
                  imageFile,
                  name,
                  phone,
                  email,
                  password,
                  confirm,
                  location,
                  termsAccepted,
                  context,
                );

              },
               
               
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 50 ,vertical:  10),
              ),
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      
              const SizedBox(height: 41,),
        ],
           ),
      ) ;
    }
  }
