// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fisio_seguro_app/screens/auth/login_screen.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Logout"),
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              if (kDebugMode) {
                print("Signed Out");
              }
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            });
          },
        ),
      ),
    );
  }
}