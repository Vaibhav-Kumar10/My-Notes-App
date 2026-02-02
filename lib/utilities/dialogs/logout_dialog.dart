/// Logout confirmation dialog.
///
/// Wraps [showGenericDialog] to provide a simple,
/// consistent confirmation dialog before logging out.
///
/// Returns:
/// - true  → user confirmed logout
/// - false → user cancelled or dismissed dialog
///
/// Purpose:
/// - Prevent accidental logouts
/// - Keep logout UX safe and predictable
///
/// This file exists as a small wrapper so:
/// - UI code stays clean
/// - Dialog text stays centralized
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
