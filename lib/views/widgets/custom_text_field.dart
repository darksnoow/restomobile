import 'package:flutter/material.dart';
// ce code est utilisable a chaque fois qu'on a besoin de cree un nouveau text field faut simplement pas oublier de donner les parametre lier creer les 5 parametres
// l'avantage de ce widget c'est qu'on peut le reutiliser a chaque fois qu'on a besoin d'un text field pour eviter de recrire le meme code a chaque fois et modifier seulement les parametre de tout les text field
class CustomTextField extends StatefulWidget {
     // ici on place les controler le controler(nature)-le nom du controler
     TextEditingController? textEditingController ;
     IconData? iconData;
     String? hintString;
     bool? isObscure = true; //ici on cache les donnees pour le password pour l'email vible auto.
     bool? enabled = true;

  // ceci est le constructeur qui doit obligatoirement recevoir les parametre des controler
  CustomTextField({super.key, this.textEditingController, this.iconData, this.hintString, this.isObscure, this.enabled});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
       padding: const EdgeInsets.all(11),
       margin: const EdgeInsets.all(12),
       child: TextFormField(
        // ici on active les controler cree en haut de l'app
        enabled: widget.enabled,
        controller: widget.textEditingController,
        obscureText: widget.isObscure!,
        decoration:InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            widget.iconData,
            color: Colors.blueAccent,
          ),
          hintText: widget.hintString,
          hintStyle: const TextStyle(color: Colors.black54),
        
        ) ,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    ),
       ),
    );
  }
}