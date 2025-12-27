/// Firebase implementation of the [AuthProvider].
///
/// This class communicates directly with Firebase Authentication
/// and converts Firebase-specific behavior and errors into
/// app-specific models and exceptions.
/// Due to this,
/// - Firebase logic is isolated
/// - No Firebase imports outside auth layer
/// - UI never sees Firebase error codes

import 'package:my_notes_app/services/auth/auth_user.dart';
import 'package:my_notes_app/services/auth/auth_provider.dart';
import 'package:my_notes_app/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider extends AuthProvider {
  // // Create an instance of firebase auth object to communicate with firebase auth
  // final _auth = FirebaseAuth.instance;

  /// Creates a new Firebase user using email and password.
  ///
  /// Converts Firebase exceptions into domain-specific auth exceptions.
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      // Calls the Future function to create user with email and password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the current user using getter defined below and return it
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    }
    // Catch only FirebaseAuthException exceptions
    on FirebaseAuthException catch (e) {
      // empty fields
      if (e.code == 'channel-error') {
        throw EmptyFieldsAuthException();
      }
      // invalid email
      else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      }
      // email already in use
      else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      }
      // weak password
      else if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      }
      // Any other error
      else {
        throw GenericAuthException();
      }
    }
    // Catch all other exceptions
    catch (e) {
      throw GenericAuthException();
    }
  }

  /// Returns the currently authenticated Firebase user
  /// as an [AuthUser], or null if no user is logged in.
  @override
  AuthUser? get currentUser {
    // Get the Firebase User and convert to AuthUser
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  /// Logs in an existing Firebase user.
  ///
  /// Throws custom auth exceptions based on Firebase error codes.
  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      // Calls the Future function to login with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the current user using getter defined above and return it
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    }
    // Catch only FirebaseAuthException exceptions
    on FirebaseAuthException catch (e) {
      // empty fields
      if (e.code == 'channel-error') {
        throw EmptyFieldsAuthException();
      }
      // invalid email
      else if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      }
      // weak password
      else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      }
      // Any other error
      else {
        throw GenericAuthException();
      }
    }
    // Catch all other exceptions
    catch (e) {
      throw GenericAuthException();
    }
  }

  /// Logs out the currently authenticated Firebase user.
  ///
  /// Throws [UserNotLoggedInAuthException] if no user is logged in.
  @override
  Future<void> logOut() async {
    // Get the current Firebase User and send request to firebase auth to signout if logged in otherwise, exception
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  /// Sends an email verification link to the current Firebase user.
  ///
  /// Throws [UserNotLoggedInAuthException] if no user is logged in.
  @override
  Future<void> sendEmailVerification() async {
    // Get the current Firebase User and send verification email if logged in otherwise, exception
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
