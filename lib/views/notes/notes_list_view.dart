import 'package:flutter/material.dart';
import 'package:my_notes_app/services/crud/notes_service.dart';
import 'package:my_notes_app/utilities/dialogs/delete_dialog.dart';

// Callback function, called when user confirms to delete the node
typedef DeleteNoteCallback = void Function(DatabaseNote note);

// Display a list of notes for user
class NotesListView extends StatelessWidget {
  // Pass a list of notes to show each of them
  final List<DatabaseNote> notes;

  final DeleteNoteCallback onDeleteNode;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNode,
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
