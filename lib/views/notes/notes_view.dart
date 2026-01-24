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
import 'package:my_notes_app/constants/loading.dart';
import 'package:my_notes_app/constants/routes.dart';
import 'package:my_notes_app/enums/menu_action.dart';
import 'package:my_notes_app/services/auth/auth_service.dart';
import 'package:my_notes_app/services/crud/notes_service.dart';
import 'package:my_notes_app/utilities/dialogs/logout_dialog.dart';
import 'package:my_notes_app/views/notes/notes_list_view.dart';

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
  // Get user's email
  String get userEmail => AuthService.firebase().currentUser!.email!;
  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    // This calls the factory constructor
    super.initState();
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
        title: const Text("Your Notes"),
        backgroundColor: Colors.blue[100],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),

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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          // Grab all notes from streamController
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        // print(allNotes);
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNode: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                        );
                      } else {
                        return const Loading();
                      }
                    default:
                      return const Loading();
                  }
                },
              );
            default:
              return const Loading();
          }
        },
      ),
    );
  }
}
