/// Provides a unified interface for authentication operations.
///
/// This service acts as a facade over an [AuthProvider],
/// allowing the rest of the app to remain unaware of the
/// underlying authentication implementation.
///
library;

import 'package:my_notes_app/services/auth/auth_user.dart';
import 'package:my_notes_app/services/auth/auth_provider.dart';
import 'package:my_notes_app/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  /// The authentication provider currently in use.
  final AuthProvider provider;

  /// Creates an [AuthService] using the given authentication provider.
  const AuthService({required this.provider});

  /// Creates an [AuthService] using [FirebaseAuthProvider] as the
  /// underlying authentication implementation.
  factory AuthService.firebase() =>
      AuthService(provider: FirebaseAuthProvider());

  /// Initializes the underlying authentication provider.
  ///
  /// This delegates initialization to the currently used [AuthProvider]
  /// and should be called once during app startup.
  @override
  Future<void> initialize() => provider.initialize();

  /// Delegates user creation to the underlying provider.
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) => provider.createUser(email: email, password: password);

  /// Returns the currently authenticated user [AuthUser].
  @override
  AuthUser? get currentUser => provider.currentUser;

  /// Delegates login to the underlying provider.
  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);

  /// Delegates logout to the underlying provider.
  @override
  Future<void> logOut() => provider.logOut();

  /// Delegates email verification to the underlying provider.
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
