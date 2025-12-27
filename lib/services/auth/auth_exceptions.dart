/// Defines all authentication-related exceptions used in the app.
///
/// These exceptions abstract away Firebase-specific error codes
/// and provide clean, domain-specific errors for the UI layer.
///
/// This ensures:
/// - UI does not depend on Firebase error strings
/// - Auth logic remains provider-agnostic
/// - Errors are easier to test and reason about
///
library;

// Login Exceptions
/// Thrown when a user with the given credentials is not found.
class UserNotFoundAuthException implements Exception {}

/// Thrown when the provided password is incorrect.
class WrongPasswordAuthException implements Exception {}

// Register Exceptions
/// Thrown when the password does not meet security requirements.
class WeakPasswordAuthException implements Exception {}

/// Thrown when the email address format is invalid.
class InvalidEmailAuthException implements Exception {}

/// Thrown when attempting to register with an email that already exists.
class EmailAlreadyInUseAuthException implements Exception {}

// Other exceptions - GENERIC Exceptions
/// Thrown for any authentication error that does not fit a known category.
class GenericAuthException implements Exception {}

/// Thrown when an operation requires a logged-in user but none exists.
class UserNotLoggedInAuthException implements Exception {}

/// Thrown when required input fields are empty.
class EmptyFieldsAuthException implements Exception {}
