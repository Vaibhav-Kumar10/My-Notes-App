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

## 🧠 NotesService (`notes_service.dart`)

This is the **core service class** that manages all database operations.

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

## 🔄 Database Lifecycle

### `open()`

* Initializes the SQLite database
* Creates:

  * `user` table
  * `note` table
* Stores DB instance for global use

```text
Documents Directory
   ↓
notes.db
   ↓
user table
note table
```

**Possible Errors**

* `DatabaseAlreadyOpenException`
* `UnableToGetDocumentsDirectory`

---

### `close()`

* Closes the database safely
* Clears internal DB reference

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

### `createNote({required DatabaseUser owner})`

* Ensures the owner exists in DB
* Creates an empty note linked to user
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

---

### `updateNote({required DatabaseNote note, required String text})`

* Updates note content
* Marks note as **not synced with cloud**

**Throws**

* `CouldNotFindNote`
* `CouldNotUpdateNote`

---

### `deleteNote({required int id})`

* Deletes a specific note

**Throws**

* `CouldNotDeleteNote`

---

### `deleteAllNotes()`

* Deletes all notes
* Returns number of rows affected

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
UI
 ↓
NotesService
 ↓
SQLite (sqflite)
 ↓
notes.db (local storage)
```

---

## ✅ Design Highlights

* Explicit lifecycle management (`open` / `close`)
* Strongly typed models (`DatabaseUser`, `DatabaseNote`)
* Clear separation from UI & auth layers
* Predictable error handling via custom exceptions
* Ready for future cloud sync integration

---

## 📌 Intended Usage

This service is designed to:

* Work **offline-first**
* Be extended with cloud sync (Firebase / REST API)
* Act as a single source of truth for local notes
