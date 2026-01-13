import 'package:flutter/material.dart';
import 'package:my_notes_app/constants/loading.dart';
import 'package:my_notes_app/services/auth/auth_service.dart';
import 'package:my_notes_app/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
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
  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    // If we have a note existing
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
      return await _notesService.createNote(owner: owner);
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
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
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
