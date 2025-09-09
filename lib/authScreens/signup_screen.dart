import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}


class _SignupScreenState extends State<SignupScreen> 
{


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
            
           const SizedBox(height: 11,),
           InkWell(
            onTap: () {
              
            },
            child: CircleAvatar(
              // best way to ajuste resposonve ui to the phone screen size
              radius: MediaQuery.of(context).size.width * 0.20,
              backgroundColor: Colors.white,
            ),
           )
         
        ],
      ),
    );
  }
}