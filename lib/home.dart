import 'package:flutter/material.dart';
import 'package:my_notes_app/views/notes_view.dart';
import 'package:my_notes_app/views/login_view.dart';
import 'package:my_notes_app/views/register_view.dart';
import 'package:my_notes_app/views/verify_email_view.dart';
import 'package:my_notes_app/constants/loading.dart';

import 'package:my_notes_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser?.emailVerified;

    // BuildContext context can be used to pass information form current Widget to another of its child Widget
    // The widget for specifying each page / screen of app
    // Has variuos part -
    // 1. Appbar - The top bar
    // 2. Body - for main content
    // 3. etc.
    return FutureBuilder(
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
            // Get the current user from Firebase Auth object
            final user = FirebaseAuth.instance.currentUser;
            // print(user);

            // If user exists
            if (user != null) {
              // If the user's email is verified - go to notes view
              if (user.emailVerified) {
                return const NotesView();
              }
              // If the user's email is not verified
              else {
                return const VerifyEmailView();
              }
            }
            // If user does not exist
            else {
              return const LoginView();
            }

          default:
            return Loading();
          // Any other connection state
          // case ConnectionState.none:
          // case ConnectionState.waiting:
          // case ConnectionState.active:
        }
      },
    );
  }
}



/*
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   @override
//   Widget build(BuildContext context) {
// final user = Provider.of<User?>(context);

//     // Stream from Firebase for auth state changes
//     return StreamProvider<User?>.value(
//       value: FirebaseAuth.instance.authStateChanges(),
//       initialData: null,

//       child: Column(
//         children: [
//           ElevatedButton.icon(
//             onPressed: () {},
//             label: Text("Register as a new user"),
//             icon: Icon(Icons.person),
//           ),

//           SizedBox(height: 50.0),

//           ElevatedButton.icon(
//             onPressed: () {},
//             label: Text("Already a new user, LOGIN"),
//             icon: Icon(Icons.login),
//           ),
//         ],
//       ),
//     );
//   }
// }
*/