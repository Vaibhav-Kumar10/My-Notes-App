/// Shows a confirmation dialog before logging out.
///
/// Returns a `Future<bool>`:
/// - true if user confirms logout
/// - false if user cancels
///
/// Prevents accidental logouts and handles null returns if dialog is dismissed.
///
library;

import 'package:flutter/material.dart';
import 'package:my_notes_app/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Log Out",
    content: "Are you sure you want to log out ?",
    optionsBuilder: () => {"CANCEL": false, "LOG OUT": true},
  ).then((onValue) => onValue ?? false);
}

// Prevents null if dialog is dismissed
// then - returns a value that is either returned from the showGenericDialog or a default value, here false
// Prevents null values that might be returned when user clicks on back navigation button or gesture or outside the dialog
