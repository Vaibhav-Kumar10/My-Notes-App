import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Email")),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              // Get the current user from Firebase Auth object
              final User? user = FirebaseAuth.instance.currentUser;
              await user!.sendEmailVerification();
              devtools.log("Verification button clicked");
            },
            child: Text("Send Email Veification"),
          ),

          Text("Verify your email to continue"),
        ],
      ),
    );
  }
}
