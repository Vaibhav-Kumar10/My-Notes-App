# 🗄️ Local CRUD Service (SQLite)

This module implements the **local persistence layer** of the app using **SQLite (`sqflite`)**.
It is responsible for **creating, reading, updating, and deleting users and notes**, fully independent of UI and authentication logic.

---

## 📂 Folder Structure

```
lib/services/crud/
├── crud_exceptions.dart     # Custom exceptions for database & CRUD failures
└── notes_service.dart      # SQLite service handling users & notes
```

---

## 🎯 Responsibilities

The CRUD service handles:

* Local SQLite database lifecycle
* User persistence (email-based)
* Note persistence (per-user)
* In-memory caching of notes
* Reactive updates to the UI
* Safe database access via controlled API
* Explicit error handling via custom exceptions

---

## 🧨 Custom Exceptions (`crud_exceptions.dart`)

All database-related errors are **explicitly modeled** using custom exception classes.

### 📁 Path & Platform

| Exception                       | Purpose                                         |
| ------------------------------- | ----------------------------------------------- |
| `UnableToGetDocumentsDirectory` | Thrown when the app cannot access local storage |

---

### 🗄️ Database State

| Exception                      | Purpose                                  |
| ------------------------------ | ---------------------------------------- |
| `DatabaseAlreadyOpenException` | Prevents opening multiple DB instances   |
| `DatabaseIsNotOpenException`   | Prevents DB access before initialization |

---

### 👤 User Errors

| Exception            | Purpose                 |
| -------------------- | ----------------------- |
| `UserAlreadyExists`  | Duplicate user creation |
| `CouldNotDeleteUser` | Failed user deletion    |
| `CouldNotFindUser`   | User not found          |

---

### 📝 Note Errors

| Exception            | Purpose              |
| -------------------- | -------------------- |
| `CouldNotDeleteNote` | Failed note deletion |
| `CouldNotFindNote`   | Note not found       |
| `CouldNotUpdateNote` | Note update failed   |

---

# 🆕 Architecture Update (Reactive + Cached)

The service now follows a **singleton + stream-based architecture**.

### Why?

To allow:

* Real-time UI updates
* Fewer database reads
* Better performance
* Centralized state management

---

## 🧠 NotesService (`notes_service.dart`)

This is the **core service class** that manages all database operations.

### 🔹 Singleton Pattern

```dart
static final NotesService _shared = NotesService._sharedInstance();
factory NotesService() => _shared;
```

Ensures:

* Only one database instance
* Single source of truth
* Shared cache across app

---

### 🔐 Database Access Control

```dart
Database? _db;
```

* Database instance is kept **private**
* Accessed only via `_getDatabaseOrThrow()`
* Guarantees **safe access** at runtime

```dart
Database _getDatabaseOrThrow()
```

* Throws `DatabaseIsNotOpenException` if DB is not initialized

---

# 🆕 In-Memory Cache

```dart
final List<DatabaseNote> _notes = [];
```

The service keeps notes **in memory** to:

* Avoid repeated DB reads
* Provide faster UI rendering
* Enable reactive streams

Cache is automatically updated after every:

* create
* update
* delete

---

# 🆕 Reactive Stream Support

```dart
Stream<List<DatabaseNote>> get allNotes
```

* Emits updated notes whenever data changes
* Used by `NotesListView` with `StreamBuilder`
* Enables automatic UI refresh

### Flow

```
DB change
  ↓
cache updated
  ↓
stream emits
  ↓
UI rebuilds automatically
```

This removes the need for manual refresh calls.

---

## 🔄 Database Lifecycle

### `open()`

* Initializes the SQLite database
* Creates:

  * `user` table
  * `note` table
* Stores DB instance for global use
* Loads notes into cache
* Starts stream updates

```text
Documents Directory
   ↓
notes.db
   ↓
user table
note table
cache
```

**Possible Errors**

* `DatabaseAlreadyOpenException`
* `UnableToGetDocumentsDirectory`

---

### `close()`

* Closes the database safely
* Clears internal DB reference
* Stops stream updates

**Possible Errors**

* `DatabaseIsNotOpenException`

---

## 👤 User Operations

### `createUser({required String email})`

* Creates a new user with a **unique email**
* Email is normalized using `toLowerCase()`

**Throws**

* `UserAlreadyExists`

---

### `getUser({required String email})`

* Fetches a user by email

**Throws**

* `CouldNotFindUser`

---

### `deleteUser({required String email})`

* Deletes exactly one user

**Throws**

* `CouldNotDeleteUser`

---

### 🧱 `DatabaseUser` Model

```dart
@immutable
class DatabaseUser
```

* Immutable value object
* Equality based on `id`
* Constructed from DB row

---

## 📝 Note Operations

All note operations:

✅ update database
✅ update cache
✅ emit new stream value

So UI always stays synchronized.

---

### `createNote({required DatabaseUser owner})`

* Ensures the owner exists in DB
* Creates an empty note linked to user
* Adds to cache
* Emits stream update
* Marks note as synced initially

**Throws**

* `CouldNotFindUser`

---

### `getNote({required int id})`

* Fetches a note by ID

**Throws**

* `CouldNotFindNote`

---

### `getAllNotes()`

* Returns all notes from the database
* Useful for listing notes per user
* Prefer `allNotes` stream for UI usage

---

### `updateNote({required DatabaseNote note, required String text})`

* Updates note content
* Marks note as **not synced with cloud**
* Updates cache
* Emits update

**Throws**

* `CouldNotFindNote`
* `CouldNotUpdateNote`

---

### `deleteNote({required int id})`

* Removes a specific note from DB
* Removes it from cache
* Emits update
**Throws**

* `CouldNotDeleteNote`

---

### `deleteAllNotes()`

* Deletes all notes
* Returns number of rows affected
* Clears DB + cache
* Emits empty list

---

### 🧱 `DatabaseNote` Model

```dart
class DatabaseNote
```

* Represents a single note row
* Tracks:
  * Owner (`userId`)
  * Text content
  * Cloud sync state
  * Equality based on `id`

---

## 🗃️ Database Schema

### User Table

```sql
CREATE TABLE user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE
);
```

---

### Note Table

```sql
CREATE TABLE note (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  text TEXT,
  is_synced_with_cloud INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES user(id)
);
```

---

## 🔄 Data Flow Overview

```
UI (StreamBuilder)
 ↓
NotesService (singleton)
 ↓
Cache (_notes)
 ↓
SQLite (sqflite)
 ↓
notes.db
```

---

## ✅ Design Highlights

* Singleton service
* Explicit lifecycle management (`open` / `close`)
* In-memory caching
* Reactive stream updates
* Strongly typed models (`DatabaseUser`, `DatabaseNote`)
* Clear separation from UI & auth layers
* Predictable error handling via custom exceptions
* Offline-first ready
* Ready for future cloud sync integration

---

## 📌 Intended Usage

This service is designed to:

* Work **offline-first**
* Provide **instant UI updates**
* Minimize DB reads
* Scale easily to cloud sync (Firebase / REST API)
* Act as a single source of truth for local notes
