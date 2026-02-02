# 🖥️ My Notes App – UI & Utilities

A simple **Flutter notes application** with:

* 🔐 Firebase Authentication (login/register/verify email)
* 🗄️ Local SQLite storage (offline-first)
* ⚡ Reactive UI with real-time updates
* 🧩 Clean separation of UI, Auth, and Data layers

---

## 📂 Folder Structure

```
├── main.dart                        # App entry point
├── home.dart                        # Home page deciding initial screen

├── utilities/
|   └── dialogs/
|       └── delete_dialog.dart 
|       └── error_dialog.dart 
|       └── generic_dialog.dart 
|       └── logout_dialog.dart

├── views/
│   ├── login_view.dart              # Login screen
│   ├── register_view.dart           # Registration screen
│   ├── verify_email_view.dart       # Email verification screen
|   └── notes/
│       ├── notes_view.dart          # Main notes screen
│       ├── notes_list_view.dart
│       └── create_update_note_view.dart

└── services/
    └── crud/
        ├── crud_exceptions.dart
        └── notes_service.dart
```

---

# 🖥️ UI Layer

Handles **all screens, navigation, and dialogs only**.
No database or auth logic lives here.

### Views

| View                  | Purpose                 |
| --------------------- | ----------------------- |
| LoginView             | Existing users login    |
| RegisterView          | New user registration   |
| VerifyEmailView       | Email verification flow |
| NotesView             | Main notes screen       |
| Create/UpdateNoteView | Edit notes              |
| NotesListView         | Displays notes list     |

---

## 🧩 Utilities

Reusable dialogs to keep UI code clean and avoid repeated `AlertDialog` boilerplate.

```
lib/utilities/dialogs/
├── generic_dialog.dart
├── error_dialog.dart
├── logout_dialog.dart
└── delete_dialog.dart
```

### Dialog Helpers

| File                | Purpose                                                |
| ------------------- | ------------------------------------------------------ |
| generic_dialog.dart | Base reusable dialog builder (buttons + return values) |
| error_dialog.dart   | Standard error popup with message + OK                 |
| logout_dialog.dart  | Logout confirmation dialog                             |
| delete_dialog.dart  | Delete confirmation dialog                             |

### Example

```dart
await showErrorDialog(context, "Something went wrong");

final shouldLogout = await showLogoutDialog(context);
```

---

## 🖥️ Views

### 1️⃣ `LoginView`

* Allows **existing users to log in**.
* Captures email and password using `TextEditingController`.
* Handles Firebase authentication errors and shows friendly messages.
* Redirects:

  * `NotesView` → if email verified
  * `VerifyEmailView` → if email not verified

---

### 2️⃣ `RegisterView`

* Allows **new users to create accounts**.
* Sends **email verification** automatically after registration.
* Handles registration errors with user-friendly alerts.
* Redirects:

  * `VerifyEmailView` → after successful registration

---

### 3️⃣ `VerifyEmailView`

* Displays instructions to **verify email**.
* Allows:

  * Resending verification email
  * Restarting authentication flow (log out and return to registration)
* Used only for users who are logged in but not verified.

---

### 4️⃣ `NotesView`

* Main application screen for authenticated & verified users.
* Provides **logout functionality** via popup menu.
* Uses `showLogOutDialog` to confirm logout before returning to login screen.

---

## 🏠 Home & Navigation

### `home.dart`

* Determines **initial screen** based on authentication state:

  * `NotesView` → authenticated & verified
  * `VerifyEmailView` → authenticated but not verified
  * `LoginView` → not logged in
* Uses **`FutureBuilder`** to await authentication initialization.

### `main.dart`

* Application entry point:

  * Initializes Flutter engine
  * Sets up theme and named routes
  * Boots the `HomePage`

---

## 🔐 Authentication Flow

```
App Start
   ↓
Auth initialize
   ↓
Logged in?
   ├─ No  → Login
   └─ Yes
        ├─ Verified → Notes
        └─ Not verified → Verify Email
```

Managed centrally in **home.dart**.

---

# 🗄️ Local CRUD Service (SQLite)

Provides **offline-first persistence** using `sqflite`.

Responsible for:

* Users
* Notes
* Database lifecycle
* Caching
* Reactive updates

---

## NotesService Highlights

### Singleton

Single shared instance across the app.

```dart
factory NotesService() => _shared;
```

---

### In-memory Cache

```dart
final List<DatabaseNote> _notes = [];
```

* Faster reads
* Fewer DB queries

---

### Reactive Stream

```dart
Stream<List<DatabaseNote>> get allNotes
```

* Emits updates automatically
* Used with `StreamBuilder`
* UI refreshes instantly

---

### CRUD

* createUser / getUser / deleteUser
* createNote / updateNote / deleteNote / deleteAllNotes
* clear custom exceptions for failures

---

### Schema

```sql
user(id, email UNIQUE)
note(id, user_id, text, is_synced_with_cloud)
```

---

# 🔄 Data Flow

```
UI
 ↓
NotesService (singleton)
 ↓
Cache
 ↓
SQLite
```

---

## 🔄 Error Handling

* Errors are shown via **`showErrorAlerts()`**, which centralizes error dialog UI.
* Keeps **UI consistent** and **simplifies code** in all views.

---

## ✅ Key Points

* UI is **completely decoupled** from authentication logic.
* Each screen has **clear responsibility**.
* Navigation is **controlled centrally** in `HomePage` and by view actions.
* Reusable utilities improve **code maintainability** and **user experience**.

---

## ✅ Design Principles

* Clean architecture
* UI ↔ Auth ↔ Database separation
* Offline-first
* Reactive updates
* Minimal boilerplate
* Easy to extend (cloud sync ready)
