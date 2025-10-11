import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/utils/widgets/util_vars.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          UtilVars.appName,
          style: GoogleFonts.pacifico(letterSpacing: 4),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Iconic.heart)),
          IconButton(onPressed: () {}, icon: Icon(Iconic.comment)),
        ],
        centerTitle: false,
      ),
      body: Column(children: [
          
        ],
      ),
    );
  }
}
