import 'package:flutter/material.dart';
import 'package:my_notes_app/home.dart';
import 'package:my_notes_app/constants/routes.dart';
import 'package:my_notes_app/views/login_view.dart';
import 'package:my_notes_app/views/notes_view.dart';
import 'package:my_notes_app/views/register_view.dart';
import 'package:my_notes_app/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Firebase backend at starting
  // Initializes a new [FirebaseApp] instance by [name] and [o ptions] and returns the created app. This method should be called before any usage of FlutterFire plugins.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

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
      // home: VerifyEmailView(),
      home: HomePage(),
      // initialRoute: '/login',
      routes: {
        loginRoute: (context) => LoginView(),
        registerRoute: (context) => RegisterView(),
        notesRoute: (context) => NotesView(),
        verifyEmailRoute: (context) => VerifyEmailView(),
      },
    );
  }
}

/*
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
              /*
              // Get the current user from Firebase Auth object
              final User? user = FirebaseAuth.instance.currentUser;
              print(user);
              // If the user's email is verified
              if (user?.emailVerified ?? false) {
                print("You are a verified user");
                return Text("Verified");
              }
              // If the user's email is not verified
              else {
                print("You need to verify your email first");
                // return const LoginView();
                return const VerifyEmailView();
              }
              */
              return const LoginView();
            // return Text("Done");

            // Any other connection state
            // case ConnectionState.none:
            // case ConnectionState.waiting:
            // case ConnectionState.active:
            default:
              print("Loading");
              return Loading();
            // return Text("Loading");
          }
        },
      ),
    );
  }
}
*/

/*
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
              if (user?.emailVerified ?? false) {
                print("You are a verified user");
                return Text("Verified");
              }
              // If the user's email is not verified
              else {
                print("You need to verify your email first");
                // Builds the Home first, then navigation happens
                // WidgetsBinding.instance.addPostFrameCallback((_) {
                // Push a new Widget page on the top of the current context screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // Pass current context to the builder of the Navigator
                    builder: (context) => const VerifyEmailView(),
                  ),
                );
                // });
                print("Went to verified and returned");
                return Text("Went to verified and returned");
                // return const LoginView();
                // return const VerifyEmailView();
              }

            // return const LoginView();
            // return Text("Done");

            // Any other connection state
            // case ConnectionState.none:
            // case ConnectionState.waiting:
            // case ConnectionState.active:
            default:
              print("Loading");
              return Loading();
            // return Text("Loading");
          }
        },
      ),
    );
  }
}

*/


/*

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Waits for a stream to be received, and once it returns a callback, produce a Widget depending on the state
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       // Builder function is called when the stream is reached
//       builder: (context, snapshot) {
//         // Now until the Future completes, a Loading State should be shown,
//         if (snapshot.connectionState != ConnectionState.done) {
//           // Any other connection state
//           // ConnectionState.none:
//           // ConnectionState.waiting:
//           // ConnectionState.active:
//           print("Loading");
//           // return Loading();
//         }
//         // When the state is done
//         else {
//           print("Stream success");

//           // Get the current user from snapshot
//           final User? user = snapshot.data;
//           print(user);

//           if (user == null) {
//             print("No user");
//             return LoginView();
//           }

//           // // If the user's email is verified
//           // if (user!.emailVerified) {
//           //   print("You are a verified user");
//           // }

//           // If the user is logeged in but email is not verified
//           if (user.emailVerified == false) {
//             print("You need to verify your email first");
//             return const VerifyEmailView();
//           }
//         }
//         return HomePage();
//         return Text("Done");
//         // return Text("Loading");
//       },
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Home"), backgroundColor: Colors.blue[100]),
//       body: Text("Home"),
//     );
//   }
// }
*/


// IF above not works
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // BuildContext context can be used to pass information form current Widget to another of its child Widget

//     // Get the current user from Firebase Auth object
//     final user = FirebaseAuth.instance.currentUser;
//     print(user);

//     // If the user's email is verified
//     if (user!.emailVerified) {
//       print("You are a verified user");
//     }
//     // If the user's email is not verified
//     else {
//       print("You need to verify your email first");

//       // Builds the Home first, then navigation happens
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         // Push a new Widget page on the top of the current context screen
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             // Pass current context to the builder of the Navigator
//             builder: (context) => const VerifyEmailView(),
//           ),
//         );
//       });
//     }

//     // The widget for specifying each page / screen of app
//     // Has variuos part -
//     // 1. Appbar - The top bar
//     // 2. Body - for main content
//     // 3. etc.
//     return Scaffold(
//       appBar: AppBar(title: Text("Home"), backgroundColor: Colors.blue[100]),
//       body: Text("Done"),
//     );
//   }
// }
