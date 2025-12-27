/// Application entry point.
///
/// This file is responsible for:
/// - Ensuring Flutter bindings are initialized
/// - Bootstrapping the widget tree
/// - Defining global app configuration such as:
///   - Theme
///   - Routes
///   - Initial screen
///
/// No business logic should exist here.
library;

import 'package:flutter/material.dart';
import 'package:my_notes_app/home.dart';
import 'package:my_notes_app/constants/routes.dart';
import 'package:my_notes_app/views/login_view.dart';
import 'package:my_notes_app/views/notes_view.dart';
import 'package:my_notes_app/views/register_view.dart';
import 'package:my_notes_app/views/verify_email_view.dart';

/// Main function of the application.
///
/// Ensures Flutter engine is initialized before running the app.
/// This is required when performing asynchronous setup before `runApp`.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

/// Root widget of the application.
///
/// Configures:
/// - App theme
/// - Named routes
/// - Initial home widget
///
/// Acts as the top-level configuration container.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // The widget for making app
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My Notes App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      routes: {
        loginRoute: (context) => LoginView(),
        registerRoute: (context) => RegisterView(),
        notesRoute: (context) => NotesView(),
        verifyEmailRoute: (context) => VerifyEmailView(),
      },
    );
  }
}
