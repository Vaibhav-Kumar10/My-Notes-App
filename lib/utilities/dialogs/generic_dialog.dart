/// Generic reusable dialog builder used across the app.
///
/// This utility provides a flexible way to create dialogs
/// without rewriting AlertDialog boilerplate every time.
///
/// Core idea:
/// - Accepts a map of button titles → return values
/// - Dynamically builds buttons
/// - Pops the dialog with the selected value
///
/// Benefits:
/// - Centralized dialog UI
/// - Type-safe return values using generics <T>
/// - Reusable for confirmation, delete, logout, error dialogs, etc.
///
/// Example:
/// showGenericDialog<bool>(
///   context: context,
///   title: "Delete",
///   content: "Delete this item?",
///   optionsBuilder: () => {"Cancel": false, "Yes": true},
/// );
library;

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
