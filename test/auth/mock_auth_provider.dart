import 'package:my_notes_app/services/auth/auth_exceptions.dart';
import 'package:my_notes_app/services/auth/auth_provider.dart';
import 'package:my_notes_app/services/auth/auth_user.dart';

/// Thrown when auth methods are used before initialization
class NotInitializedException implements Exception {}

/// Mock implementation of AuthProvider for testing purposes
class MockAuthProvider implements AuthProvider {
  // Mock user variable to hold the current user
  AuthUser? _user;

  // MockAuthProvider must not be initialized before testing.
  // We will initialize it only when we want to test it.
  // This variable will help us track the initialization state.
  var _isInitialized = false;

  // Getter to return _isInitialized
  // This will help us check if the provider is initialized
  bool get isInitialized => _isInitialized;

  // Implementing createUser method
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  // Implementing currentUser getter
  @override
  AuthUser? get currentUser => _user;

  // Implementing initialize method
  @override
  Future<void> initialize() async {
    // Simulate some initialization delay
    await Future.delayed(const Duration(seconds: 1));
    // Set _isInitialized to true
    _isInitialized = true;
  }

  // Implementing logIn method
  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    // Check for initialization
    if (!isInitialized) throw NotInitializedException();
    // Testing different exceptions
    if (email == '' || password == '') throw EmptyFieldsAuthException();
    if (email == 'galat.email@test.com') throw InvalidEmailAuthException();
    if (email == 'dobara.email@test.com')
      throw EmailAlreadyInUseAuthException();
    if (email == 'anjan.email@test.com') throw UserNotFoundAuthException();
    if (password == 'galat#password@123') throw WrongPasswordAuthException();
    if (password == 'kamzor#password@111') throw WeakPasswordAuthException();

    // Creating a new user
    const user = AuthUser(isEmailVerified: false);
    // Setting the mock user
    _user = user;
    // Return the user
    return Future.value(user);
  }

  // Implementing logOut method
  @override
  Future<void> logOut() async {
    // Check for initialization
    if (!isInitialized) throw NotInitializedException();

    // Check for logged-in user
    if (_user == null) throw UserNotFoundAuthException();

    // Simulate logout delay
    await Future.delayed(const Duration(seconds: 1));
    // Set user to null to simulate logout
    _user = null;
  }

  // Implementing sendEmailVerification method
  @override
  Future<void> sendEmailVerification() async {
    // Check for initialization
    if (!isInitialized) throw NotInitializedException();

    // Check for logged-in user
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();

    // Simulate email verification delay
    await Future.delayed(const Duration(seconds: 1));

    // Update user to be email verified
    const newUser = AuthUser(isEmailVerified: true);
    // Set the updated user
    _user = newUser;
  }
}
