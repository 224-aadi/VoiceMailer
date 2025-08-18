// ignore_for_file: unused_import, prefer_const_constructors

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_mailer_new/homepage.dart';
import 'package:voice_mailer_new/change_email.dart';
import 'package:voice_mailer_new/main.dart';
import 'package:voice_mailer_new/saved.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController email = TextEditingController();
  late SharedPreferences prefs;
  late String givenEmail;

  int _currentIndex = 2;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const Divider(
            thickness: 1.5,
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Change Email'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeEmail(
                          email: givenEmail,
                        )),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text('Theme'),
            trailing: const SizedBox(
              width: 50,
              height: 40,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Switch(
                  value: false,
                  onChanged: null,
                ),
              ),
            ),
            onTap: () {
              // Theme setting
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Permissions'),
            trailing: Text('Granted'),
            onTap: () {
              // Permissions setting
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.support),
            title: Text('Contact Support'),
            onTap: () {
              // Contact support
            },
          ),
          const Divider(
            thickness: 1.5,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SavedRecordings()),
            );
          } else if (index == 2) {
            // Stay on the same page (Settings)
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
