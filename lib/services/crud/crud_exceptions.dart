/// Custom exception thrown when the app is unable to access
/// the platform-specific documents directory.
///
/// This usually indicates a platform or permission issue.
class UnableToGetDocumentsDirectory implements Exception {}

/// Thrown when attempting to open the database
/// while it is already open.
///
/// Prevents multiple database instances from being created.
class DatabaseAlreadyOpenException implements Exception {}

/// Thrown when a database operation is attempted
/// before the database has been opened.
class DatabaseIsNotOpenException implements Exception {}

/// Thrown when attempting to create a user
/// that already exists in the database.
class UserAlreadyExists implements Exception {}

/// Thrown when a user deletion operation fails.
///
/// This usually means:
/// - The user does not exist
/// - More or fewer rows than expected were affected
class CouldNotDeleteUser implements Exception {}

/// Thrown when a requested user cannot be found
/// in the database.
class CouldNotFindUser implements Exception {}

/// Thrown when a note deletion operation fails.
///
/// This usually means the note does not exist.
class CouldNotDeleteNote implements Exception {}

/// Thrown when a requested note cannot be found
/// in the database.
class CouldNotFindNote implements Exception {}

/// Thrown when a note update operation fails.
///
/// This usually means no rows were updated.
class CouldNotUpdateNote implements Exception {}

/// Thrown when attempting to read all notes
/// without setting the user first.
class UserShouldBeSetBeforeReadingAllNotes implements Exception {}
