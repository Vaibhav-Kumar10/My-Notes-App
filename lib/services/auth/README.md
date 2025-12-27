# 🔐 Authentication Service – Clean Architecture (Flutter + Firebase)

This module provides a **clean, scalable, and provider-agnostic authentication system** for a Flutter application using **Firebase Authentication**.

The design follows **Clean Architecture principles**, separating concerns between:

* UI
* Authentication contract
* Provider implementation
* Domain models
* Error handling

---

## 📌 Key Design Goals

* ✅ **Decouple UI from Firebase**
* ✅ **Abstract authentication logic**
* ✅ **Use domain-specific exceptions**
* ✅ **Enable easy testing & mocking**
* ✅ **Allow future provider replacement**

---

## 🧱 Architecture Overview

```
UI Layer
   ↓
AuthService (Facade)
   ↓
AuthProvider (Contract / Interface)
   ↓
FirebaseAuthProvider (Implementation)
   ↓
Firebase Authentication SDK
```

---

## 📂 Folder Structure

```
lib/services/auth/
│
├── auth_exceptions.dart       # Custom domain-specific auth errors
├── auth_user.dart             # Lightweight immutable user model
├── auth_provider.dart         # Authentication contract (interface)
├── firebase_auth_provider.dart# Firebase implementation of AuthProvider
└── auth_service.dart          # Facade used by UI layer
```

---

## 🧠 Core Concepts

### 1️⃣ AuthProvider (Contract)

Defines **what authentication can do**, not how it is implemented.

```dart
abstract class AuthProvider {
  Future<AuthUser> createUser({required String email, required String password});
  AuthUser? get currentUser;
  Future<AuthUser> logIn({required String email, required String password});
  Future<void> logOut();
  Future<void> sendEmailVerification();
}
```

✔ Enables swapping Firebase with:

* Mock provider (testing)
* Supabase
* Custom backend

---

### 2️⃣ FirebaseAuthProvider (Implementation)

Concrete implementation of `AuthProvider` using Firebase Authentication.

Responsibilities:

* Communicate with Firebase SDK
* Convert Firebase errors → custom exceptions
* Convert Firebase `User` → `AuthUser`

✔ Firebase-specific logic stays isolated  
✔ UI never sees Firebase error codes

---

### 3️⃣ AuthUser (Domain Model)

A lightweight, immutable user model for the app.

```dart
@immutable
class AuthUser {
  final bool isEmailVerified;
}
```

✔ Prevents passing Firebase `User` across the app  
✔ Improves testability and stability

---

### 4️⃣ AuthService (Facade)

Acts as the **single entry point** for authentication in the app.

```dart
final authService = AuthService(
  provider: FirebaseAuthProvider(),
);
```

✔ UI interacts only with `AuthService`  
✔ Provider can be swapped without changing UI code

---

### 5️⃣ Custom Auth Exceptions

Firebase errors are mapped to **domain-specific exceptions**:

| Exception                        | Meaning                        |
| -------------------------------- | ------------------------------ |
| `UserNotFoundAuthException`      | User does not exist            |
| `WrongPasswordAuthException`     | Incorrect password             |
| `WeakPasswordAuthException`      | Password too weak              |
| `InvalidEmailAuthException`      | Invalid email format           |
| `EmailAlreadyInUseAuthException` | Email already registered       |
| `EmptyFieldsAuthException`       | Required fields missing        |
| `UserNotLoggedInAuthException`   | Action requires logged-in user |
| `GenericAuthException`           | Unknown error                  |

✔ UI handles meaningful exceptions instead of string codes  
✔ Cleaner error handling and messages

---

## 🧪 Testing & Mocking

Because the app depends on `AuthProvider`, you can easily mock authentication:

```dart
class MockAuthProvider implements AuthProvider {
  // Fake implementations for testing
}
```

✔ Enables unit tests without Firebase  
✔ Faster and more reliable tests

---

## 🚀 Usage Example

### Initialize Auth Service

```dart
final authService = AuthService(
  provider: FirebaseAuthProvider(),
);
```

### Register User

```dart
await authService.createUser(
  email: email,
  password: password,
);
```

### Login User

```dart
await authService.logIn(
  email: email,
  password: password,
);
```

### Check Email Verification

```dart
final user = authService.currentUser;
if (user?.isEmailVerified ?? false) {
  // proceed
}
```

### Logout

```dart
await authService.logOut();
```

---

## 🧩 Why This Architecture Matters

This design:

* Prevents tight coupling to Firebase
* Improves maintainability
* Simplifies error handling
* Scales to production-grade apps
* Reflects **industry-level architecture patterns**

> This approach is commonly used in **enterprise Flutter applications** and is highly valued in interviews and code reviews.

---

## 🔮 Future Improvements

* 🔄 Auth state stream (`Stream<AuthUser?>`)
* 🧪 Full mock provider for unit tests
* 🔐 Multi-provider support (Google, Apple)
* 🧠 Token refresh handling
* 📦 Dependency Injection (GetIt / Riverpod)

---

## 📄 License

This authentication service is part of a personal Flutter project and can be freely adapted or extended.
