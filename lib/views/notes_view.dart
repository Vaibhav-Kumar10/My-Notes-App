/// Main notes screen of the application.
///
/// This view is displayed when:
/// - The user is authenticated
/// - The user's email is verified
///
/// Responsibilities:
/// - Display the primary app content (notes)
/// - Provide logout functionality via the app bar menu
/// - Handle user sign-out and navigate back to login
///
library;

import 'package:flutter/material.dart';
import 'package:my_notes_app/constants/routes.dart';
import 'package:my_notes_app/enums/menu_action.dart';
import 'package:my_notes_app/services/auth/auth_service.dart';

/// Stateful widget representing the authenticated area of the app.
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

/// State class for NotesView.
///
/// Manages:
/// - UI rendering of main notes screen
/// - Logout interactions via PopupMenuButton
/// - Confirmation dialog before logging out
class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    // The widget for specifying each page / screen of app
    // Has variuos part -
    // 1. Appbar - The top bar
    // 2. Body - for main content
    // 3. etc.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main UI"),
        backgroundColor: Colors.blue[100],
        actions: [
          // Popup menu for additional actions like logout
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                // If logout button is clicked
                case MenuAction.logout:
                  // get the confirmation to log out
                  final shouldLogout = await showLogOutDialog(context);
                  // Show confirmation dialog before logging out
                  if (shouldLogout) {
                    // Log out the user via AuthService
                    await AuthService.firebase().logOut();
                    // Navigate back to the login screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      // remove everything
                      (route) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              // Menu items for the popup menu - Return a list of MenuItemEntry
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Log out"),
                ),
              ];
            },
          ),
        ],
      ),

      // Main body of the screen showing user's notes
      body: Text("My Notes"),
    );
  }
}

/// Shows a confirmation dialog before logging out.
///
/// Returns a `Future<bool>`:
/// - true if user confirms logout
/// - false if user cancels
///
/// Prevents accidental logouts and handles null returns if dialog is dismissed.
///
Future<bool> showLogOutDialog(BuildContext context) {
  // showDialog returns an Future with optional return value
  return showDialog(
    context: context,
    // Builds a widget - AlertDialog
    builder: (context) {
      return AlertDialog(
        title: Text("Sign Out"),
        content: Text("Are you sure you wnt to sign out ?"),
        actions: [
          // Cancel button returns false
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            label: Text("Cancel"),
            icon: Icon(Icons.cancel),
          ),

          // Log out button returns true
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            label: Text("Log Out"),
            icon: Icon(Icons.logout),
          ),
        ],
      );
    },
  ).then((onValue) => onValue ?? false);
  // Prevents null if dialog is dismissed
  // then - returns a value that is either returned from the showDialog or a default value, here false
  // Prevents null values that might be returned when user clicks on back navigation button or gesture or outside the dialog
}
