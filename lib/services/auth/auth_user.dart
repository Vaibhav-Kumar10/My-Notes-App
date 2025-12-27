/// Represents a lightweight, immutable authentication user for the app.
///
/// This class acts as an abstraction over Firebase's [User] object,
/// exposing only the fields required by the application.
///
/// Benefits:
/// - Prevents tight coupling to Firebase
/// - Makes testing and mocking easier
/// - Ensures immutability and predictable state
///

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  /// Indicates whether the user's email has been verified.
  final bool isEmailVerified;
  const AuthUser({required this.isEmailVerified});

  /// Creates an [AuthUser] from a Firebase [User] instance.
  ///
  /// Copies only the required fields instead of exposing the full
  /// Firebase user object to the rest of the app.
  factory AuthUser.fromFirebase(User user) =>
      AuthUser(isEmailVerified: user.emailVerified);
  // Take the emailVerified property from Firebase's User, makes its copy and call the constructor of AuthUser
}

// Custom user for app, instead of entire firebase User
// Makes sure that the class and all its sub classes can never change their internals once initialized
// A class is immutable if all of the instance fields of the class, whether defined directly or inherited, are final.
