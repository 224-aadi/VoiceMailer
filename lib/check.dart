// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_mailer_new/homepage.dart';
import 'login.dart';
// import 'main.dart';

class Checking extends StatefulWidget {
  const Checking({super.key});

  @override
  State<Checking> createState() => _CheckingState();
}

class _CheckingState extends State<Checking> {
  late SharedPreferences prefs;
  //String email;
  late bool newuser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfAlreadyLogin();
  }

  void checkIfAlreadyLogin() async {
    prefs = await SharedPreferences.getInstance();
    //email = prefs.getString('name');
    newuser = (prefs.getBool('login') ?? true);
    debugPrint(newuser.toString());
    if (newuser == false) {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    } else {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Login()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Padding(padding: EdgeInsets.only(top: 10)),
            Align(
              alignment: Alignment.center,
              child: Text(
                "VoiceMailer",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
