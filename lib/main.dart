import 'package:flutter/material.dart';
import 'package:my_notes_app/views/login_view.dart';
import 'package:my_notes_app/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // The widget for making app
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My  Notes App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginView(),
    ),
  );
}



// import 'package:my_notes_app/firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:my_notes_app/loading.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // Initialise the TextEditingController for email and password
//   late final TextEditingController _email;
//   late final TextEditingController _password;

//   @override
//   void initState() {
//     super.initState();
//     // Create the TextEditingController objects when the Widget is initialised
//     _email = TextEditingController();
//     _password = TextEditingController();
//     print("TextEditingController initialized");
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     // Dispose the TextEditingController objects when the Widget is closed
//     _email.dispose();
//     _password.dispose();
//     print("TextEditingController disposed");
//   }

//   @override
//   Widget build(BuildContext context) {
//     // The widget for specifying each page / screen of app
//     // Has variuos part -
//     // 1. Appbar - The top bar
//     // 2. Body - for main content
//     // 3. etc.
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Register"),
//         backgroundColor: Colors.blue[100],
//       ),

//       // Takes  and performs a Future, and once it returns a callback, produce a Widget depending on the state
//       body: FutureBuilder(
//         // Initialize the Firebase backend at starting
//         // Initializes a new [FirebaseApp] instance by [name] and [options] and returns the created app. This method should be called before any usage of FlutterFire plugins.
//         future: Firebase.initializeApp(
//           options: DefaultFirebaseOptions.currentPlatform,
//         ),
//         builder: (context, snapshot) {
//           // Now until the Future completes, a Loading State should be shown,

//           switch (snapshot.connectionState) {
//             // When the state is done
//             case ConnectionState.done:
//               print("Future success");

//               return Column(
//                 children: [
//                   TextField(
//                     // Specify that the input type is email address
//                     keyboardType: TextInputType.emailAddress,

//                     // Disable sugesstions and autocorrect while typing
//                     enableSuggestions: false,
//                     autocorrect: false,

//                     // Specify the TextEditingController for password
//                     controller: _email,

//                     // Show hint to user
//                     decoration: InputDecoration(
//                       hintText: "Enter your email here",
//                     ),
//                   ),

//                   TextField(
//                     // Hide the input as it is password
//                     obscureText: true,

//                     // Disable sugesstions and autocorrect while typing
//                     enableSuggestions: false,
//                     autocorrect: false,

//                     // Specify the TextInputController for password
//                     controller: _password,

//                     // Show hint to user
//                     decoration: InputDecoration(
//                       hintText: "Enter your password here",
//                     ),
//                   ),

//                   // Button to register and send request to Firebase Authentication
//                   TextButton(
//                     child: Text("Register"),

//                     onPressed: () async {
//                       // Store the contents from the TextEditingController objects
//                       final email = _email.text;
//                       final password = _password.text;

//                       // Create an instance of firebase auth object to communicate with firebase auth
//                       final FirebaseAuth _auth = FirebaseAuth.instance;

//                       // Calls the Future function to create user with email and password and returns a UserCredential object
//                       final UserCredential userCredential = await _auth
//                           .createUserWithEmailAndPassword(
//                             email: email,
//                             password: password,
//                           );

//                       print(userCredential);
//                     },
//                   ),
//                 ],
//               );

//             // Any other connection state
//             // case ConnectionState.none:
//             // case ConnectionState.waiting:
//             // case ConnectionState.active:
//             default:
//               print("Loading");
//               return Loading();
//           }
//         },
//       ),
//     );
//   }
// }
