/// ------------------------------------------------------------
/// NotesService (Local CRUD Service)
/// ------------------------------------------------------------
///
/// Central service responsible for:
///   • SQLite database lifecycle
///   • User management (User creation and lookup)
///   • Note CRUD operations (Note creation, retrieval, update, and deletion)
///   • Local caching
///   • Real-time streaming updates to UI
///
/// Architecture:
///   UI  →  NotesService  →  SQLite (sqflite)
///
/// Key Features:
/// ------------------------------------------------------------
/// - Singleton pattern (single DB instance)
/// - SQLite local persistence
/// - In-memory cache for fast reads
/// - Stream-based updates (reactive UI)
/// - User-scoped notes filtering
///
/// Flow:
/// ------------------------------------------------------------
/// Database → Cache → StreamController → UI widgets
///
/// Why caching?
/// - Avoids hitting DB repeatedly
/// - Faster rendering
/// - Real-time updates
///
/// Why StreamController?
/// - Automatically refresh UI when notes change
/// - Works perfectly with StreamBuilder
///
/// ------------------------------------------------------------
///
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_notes_app/extensions/list/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:my_notes_app/services/crud/crud_exceptions.dart';

/// This service is UI-agnostic and can be reused
/// across the entire application.
class NotesService {
  /// Internal reference to the SQLite database.
  ///
  /// This is kept private to ensure controlled access.
  Database? _db;

  /// In-memory cache of notes.
  ///
  /// Why?
  /// - Faster than querying SQLite every time
  /// - Allows instant UI updates
  /// - Works with StreamController
  // This is the local cache for our notes for current user
  List<DatabaseNote> _notes = [];

  /// Currently logged-in database user.
  ///
  /// Used to:
  /// - Scope notes per user
  /// - Filter streams
  /// - Ensure data isolation
  DatabaseUser? _user;

  /// ------------------------------------------------------------
  /// Singleton Implementation
  /// ------------------------------------------------------------
  ///
  /// Ensures only ONE database connection exists
  /// throughout the app lifecycle.
  ///
  /// Prevents:
  /// - multiple DB instances
  /// - resource leaks
  /// - inconsistent state
  /// ------------------------------------------------------------
  ///
  // To make the class instance as Singleton
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        // Update with the currently read notes
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  /// Broadcast stream controller used to push note updates.
  ///
  /// broadcast() allows:
  /// - multiple listeners
  /// - multiple StreamBuilders
  ///
  /// Every CRUD change updates this stream.
  ///

  // The interface used by UI to interact with backend
  late final StreamController<List<DatabaseNote>> _notesStreamController;
  // broadcast() - A controller where [stream] can be listened to more than once.

