/// Email verification screen.
///
/// This view is shown when:
/// - A user is logged in
/// - But has not verified their email address
///
/// Responsibilities:
/// - Inform the user that a verification email has been sent
/// - Allow resending the verification email
/// - Allow restarting the authentication flow (logout and return to registration)
///
library;

import 'package:flutter/material.dart';
import 'package:my_notes_app/constants/routes.dart';
import 'package:my_notes_app/services/auth/auth_service.dart';

/// Stateful widget for handling email verification actions.
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

/// State class that manages verification-related user actions.
///
/// Provides:
/// - Resend verification email
/// - Logout and restart registration process
class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    // The widget for specifying each page / screen of app
    // Has variuos part -
    // 1. Appbar - The top bar
    // 2. Body - for main content
    // 3. etc.
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email"),
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10.0),

          // Inform user that a verification email has been sent
          const Text(
            "Verification Email sent. Please check your inbox to complete verification.",
          ),

          const SizedBox(height: 10.0),

          // Instructions for resending email if not received
          const Text(
            "If you haven't received the verification email yet, press the button below.",
          ),

          const SizedBox(height: 10.0),

          // Button to resend verification email
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: Text("Send Email Veification"),
          ),

          SizedBox(height: 10.0),

          // Button to restart the authentication process
          TextButton(
            onPressed: () async {
              // Logout the current user
              await AuthService.firebase().logOut();
              // Navigate to registration screen and remove all previous routes
              Navigator.of(context).pushNamedAndRemoveUntil(
                // Got to register
                registerRoute,
                (route) => false,
              );
            },
            child: Text("RESTART"),
          ),
        ],
      ),
    );
  }
}
