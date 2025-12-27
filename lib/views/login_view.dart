/// Login screen of the application.
///
/// It allows existing users to log in with email and password.
///
/// This view allows existing users to:
/// - Enter email and password
/// - Authenticate using Firebase Authentication
///
/// Responsibilities:
/// - Capture user credentials via text fields
/// - Authenticate using Firebase via AuthService
/// - Handle authentication errors with user-friendly messages
/// - Navigate users based on email verification status
///
library;

import 'package:flutter/material.dart';
import 'package:my_notes_app/services/auth/auth_exceptions.dart';
import 'package:my_notes_app/services/auth/auth_service.dart';
import 'package:my_notes_app/utilities/show_error_dialog.dart';
import 'package:my_notes_app/constants/routes.dart';

/// Stateful widget for handling user login.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

/// State class that manages:
/// - TextEditingControllers for email and password input
/// - Authentication requests to AuthService
/// - Navigation after successful login
class _LoginViewState extends State<LoginView> {
  // Controller for email input
  late final TextEditingController _email;
  // Controller for password input
  late final TextEditingController _password;

  /// Initializes the text controllers when the widget is created
  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  /// Disposes the text controllers to free resources
  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The widget for specifying each page / screen of app
    // Has variuos part -
    // 1. Appbar - The top bar
    // 2. Body - for main content
    // 3. etc.
    return Scaffold(
      appBar: AppBar(title: Text("Login"), backgroundColor: Colors.blue[100]),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Email input field
            TextField(
              // Specify that the input type is email address
              keyboardType: TextInputType.emailAddress,

              // Disable sugesstions and autocorrect while typing
              enableSuggestions: false,
              autocorrect: false,

              // Specify the TextEditingController for password
              controller: _email,

              // Show hint to user
              decoration: InputDecoration(hintText: "Enter your email here"),
            ),

            // Password input field
            TextField(
              // Hide the input as it is password
              obscureText: true,

              // Disable sugesstions and autocorrect while typing
              enableSuggestions: false,
              autocorrect: false,

              // Specify the TextInputController for password
              controller: _password,

              // Show hint to user
              decoration: InputDecoration(hintText: "Enter your password here"),
            ),

            // Login button
            ElevatedButton(
              child: Text("Login"),
              onPressed: () async {
                // Store the contents from the TextEditingController objects
                final email = _email.text;
                final password = _password.text;

                try {
                  // Attempt to log in via AuthService
                  await AuthService.firebase().logIn(
                    email: email,
                    password: password,
                  );

                  // Navigate based on email verification status
                  final user = AuthService.firebase().currentUser;
                  // If the user's email is verified, let him login into app
                  if (user!.isEmailVerified) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  }
                  // If the user's email is not verified, prompt them to verify email
                  else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                    );
                  }
                } on EmptyFieldsAuthException {
                  await showErrorAlerts(context, "Fields can't be empty");
                } on UserNotFoundAuthException {
                  await showErrorAlerts(context, "User Not Found");
                } on WrongPasswordAuthException {
                  await showErrorAlerts(context, "Wrong Credentials");
                } on GenericAuthException {
                  await showErrorAlerts(context, "Authentication Error");
                }
              },
            ),

            const SizedBox(height: 30.0),

            // Link to registration screen
            TextButton(
              child: const Text("Not registered yet ? Register now"),
              onPressed: () {
                // Push the route with the given name onto the navigator, and then remove all the previous routes until the predicate returns true.
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  // remove everything
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
