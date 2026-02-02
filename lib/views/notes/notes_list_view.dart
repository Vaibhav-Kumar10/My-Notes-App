/// Stateless widget responsible for rendering a list of notes.
///
/// Responsibilities:
/// - Receive list of DatabaseNote objects
/// - Display them in a scrollable list
/// - Provide callbacks for:
///     • onDelete
///     • onTap (open note)
///
/// Purpose:
/// - Separate UI rendering from business logic
/// - Keep NotesView clean and readable
///
/// This widget is purely presentational:
/// - No database logic
/// - No service calls
/// - Only displays data and triggers callbacks
///
/// Promotes:
/// - Reusability
/// - Testability
/// - Clean architecture
///
library;

import 'package:flutter/material.dart';
import 'package:my_notes_app/services/crud/notes_service.dart';
import 'package:my_notes_app/utilities/dialogs/delete_dialog.dart';

// Callback function, called when user clicks the node
typedef NoteCallback = void Function(DatabaseNote note);

// Display a list of notes for user
class NotesListView extends StatelessWidget {
  // Pass a list of notes to show each of them
  final List<DatabaseNote> notes;

  final NoteCallback onDeleteNode;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use ListView.builder to show each note
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        // The current note
        final curNote = notes[index];
        return ListTile(
          onTap: () => onTap(curNote),

          title: Text(
            curNote.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),

          trailing: IconButton(
            onPressed: () async {
              // Show a alert dialog to conform note deletion
              // Returns true or false
              final shouldDelete = await showDeleteDialog(context);
              // If true, delete node
              if (shouldDelete) {
                onDeleteNode(curNote);
              }
            },
            icon: const Icon(Icons.delete),
            color: Colors.orangeAccent,
          ),

          leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_document),
            color: Colors.amberAccent,
          ),

          subtitle: Text(("$index")),
          iconColor: Colors.blue[200],
          tileColor: Colors.deepPurpleAccent[100],
        );
      },
    );
  }
}
