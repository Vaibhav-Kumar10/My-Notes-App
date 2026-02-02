/// ------------------------------------------------------------
/// GetArgument Extension
/// ------------------------------------------------------------
///
/// Provides a clean and type-safe way to extract arguments
/// passed through Flutter navigation routes.
///
/// Normally Flutter requires:
///   ModalRoute.of(context)?.settings.arguments
///
/// This extension simplifies it to:
///   context.getArgument<MyType>()
///
/// Benefits:
/// - Cleaner syntax
/// - Type-safe casting
/// - Avoids repetitive boilerplate
/// - Prevents unsafe casts
///
/// Returns:
/// - T  → if argument exists and matches type
/// - null → if no argument or wrong type
///
/// Example:
/// Navigator.pushNamed(
///   context,
///   '/edit-note',
///   arguments: myNote,
/// );
///
/// final note = context.getArgument<DatabaseNote>();
///
library;

import 'package:flutter/material.dart';

extension GetArguement on BuildContext {
  /// Returns the argument of type [T] passed to the current route.
  ///
  /// Safe behavior:
  /// - Checks if ModalRoute exists
  /// - Checks argument is non-null
  /// - Checks argument is of type T
  ///
  /// Prevents runtime cast exceptions.
  T? getArguement<T>() {
    final modalRoute = ModalRoute.of(this);

    // If modal route exists
    if (modalRoute != null) {
      final arguement = modalRoute.settings.arguments;

      // If argument exists and is of type T, return it
      if (arguement != null && arguement is T) {
        return arguement as T;
      }
    }

    // Otherwise return null safely
    return null;
  }
}
