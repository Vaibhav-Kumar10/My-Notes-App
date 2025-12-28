/// Home routing widget of the application, which decides which screen to show based on authentication.
///
/// This widget:
/// - Initializes the authentication service
/// - Decides which screen to show based on authentication state
/// - Acts as the app's navigation gatekeeper
///
/// Possible navigation outcomes:
/// - NotesView → logged in & email verified
/// - VerifyEmailView → logged in but not verified
/// - LoginView → not logged in
///
/// While the authentication service is initializing, it shows a loading indicator.
library;

import 'package:flutter/material.dart';
import 'package:my_notes_app/views/notes_view.dart';
import 'package:my_notes_app/views/login_view.dart';
import 'package:my_notes_app/views/verify_email_view.dart';
import 'package:my_notes_app/constants/loading.dart';
import 'package:my_notes_app/services/auth/auth_service.dart';

/// HomePage determines the initial screen using authentication state.
///
/// Uses a [FutureBuilder] to wait for authentication initialization
/// before making navigation decisions.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Builds UI based on authentication initialization state.
  ///
  /// Shows:
  /// - Loading indicator while initializing
  /// - Appropriate screen after authentication status is resolved
  @override
  Widget build(BuildContext context) {
    // BuildContext context can be used to pass information form current Widget to another of its child Widget
    // Use FutureBuilder to wait for AuthService initialization
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      // Builder function is called when the Future finishes
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          // When the state is done
          case ConnectionState.done:
            // Get the current logged-in user from AuthService
            final user = AuthService.firebase().currentUser;

            // If user exists, navigate based on email verification
            if (user != null) {
              // If the user's email is verified - go to notes view
              if (user.isEmailVerified) {
                return const NotesView();
              }
              // If the user's email is not verified
              else {
                // No user logged in, show login
                return const VerifyEmailView();
              }
            }
            // If user does not exist, show loading while initializing
            else {
              return const LoginView();
            }

          default:
            return Loading();
          // Any other connection state
          // ConnectionState.none, ConnectionState.waiting, ConnectionState.active
        }
      },
    );
  }
}
