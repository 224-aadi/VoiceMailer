// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key, required this.email});

  final String email;

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  TextEditingController email = TextEditingController();
  late SharedPreferences prefs;
  late String givenEmail;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmail();
  }

  void getEmail() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        givenEmail = prefs.getString('email') ?? 'Enter Email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Email'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: (screenWidth / 14),
                  right: (screenWidth / 14),
                  top: (screenWidth / 6)),
              alignment: Alignment.center,
              child: TextField(
                controller: email,
                autocorrect: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.black)),
                  prefixIcon: Icon(
                    Icons.email,
                  ),
                  hintText: widget.email,
                  labelText: "Enter Email",
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: (screenWidth / 3.2)),
              child: ElevatedButton(
                onPressed: () async {
                  prefs = await SharedPreferences.getInstance();
                  prefs.setString('email', email.text.toString());
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.black87),
                  ),
                ),
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
