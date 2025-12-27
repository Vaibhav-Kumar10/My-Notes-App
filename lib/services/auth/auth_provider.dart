/// Defines the authentication contract for the application.
///
/// Any authentication provider (Firebase, mock, custom backend)
/// must implement this interface.
///
/// This allows the app to remain independent of the actual
/// authentication implementation.
///
/// It defines:
/// - What authentication can do
/// - Not how it is done

import 'package:my_notes_app/services/auth/auth_user.dart';

abstract class AuthProvider {
  /// Creates a new user using email and password.
  ///
  /// Throws [AuthException] variants if creation fails.
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  /// Returns the currently authenticated user [AuthUser], or null if not logged in.
  AuthUser? get currentUser;

  /// Logs in an existing user using email and password.
  ///
  /// Returns an [AuthUser] on success or throws an auth exception.
  Future<AuthUser> logIn({required String email, required String password});

  /// Logs out the currently authenticated user.
  Future<void> logOut();

  /// Sends an email verification link to the current user.
  Future<void> sendEmailVerification();
}

// Just the blueprint of what all features need to be present in Child classes
// Encapsulates every provider that might be used
// Just the interface of what all things need to be present in other
