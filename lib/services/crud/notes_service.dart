/// Service responsible for handling all local CRUD operations
/// using SQLite.
///
/// This class manages:
/// - Database lifecycle (open / close)
/// - User creation and lookup
/// - Note creation, retrieval, update, and deletion
///
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:my_notes_app/services/crud/crud_exceptions.dart';

/// This service is UI-agnostic and can be reused
/// across the entire application.
class NotesService {
  // To make the class instance as Singleton
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  /// Internal reference to the SQLite database.
  ///
  /// This is kept private to ensure controlled access.
  Database? _db;

  // This is the local cache for our notes for current user
  List<DatabaseNote> _notes = [];

  // The interface used by UI to interact with backend
  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();
  // broadcast() - A controller where [stream] can be listened to more than once.

  // Returns a stream of StreamController
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  // Function to reads all notes available in db,
  // and cache them in the local db, as well as StreamController
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      // Get a user if exists
      final user = await getUser(email: email);
      return user;
    }
    // Otherwise create a user
    on CouldNotFindUser {
      final createdUser = await createUser(email: email);
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
      throw DatabaseAlreadyOpenException;
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
    } catch (e) {
      print(e);
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

  /// Creates a new empty note for the given user.
  ///
  /// Ensures that:
  /// - The user exists in the database
  /// - The provided user matches the stored user ID
  ///
  /// Throws:
  /// - [CouldNotFindUser]
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
        textColumn: 'text',
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

  /// Deletes a note by its unique ID.
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
    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

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

/// Representation of a note stored in the database.
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
