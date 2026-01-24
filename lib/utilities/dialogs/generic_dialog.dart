import 'package:flutter/material.dart';

// List of titles to be displayed for each button option
// Map of Title and its corresponding value, both combined in a function
// It is unique for each dialog, as a unique title, and unique values are needed
// Every string is unique .
// No 2 buttons with same title and Different values
typedef DialogOptionBuilder<T> = Map<String, T> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        // Create a button for each option
        actions: options.keys.map((optionTitle) {
          // Every key in options map is a button title
          // Map it to a list of TextButtons, with child as the title - optionTitle
          // Get the value corresponding to the title
          final T value = options[optionTitle];
          // Create a button with the title and value
          return TextButton(
            onPressed: () {
              // If value is not null, pop with value
              if (value != null) {
                Navigator.of(context).pop(value);
              }
              // Otherwise, just pop
              else {
                Navigator.of(context).pop();
              }
            },
            child: Text(optionTitle),
          );
        }).toList(),
      );
    },
  );
}
// List of options for dialog



/*
/// Shows a confirmation dialog before logging out.
///
/// Returns a `Future<bool>`:
/// - true if user confirms logout
/// - false if user cancels
///
/// Prevents accidental logouts and handles null returns if dialog is dismissed.
///
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
          // Cancel button returns false
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            label: Text("Cancel"),
            icon: Icon(Icons.cancel),
          ),

          // Log out button returns true
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            label: Text("Log Out"),
            icon: Icon(Icons.logout),
          ),
        ],
      );
    },
  ).then((onValue) => onValue ?? false);
  // Prevents null if dialog is dismissed
  // then - returns a value that is either returned from the showDialog or a default value, here false
  // Prevents null values that might be returned when user clicks on back navigation button or gesture or outside the dialog
}
*/

/*
/// Utility function for displaying error dialogs.
///
/// This helper:
/// - Centralizes error dialog UI
/// - Keeps UI code clean and consistent
/// - Can be reused across multiple screens
///
/// Intended for displaying user-friendly error messages.
library;

import 'package:flutter/material.dart';

/// Displays an alert dialog with the given error message.
///
/// Parameters:
/// - [context]: Build context used to show the dialog
/// - [errorText]: Message displayed to the user
///
/// The dialog is dismissible via an "OK" button.
Future<void> showErrorAlerts(BuildContext context, String errorText) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("An error occured"),
        content: Text(errorText),
        actions: [
          TextButton(
            onPressed: () {
              // Remove the current screen - Alert Screen
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}
*/