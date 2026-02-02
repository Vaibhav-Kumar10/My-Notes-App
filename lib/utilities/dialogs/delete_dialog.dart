/// Delete confirmation dialog.
///
/// Used when a user attempts to delete a note.
///
/// Returns:
/// - true  → confirmed deletion
/// - false → cancelled
///
/// Purpose:
/// - Prevent accidental data loss
/// - Provide explicit confirmation step
///
/// Internally uses [showGenericDialog] for consistency.
///
library;

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
