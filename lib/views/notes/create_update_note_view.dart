/// Screen used for both creating and updating notes.
///
/// This view handles:
/// - Creating a new empty note
/// - Editing existing note content
/// - Auto-saving changes to local database
///
/// Behavior:
/// - If note argument exists → update mode
/// - If no note → create new note
///
/// Responsibilities:
/// - Load note data
/// - Track text changes
/// - Persist updates using NotesService
/// - Delete empty notes if needed
///
/// Design choice:
/// A single screen handles both create & update to:
/// - Reduce duplication
/// - Keep UX simple
/// - Share same editor logic
///
/// Connected to:
/// - NotesService (CRUD operations)
/// - Navigation back to NotesView
///
library;

import 'package:flutter/material.dart';
import 'package:my_notes_app/constants/loading.dart';
import 'package:my_notes_app/services/auth/auth_service.dart';
import 'package:my_notes_app/services/crud/notes_service.dart';
import 'package:my_notes_app/utilities/generics/get_arguements.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _notesService = NotesService();
    _textEditingController = TextEditingController();
    super.initState();
  }

  // Listenerthat updates the current note upon text changes
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textEditingController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupTextContollerListener() async {
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  // Create an empty note every time add note screen is reached
  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    // Get the note from arguements, if any
    final widgetNote = context.getArguement<DatabaseNote>();

    // If we get a note from arguements, show that note
    if (widgetNote != null) {
      _note = widgetNote;
      // Pre populate with existing note text
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    // If we have an existing note
    if (existingNote != null) {
      return existingNote;
    }
    // Otherwise, create a note
    else {
      // Get the current logged in user, only if user is logged in
      final currentUser = AuthService.firebase().currentUser!;
      final email = currentUser.email!;
      // Get the user with the current email, that is stored in the db
      final owner = await _notesService.getUser(email: email);
      // Create a note for that user
      final newNote = await _notesService.createNote(owner: owner);
      // Set the note to the newly created note
      _note = newNote;
      return newNote;
    }
  }

  // Don't save empty text note
  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      await _notesService.deleteNote(id: note.id);
    }
  }

  // Auto save non empty notes
  void _saveNotIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textEditingController.text;
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNotIfTextIsNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        backgroundColor: Colors.blue[100],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // Start listening to the text changes on UI
              _setupTextContollerListener();
              return TextField(
                // Use the Contoller to store the text
                controller: _textEditingController,
                // To make the text multi line
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Write your new note here...",
                ),
                // expands: true,
              );
            default:
              return const Loading();
          }
        },
      ),
    );
  }
}
