/// ------------------------------------------------------------
/// Filter Extension on Stream<List<T>>
/// ------------------------------------------------------------
///
/// Adds a helper method to filter elements inside a streamed list.
///
/// Useful when working with:
///   Stream<List<Model>>
///
/// Instead of manually mapping every time:
///   stream.map((list) => list.where(...).toList())
///
/// You can simply use:
///   stream.filter(...)
///
/// Benefits:
/// - Cleaner syntax
/// - Reusable logic
/// - Keeps UI code readable
///
/// Example:
/// notesStream.filter((note) => note.userId == currentUser.id)
///
/// This is heavily used by NotesService to:
/// 👉 return only notes belonging to the logged-in user
///
library;

// Targeted by Stream<List<T>> where T is any type
// e.g., Stream<List<DatabaseNote>>
// Returns a stream that contains only the items that satisfy the given predicate - where
extension Filter<T> on Stream<List<T>> {
  /// Filters each emitted list using the provided predicate.
  ///
  /// Returns:
  /// - A new stream containing only matching elements
  Stream<List<T>> filter(bool Function(T) where) =>
      map((item) => item.where(where).toList());
}
