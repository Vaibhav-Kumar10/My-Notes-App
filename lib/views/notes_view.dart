import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Import as alias and impoort only specific feature only
import 'dart:developer' as devtools show log;

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

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
        // leading: Icon(Icons.home),
        title: const Text("Main UI"),
        backgroundColor: Colors.blue[100],
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              print("Selected $value");
              devtools.log("Selected $value");
              switch (value) {
                // If logout button is clicked
                case MenuAction.logout:
                  // get the confirmation to log out
                  final shouldLogout = await showLogOutDialog(context);
                  devtools.log(shouldLogout.toString());
                  // If confirm, logout
                  if (shouldLogout) {
                    // send request to firebase auth to signout
                    await FirebaseAuth.instance.signOut();
                    // change the screen to login
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (_) => false);
                  }
              }
            },
            itemBuilder: (context) {
              // Return a list of MenuItemEntry
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Log out"),
                ),
              ];
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.logout),
            label: Text("Logout"),
            onPressed: () {},
          ),
        ],
      ),
      body: Text("My Notes"),
    );
  }
}

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
          TextButton.icon(
            onPressed: () {
              // Pop the current screen and return false
              Navigator.of(context).pop(false);
            },
            label: Text("Cancel"),
            icon: Icon(Icons.cancel),
          ),
          TextButton.icon(
            onPressed: () {
              // Pop the current screen and return true
              Navigator.of(context).pop(true);
            },
            label: Text("Log Out"),
            icon: Icon(Icons.logout),
          ),
        ],
      );
    },
  ).then((onValue) => onValue ?? false);
  // then - returns a value that is either returned from the showDialog or a default value, here false
  // Prevents null values that might be returned when user clicks on back navigation button or gesture or outside the dialog
}
