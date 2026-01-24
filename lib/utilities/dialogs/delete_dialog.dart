import 'package:flutter/material.dart';
import 'package:my_notes_app/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Delete Note",
    content: "Are you sure you want to delete this note?",
    optionsBuilder: () => {"CANCEL": false, "YES": true},
  ).then((onValue) => onValue ?? false);
}
