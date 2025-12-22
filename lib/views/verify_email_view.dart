import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

import 'package:my_notes_app/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email"),
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
          SizedBox(height: 10.0),

          Text(
            "Verification Email sent. Please check your inbox to complete verification.",
          ),

          SizedBox(height: 10.0),

          Text(
            "If you haven't received the verification email yet, press the button below.",
          ),

          SizedBox(height: 10.0),

          TextButton(
            onPressed: () async {
              // Get the current user from Firebase Auth object
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
              // devtools.log("Verification button clicked");
            },
            child: Text("Send Email Veification"),
          ),

          SizedBox(height: 10.0),

          // Button to restart the process
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                // Got to register
                registerRoute,
                (route) => false,
              );
              // devtools.log("RESTART button clicked");
            },
            child: Text("RESTART"),
          ),
        ],
      ),
    );
  }
}
