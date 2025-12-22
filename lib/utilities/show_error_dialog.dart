import 'package:flutter/material.dart';

// A generic function to show alers for errors that occur
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
              // Navigator.pop(context);
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}
