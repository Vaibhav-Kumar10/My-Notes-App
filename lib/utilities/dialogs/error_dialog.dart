/// Utility function for displaying error dialogs.
///
/// This helper:
/// - Centralizes error dialog UI
/// - Keeps UI code clean and consistent
/// - Can be reused across multiple screens
///
/// Intended for displaying user-friendly error messages.
library;

import 'package:my_notes_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

/// Displays an alert dialog with the given error message.
///
/// Parameters:
/// - [context]: Build context used to show the dialog
/// - [errorText]: Message displayed to the user
///
/// The dialog is dismissible via an "OK" button.
Future<void> showErrorDialog(BuildContext context, String errorText) {
  return showGenericDialog(
    context: context,
    title: "An error occured",
    content: errorText,
    optionsBuilder: () => {'OK': null},
  );
}
