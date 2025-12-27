/// Utility function for displaying error dialogs.
///
/// This helper:
/// - Centralizes error dialog UI
/// - Keeps UI code clean and consistent
/// - Can be reused across multiple screens
///
/// Intended for displaying user-friendly error messages.

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
