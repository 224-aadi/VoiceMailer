// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_mailer_new/Homepage.dart';
// import 'main.dart';

class login extends StatefulWidget {
  @override
  _login createState() => _login();
}

class _login extends State<login> {
  TextEditingController email = TextEditingController();

  Future<void> complete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('login', false);
    prefs.setString('email', email.text.toString());
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Text('Enter Email',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 40,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: (MediaQuery.of(context).size.width / 14),
                    right: (MediaQuery.of(context).size.width / 14),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: email,
                    autocorrect: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(color: Colors.black)),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.black,
                        ),
                        hintText: 'Enter Email',
                        hintStyle: TextStyle(color: Colors.black),
                        labelText: "Enter Email",
                        labelStyle: TextStyle(color: Colors.black)),
                  ),
                ),
                ElevatedButton(
                  onPressed: complete,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                  ),
                  child: Text('Submit'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
