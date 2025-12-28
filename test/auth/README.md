# 🔐 Authentication Service – Unit Tests

This directory contains **unit tests for the Authentication Service** of the `my_notes_app` Flutter project.  
The tests validate authentication behavior using a **Mock Authentication Provider**, ensuring correctness, safety, and predictable state handling without relying on external services (e.g., Firebase).

---

## 🎯 Purpose of These Tests

The goal of this test suite is to:

* Validate **authentication logic in isolation**
* Ensure **correct exception handling**
* Prevent **state leakage between tests**
* Mirror **real-world authentication behavior**
* Enable **CI/CD validation** for every commit

---

## 🧪 What Is Being Tested?

### 1️⃣ Initialization

* Provider starts **uninitialized**
* Initialization can be called **multiple times safely**
* Initialization completes within an expected time limit

### 2️⃣ Pre-Initialization Safety

* Login before initialization → ❌ Exception
* User creation before initialization → ❌ Exception
* Logout before initialization → ❌ Exception

### 3️⃣ User State Handling

* No user exists immediately after initialization
* User state is properly cleared after logout
* User state does not leak between tests

### 4️⃣ User Creation & Login

* `createUser()` correctly delegates to `logIn()`
* Proper exceptions are thrown for:

  * Invalid email
  * Duplicate email
  * Unknown user
  * Wrong password
  * Weak password
  * Empty email/password
* Successful user creation:

  * Sets `currentUser`
  * Email is **not verified by default**

### 5️⃣ Email Verification

* Cannot verify email when logged out
* Logged-in users can verify email
* Email verification is **idempotent** (safe to call multiple times)

### 6️⃣ Logout Behavior

* Logout clears the current user
* Logging out twice throws an exception
* User can log out and log in again successfully

---

## 🧩 Why Use a MockAuthProvider?

Using a mock provider allows us to:

* Avoid network calls
* Run tests **fast and deterministically**
* Simulate edge cases reliably
* Follow **clean architecture principles**
* Ensure tests remain stable in CI environments

---

## 🔄 Test Isolation Strategy

Each test runs with a **fresh provider instance**:

```dart
setUp(() {
  provider = MockAuthProvider();
});
```

### Benefits

* No shared state between tests
* Tests can run in **any order**
* Prevents flaky or dependent tests

---

## ▶️ Running the Tests

Run all auth tests:

```bash
flutter test test/auth
```

Run a specific test file:

```bash
flutter test test/auth/auth_test.dart
```

Run a single test by name:

```bash
flutter test test/auth/auth_test.dart --plain-name "Logged-in user can verify email"
```

---

## 🤖 CI/CD Compatibility

These tests are designed to:

* Run in **GitHub Actions**
* Fail builds on regressions
* Provide confidence before merging PRs
* Support future test coverage reporting

---

## 🏆 Best Practices Followed

* ✔ Arrange–Act–Assert pattern
* ✔ Explicit exception testing
* ✔ No reliance on execution order
* ✔ Realistic auth behavior
* ✔ Clear, readable test descriptions

---

## 📁 Related Files

```
test/
└── auth/
    ├── auth_test.dart
    ├── mock_auth_provider.dart
    └── README.md
```

---

## 📌 Notes

* Email verification is **explicit**, not automatic
* Logout is only allowed when a user is logged in
* Provider behavior mirrors real authentication systems (e.g., Firebase)

---

## 🚀 Future Improvements

* Add code coverage reporting
* Parameterize repeated test cases
* Extend tests for password reset flow
* Integrate with full app authentication flow tests
