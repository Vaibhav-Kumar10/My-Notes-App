/// User registration screen.
///
/// This view allows new users to:
/// - Create an account using email and password
/// - Receive a verification email
///
/// Responsibilities:
/// - Capture user credentials via text fields
/// - Register the user using Firebase via AuthService
/// - Send verification email
/// - Handle authentication errors gracefully
/// - Navigate users to the email verification screen after successful registration
///
library;

import 'package:flutter/material.dart';
import 'package:my_notes_app/services/auth/auth_exceptions.dart';
import 'package:my_notes_app/services/auth/auth_service.dart';
import 'package:my_notes_app/utilities/show_error_dialog.dart';
import 'package:my_notes_app/constants/routes.dart';

/// Stateful widget responsible for user registration.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

/// State class for RegisterView.
///
/// Manages:
/// - TextEditingControllers for email and password input
/// - Registration requests to AuthService
/// - Sending verification email
/// - Error handling and navigation
class _RegisterViewState extends State<RegisterView> {
  // Controller for email input
  late final TextEditingController _email;
  // Controller for password input
  late final TextEditingController _password;

  /// Initializes text controllers when the widget is created
  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  /// Disposes the text controllers to free resources
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The widget for specifying each page / screen of app
    // Has variuos part -
    // 1. Appbar - The top bar
    // 2. Body - for main content
    // 3. etc.
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        backgroundColor: Colors.blue[100],
      ),

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

            // Register button
            ElevatedButton(
              child: Text("Register"),
              onPressed: () async {
                // Store the contents from the TextEditingController objects
                final email = _email.text;
                final password = _password.text;

                try {
                  // Attempt to register the user via AuthService
                  await AuthService.firebase().createUser(
                    email: email,
                    password: password,
                  );

                  // Send verification email after registration
                  await AuthService.firebase().sendEmailVerification();

                  // Navigate to email verification screen
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                } on EmptyFieldsAuthException {
                  await showErrorAlerts(context, "Fields can't be empty");
                } on InvalidEmailAuthException {
                  await showErrorAlerts(
                    context,
                    "This is an Invalid Email Address",
                  );
                } on EmailAlreadyInUseAuthException {
                  await showErrorAlerts(context, "Email is already in use");
                } on WeakPasswordAuthException {
                  await showErrorAlerts(context, "Weak Password");
                } on GenericAuthException {
                  await showErrorAlerts(context, "Authentication Error");
                }
              },
            ),

            const SizedBox(height: 30.0),

            // Link to login screen
            TextButton(
              child: const Text("Already registered? Login now"),
              onPressed: () {
                // Push the route with the given name onto the navigator, and then remove all the previous routes until the predicate returns true.
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
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