  /// Public stream exposed to UI.
  ///
  /// Returns only notes that belong to the current user.
  ///
  /// Internally:
  /// - listens to cache
  /// - filters using extension filter()
  /// - emits updates automatically
  ///
  // Returns a stream of StreamController
  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        // Only return all notes for the current user
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });
  // It doesn't get populated with default value, or with the value from new listeners
  // So initialize it later

  /// Loads all notes from database into memory cache.
  ///
  /// Steps:
  /// 1. Fetch from DB
  /// 2. Store locally
  /// 3. Push to stream
  ///
  /// Called when:
  /// - DB opens
  ///
  // Function to reads all notes available in db,
  // and cache them in the local db, as well as StreamController
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  /// Returns the existing user or creates a new one.
  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      // Get a user if exists
      final user = await getUser(email: email);
      // Set as current user if needed - only to extract all the notes of that user
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    }
    // Otherwise create a user
    on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      // Set as current user if needed - only to extract all the notes of that user
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Returns the active database instance if available.
  ///
  /// Throws:
  /// - [DatabaseIsNotOpenException] if the database
  ///   has not been initialized.
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  /// Ensures the database is open.
  ///
  Future<void> _ensureDbIsOpen() async {
    try {
      // Open database
      await open();
    } on DatabaseAlreadyOpenException {
      // Let it open
    }
  }

  /// Opens the SQLite database and initializes required tables.
  ///
  /// This method:
  /// - Resolves the platform documents directory
  /// - Creates (or opens) the database file
  /// - Creates the user and note tables if they do not exist
  ///
  /// Throws:
  /// - [DatabaseAlreadyOpenException]
  /// - [UnableToGetDocumentsDirectory]
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      // Get the path to application document directory
      final docsPath = await getApplicationDocumentsDirectory();
      // Create the path to database in application document directory
      final dbPath = join(docsPath.path, dbName);
      // Open db instance from that path
      final db = await openDatabase(dbPath);
      // Assign that instance from that path to our local database
      _db = db;

      // Create the user table
      await db.execute(createUserTable);
      // Create the note table
      await db.execute(createNoteTable);

      // cache notes
      await _cacheNotes();
    }
    // Throws a [MissingPlatformDirectoryException] if the system is unable to provide the directory.
    on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory;
    }
  }

  /// Closes the database connection safely.
  ///
  /// After calling this method, the database
  /// must be reopened before further operations.
  ///
  /// Throws:
  /// - [DatabaseIsNotOpenException]
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  /// Creates a new user with the given email address.
  ///
  /// Emails are normalized to lowercase to ensure uniqueness.
  ///
  /// Throws:
  /// - [UserAlreadyExists] if a user with the same email exists
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    } else {
      final userId = await db.insert(userTable, {
        emailColum: email.toLowerCase(),
      });
      return DatabaseUser(id: userId, email: email);
    }
  }

  /// Deletes a user identified by their email address.
  ///
  /// Exactly one row must be deleted for this operation
  /// to be considered successful.
  ///
  /// Throws:
  /// - [CouldNotDeleteUser]
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    // it should be 0 - if no such user exists, or 1 - if only 1 user exists and is deleted
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  /// Retrieves a user by email address.
  ///
  /// Throws:
  /// - [CouldNotFindUser] if no matching user exists
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  /// Creates a new empty note for the current user.
  ///
  /// After creation:
  /// - Saves to database
  /// - Adds to cache
  /// - Notifies stream listeners
  ///
  /// Ensures that:
  /// - The user exists in the database
  /// - The provided user matches the stored user ID
  ///
  /// Throws:
  /// - [CouldNotFindUser]
  ///
  /// UI updates instantly due to stream emission.
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    // Make sure that the owner exists in the database with correct ID

    // Check if the owner exists in database as a user
    final dbUser = await getUser(email: owner.email);
    // Checks if dbUser is not the owner
    if (dbUser != owner) {
      throw CouldNotFindUser();
    } else {
      const text = '';
      final noteID = await db.insert(noteTable, {
        userIdColumn: owner.id,
        textColumn: text,
        isSyncedWithCloudColumn: 1,
      });

      final note = DatabaseNote(
        id: noteID,
        userId: owner.id,
        text: text,
        isSyncedWithCloud: true,
      );

      // Update local cache db, and StreamContoller
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  /// Deletes note permanently by its unique ID.
  ///
  /// After deletion:
  /// - Removes from DB
  /// - Removes from cache
  /// - Pushes updated list to stream
  ///
  /// Throws:
  /// - [CouldNotDeleteNote] if no rows were deleted
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    // If no notes exists. Didn't used deletedCount != 1, as there can be many notes, for a single user
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      // Update local cache db, and StreamContoller
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  /// Deletes all notes from the database.
  ///
  /// Returns:
  /// - The number of rows affected.
  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final deletionCount = await db.delete(noteTable);

    // Update local cache db, and StreamContoller
    _notes = [];
    _notesStreamController.add(_notes);

    // Returns the number of rows affected.
    return deletionCount;
  }

  /// Retrieves a single note by its ID.
  ///
  /// Typically used when a user selects a note
  /// from the UI.
  ///
  /// Throws:
  /// - [CouldNotFindNote]
  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      // Get the latest note from database
      final note = DatabaseNote.fromRow(notes.first);

      // Update local cache db, and StreamContoller
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);

      // Return that note
      return note;
    }
  }

  /// Retrieves all notes stored in the database.
  ///
  /// Returns:
  /// - An iterable of [DatabaseNote] objects.
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  /// Updates the text content of an existing note.
  ///
  /// Marks the note as not synced with the cloud.
  ///
  /// After update:
  /// - Writes to DB
  /// - Refreshes cache
  /// - Emits updated notes to stream
  ///
  /// Throws:
  /// - [CouldNotFindNote]
  /// - [CouldNotUpdateNote]
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();

    // Make sure that the note exists
    await getNote(id: note.id);

    // Update database
    final updatesCount = await db.update(
      noteTable,
      {textColumn: text, isSyncedWithCloudColumn: 0},
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);

      // Update local cache db, and StreamContoller
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);

      return updatedNote;
    }
  }
}

/// Immutable representation of a user stored in the database.
/// Immutable ensures:
/// - safe usage
/// - no accidental mutation
/// - predictable behavior
@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});

  /// Creates a [DatabaseUser] instance from a database row.
  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColum] as String;

  // To return something when class object is printed
  @override
  String toString() => "Person, ID: $id, Email: $email";

  /// Users are considered equal if their IDs match.
  // To compare for equality of different DatabaseUser objects
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Model representing a single note.
///
/// Contains:
/// - id (primary key)
/// - owner user id
/// - text content
/// - sync status
class DatabaseNote {
  final int id;
  final int userId;
  final bool isSyncedWithCloud;
  final String text;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  /// Creates a [DatabaseNote] instance from a database row.
  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String,
      isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1
          ? true
          : false;

  // To return something when class object is printed
  @override
  String toString() =>
      "Note, ID: $id, UserId: $userId, IsSynceWithCloud: $isSyncedWithCloud";

  /// Notes are considered equal if their IDs match.
  // To compare for equality of different DatabaseNotes objects
  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Name of the SQLite database file.
const dbName = 'notes.db';

/// Table and column name constants used across queries.
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColum = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

/// SQL statement used to create the user table.
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL,
  "email"	TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id" AUTOINCREMENT)
  ); 
''';

/// SQL statement used to create the note table.
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
  "id"	INTEGER NOT NULL,
  "user_id"	INTEGER NOT NULL,
  "text"	TEXT,
  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY("id" AUTOINCREMENT),
  FOREIGN KEY("user_id") REFERENCES "user"("id")
  );
''';
