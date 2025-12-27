
# 🖥️ My Notes App – UI & Utilities

This section of the project handles **all user-facing screens, navigation, and reusable UI utilities**.
It is designed to work **cleanly with the authentication service** and keeps UI logic separate from backend/auth logic.

---

## 📂 Folder Structure

```
lib/
├── utilities/
│   └── show_error_dialog.dart       # Generic error dialog utility
├── views/
│   ├── login_view.dart              # Login screen
│   ├── register_view.dart           # Registration screen
│   ├── verify_email_view.dart       # Email verification screen
│   └── notes_view.dart              # Main notes screen
├── home.dart                        # Home page deciding initial screen
└── main.dart                        # App entry point
```

---

## 🧩 Utilities

### `show_error_dialog.dart`

* Provides a **centralized, reusable error alert**.
* Keeps UI clean by avoiding repeated dialog boilerplate.
* Usage example:

```dart
await showErrorAlerts(context, "An error occurred");
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

## ⚡ Flow Overview

```
App Start
   ↓
HomePage → AuthService.firebase().initialize()
   ↓
[User Logged In?]
   ├─ Yes → [Email Verified?]
   │           ├─ Yes → NotesView
   │           └─ No → VerifyEmailView
   └─ No → LoginView
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
