import 'package:flutter/material.dart';
import 'package:my_notes_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_notes_app/loading.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Initialise the TextEditingController for email and password
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    // Create the TextEditingController objects when the Widget is initialised
    _email = TextEditingController();
    _password = TextEditingController();
    print("TextEditingController initialized");
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose the TextEditingController objects when the Widget is closed
    _email.dispose();
    _password.dispose();
    print("TextEditingController disposed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"), backgroundColor: Colors.blue[100]),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              // Specify that the input type is email address
              keyboardType: TextInputType.emailAddress,

              // Disable sugesstions and autocorrect while typing
              enableSuggestions: false,
              autocorrect: false,

              // Specify the TextEditingController for password
              controller: _email,

              // Show hint to user
              decoration: InputDecoration(hintText: "Enter your email here"),
            ),

            TextField(
              // Hide the input as it is password
              obscureText: true,

              // Disable sugesstions and autocorrect while typing
              enableSuggestions: false,
              autocorrect: false,

              // Specify the TextInputController for password
              controller: _password,

              // Show hint to user
              decoration: InputDecoration(hintText: "Enter your password here"),
            ),

            // Button to login and send request to Firebase Authentication
            ElevatedButton(
              child: Text("Login"),

              onPressed: () async {
                // Store the contents from the TextEditingController objects
                final email = _email.text;
                final password = _password.text;

                try {
                  // Create an instance of firebase auth object to communicate with firebase auth
                  final FirebaseAuth _auth = FirebaseAuth.instance;

                  // Calls the Future function to login with email and password and returns a UserCredential object
                  final UserCredential userCredential = await _auth
                      .signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                  print(userCredential);
                }
                // Catch only FirebaseAuthException exceptions
                on FirebaseAuthException catch (e) {
                  print("ERROR occured !!!");
                  // print(e.runtimeType);
                  // empty fields
                  if (e.code == 'channel-error') {
                    print("The fields are empty ---  channel-error !!");
                  }
                  // user not found
                  else if (e.code == 'user-not-found') {
                    print("The user doesn't exist --- user-not-found !!");
                  }
                  // wrong password
                  else if (e.code == 'wrong-password') {
                    print("Incorrect Password --- wrong-password !!");
                  }
                  print(e.code);
                  print(e);
                }
                // Catch all other exceptions
                catch (e) {
                  print("ERROR occured !!!");
                  print(e.runtimeType);
                  print(e);
                }
              },
            ),

            SizedBox(height: 30.0),

            TextButton(
              child: const Text("Not registered yet ? Register now"),
              onPressed: () {
                // Push the route with the given name onto the navigator, and then remove all the previous routes until the predicate returns true.
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/register', (route) => false);
              },
            ),

            ElevatedButton(child: Text("Register"), onPressed: () {}),

            TextButton.icon(
              label: Text("Register"),
              icon: Icon(Icons.login),
              onPressed: () {},
            ),

            ElevatedButton.icon(
              label: Text("Register"),
              icon: Icon(Icons.login),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}




// Old build with Scaffold

  /*
  @override
  Widget build(BuildContext context) {
    // The widget for specifying each page / screen of app
    // Has variuos part -
    // 1. Appbar - The top bar
    // 2. Body - for main content
    // 3. etc.
    return Scaffold(
      appBar: AppBar(title: Text("Login"), backgroundColor: Colors.blue[100]),

      // Takes  and performs a Future, and once it returns a callback, produce a Widget depending on the state
      body: FutureBuilder(
        // Initialize the Firebase backend at starting
        // Initializes a new [FirebaseApp] instance by [name] and [options] and returns the created app. This method should be called before any usage of FlutterFire plugins.
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          // Now until the Future completes, a Loading State should be shown,

          switch (snapshot.connectionState) {
            // When the state is done
            case ConnectionState.done:
              print("Future success");

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    TextField(
                      // Specify that the input type is email address
                      keyboardType: TextInputType.emailAddress,

                      // Disable sugesstions and autocorrect while typing
                      enableSuggestions: false,
                      autocorrect: false,

                      // Specify the TextEditingController for password
                      controller: _email,

                      // Show hint to user
                      decoration: InputDecoration(
                        hintText: "Enter your email here",
                      ),
                    ),

                    TextField(
                      // Hide the input as it is password
                      obscureText: true,

                      // Disable sugesstions and autocorrect while typing
                      enableSuggestions: false,
                      autocorrect: false,

                      // Specify the TextInputController for password
                      controller: _password,

                      // Show hint to user
                      decoration: InputDecoration(
                        hintText: "Enter your password here",
                      ),
                    ),

                    // Button to login and send request to Firebase Authentication
                    ElevatedButton(
                      child: Text("Login"),

                      onPressed: () async {
                        // Store the contents from the TextEditingController objects
                        final email = _email.text;
                        final password = _password.text;

                        try {
                          // Create an instance of firebase auth object to communicate with firebase auth
                          final FirebaseAuth _auth = FirebaseAuth.instance;

                          // Calls the Future function to login with email and password and returns a UserCredential object
                          final UserCredential userCredential = await _auth
                              .signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );

                          print(userCredential);
                        }
                        // Catch only FirebaseAuthException exceptions
                        on FirebaseAuthException catch (e) {
                          print("ERROR occured !!!");
                          // print(e.runtimeType);
                          // empty fields
                          if (e.code == 'channel-error') {
                            print("The fields are empty ---  channel-error !!");
                          }
                          // user not found
                          else if (e.code == 'user-not-found') {
                            print(
                              "The user doesn't exist --- user-not-found !!",
                            );
                          }
                          // wrong password
                          else if (e.code == 'wrong-password') {
                            print("Incorrect Password --- wrong-password !!");
                          }
                          print(e.code);
                          print(e);
                        }
                        // Catch all other exceptions
                        catch (e) {
                          print("ERROR occured !!!");
                          print(e.runtimeType);
                          print(e);
                        }
                      },
                    ),

                    SizedBox(height: 30.0),

                    Text("Not a user"),

                    ElevatedButton.icon(
                      label: Text("Register"),
                      icon: Icon(Icons.login),
                      onPressed: () {},
                    ),
                  ],
                ),
              );

            // Any other connection state
            // case ConnectionState.none:
            // case ConnectionState.waiting:
            // case ConnectionState.active:
            default:
              print("Loading");
              return Loading();
          }
        },
      ),
    );
  }
*/
 