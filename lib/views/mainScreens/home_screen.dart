import 'package:flutter/material.dart';
import 'package:sellers_app/views/widgets/my_drawer.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}




class _HomeScreenState extends State<HomeScreen> 
{
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
       drawer: MyDrawer(),
       appBar: AppBar(
        title: Text(
            "HOME PAGE"
        ),

       ),

    );
  }
}