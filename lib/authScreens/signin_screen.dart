import 'package:flutter/material.dart';
import 'package:sellers_app/widgets/custom_text_field.dart';


class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}
class _SigninScreenState extends State<SigninScreen>
 {
    //ici je jappel la methode je cree des objet relier au controler
    TextEditingController emailTextEditingController = TextEditingController();
    TextEditingController passwordTextEditingController = TextEditingController();
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [

         Container(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "images/seller.png",
              height: 270
            ),
          ),

         ),

         Form(
          key: formkey,
          child: Column(
            children: [
              //ici j'utilise la le widget creer contenant toutes les parametres preablement creer appeler CustomTextField
               CustomTextField(
                //on appel d'abort les contronller puis on pass a la valeur voulu comme avec l'email-le mot de pass l'icon
                  textEditingController: emailTextEditingController,
                  iconData: Icons.email,
                  hintString: "Email",
                  isObscure: false, //pour permettre a l'utilisateur de voir ce qu'il tape
                  enabled: true,

               ),

                  CustomTextField(
                //on appel d'abort les contronller puis on pass a la valeur voulu comme avec l'email-le mot de pass l'icon
                  textEditingController: passwordTextEditingController,
                  iconData: Icons.lock,
                  hintString: "Password",
                  isObscure: true,//pour permettre a l'utilisateur de caché ce qu'il tape
                  enabled: true,

               ),

               ElevatedButton(
                onPressed: ()
                {

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50 ,vertical:  10),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
            ],
          ),
         ),

        ],
      ),
    );
  }
}