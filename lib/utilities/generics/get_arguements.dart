// Function to get arguements passed to a route
import 'package:flutter/material.dart';

extension GetArguement on BuildContext {
  T? getArguement<T>() {
    final modalRoute = ModalRoute.of(this);
    // If modal route exists
    if (modalRoute != null) {
      final arguement = modalRoute.settings.arguments;
      // If arguement exists and is of type T, return it
      if (arguement != null && arguement is T) {
        return arguement as T;
      }
    }
    return null;
  }
}

// final arg = ModalRoute.of(context).settings.arguments;
