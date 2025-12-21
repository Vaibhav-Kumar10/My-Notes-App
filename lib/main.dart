import 'package:flutter/material.dart';
import 'package:my_notes_app/home.dart';
import 'package:my_notes_app/views/login_view.dart';
import 'package:my_notes_app/views/register_view.dart';

import 'package:my_notes_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_notes_app/loading.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // The widget for making app
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My  Notes App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // BuildContext context can be used to pass information form current Widget to another of its child Widget

    // The widget for specifying each page / screen of app
    // Has variuos part -
    // 1. Appbar - The top bar
    // 2. Body - for main content
    // 3. etc.
    return Scaffold(
      appBar: AppBar(title: Text("Home"), backgroundColor: Colors.blue[100]),

      // Takes  and performs a Future, and once it returns a callback, produce a Widget depending on the state
      body: FutureBuilder(
        // Initialize the Firebase backend at starting
        // Initializes a new [FirebaseApp] instance by [name] and [options] and returns the created app. This method should be called before any usage of FlutterFire plugins.
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),

        // Builder function is called when the Future finishes
        builder: (context, snapshot) {
          // Now until the Future completes, a Loading State should be shown,
          switch (snapshot.connectionState) {
            // When the state is done
            case ConnectionState.done:
              print("Future success");

              // Get the current user from Firebase Auth object
              final User? user = FirebaseAuth.instance.currentUser;
              print(user);

              // If the user's email is verified
              if (user!.emailVerified) {
                print("You are a verified user");
              }
              // If the user's email is not verified
              else {
                print("You need to verify your email first");

                // Builds the Home first, then navigation happens
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Push a new Widget page on the top of the current context screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // Pass current context to the builder of the Navigator
                      builder: (context) => const VerifyEmailView(),
                    ),
                  );
                });

                // return const Loading();
                // return const VerifyEmailView();
              }

              return Text("Done");

            // Any other connection state
            // case ConnectionState.none:
            // case ConnectionState.waiting:
            // case ConnectionState.active:
            default:
              print("Loading");
              return Text("Loading");
            // return Loading();
          }
        },
      ),
    );
  }
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Email")),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              // Get the current user from Firebase Auth object
              final User? user = FirebaseAuth.instance.currentUser;
              await user!.sendEmailVerification();
              print(user);
            },
            child: Text("Send Email Veification"),
          ),

          Text("Verify your email to continue"),
        ],
      ),
    );
  }
}
