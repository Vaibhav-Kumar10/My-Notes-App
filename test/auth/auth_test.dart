import 'package:test/test.dart';
import 'package:my_notes_app/services/auth/auth_exceptions.dart';
import 'mock_auth_provider.dart';

void main() {
  group('Mock Authentication', () {
    late MockAuthProvider provider;

    /// setUp() runs before every single test inside the group.
    /// Outcome -
    /// 1. Every test starts with a fresh, clean provider
    /// 2. No test shares state with another
    setUp(() {
      provider = MockAuthProvider();
    });

    /// ─────────────────────────────────────────────
    /// Initialization Tests
    /// ─────────────────────────────────────────────

    test('Should not be initialized initially.', () {
      expect(provider.isInitialized, false);
    });

    test('Initialize can be called multiple times safely.', () async {
      await provider.initialize();
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    // Test Timeouts
    // Fail if initialization takes more than 2 seconds
    test(
      'Initialization completes within 2 seconds.',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    /// ─────────────────────────────────────────────
    /// Pre-initialization safety checks
    /// ─────────────────────────────────────────────

    test('Cannot log in before initialization.', () {
      expect(
        () => provider.logIn(email: 'a', password: 'b'),
        // throwsA(isA<NotInitializedException>()),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Cannot create user before initialization.', () {
      expect(
        () => provider.createUser(email: 'a', password: 'b'),
        // throwsA(isA<NotInitializedException>()),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Cannot log out before initialization.', () {
      expect(
        provider.logOut(),
        // throwsA(isA<NotInitializedException>()),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    /// ─────────────────────────────────────────────
    /// User before creation and login
    /// ─────────────────────────────────────────────

    test("User should be null after initialization.", () {
      expect(provider.currentUser, null);
    });

    /// ─────────────────────────────────────────────
    /// User creation & login tests
    /// ─────────────────────────────────────────────

    test('Create user delegates to login & handles exceptions.', () async {
      await provider.initialize();

      expect(
        provider.createUser(email: 'galat.email@test.com', password: 'x'),
        throwsA(isA<InvalidEmailAuthException>()),
      );

      expect(
        provider.createUser(email: 'dobara.email@test.com', password: 'x'),
        throwsA(isA<EmailAlreadyInUseAuthException>()),
      );

      expect(
        provider.createUser(email: 'anjan.email@test.com', password: 'x'),
        throwsA(isA<UserNotFoundAuthException>()),
      );

      expect(
        provider.createUser(
          email: 'sahi.email@test.com',
          password: 'galat#password@123',
        ),
        throwsA(isA<WrongPasswordAuthException>()),
      );

      expect(
        provider.createUser(
          email: 'sahi.email@test.com',
          password: 'kamzor#password@111',
        ),
        throwsA(isA<WeakPasswordAuthException>()),
      );

      expect(
        provider.createUser(email: '', password: 'x'),
        throwsA(isA<EmptyFieldsAuthException>()),
      );

      expect(
        provider.createUser(email: 'x', password: ''),
        throwsA(isA<EmptyFieldsAuthException>()),
      );

      final user = await provider.createUser(
        email: 'sahi.email@test.com',
        password: 'koisa.bhi@password',
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    /// ─────────────────────────────────────────────
    /// Email verification tests
    /// ─────────────────────────────────────────────

    test('Cannot verify email when logged out.', () async {
      await provider.initialize();
      expect(
        () => provider.sendEmailVerification(),
        throwsA(isA<UserNotFoundAuthException>()),
      );
    });

    test('Logged-in user can verify email.', () async {
      await provider.initialize();
      await provider.createUser(
        email: 'sahi.email@test.com',
        password: 'koisa.bhi@password',
      );

      await provider.sendEmailVerification();

      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Email verification is idempotent.', () async {
      await provider.initialize();
      await provider.createUser(
        email: 'sahi.email@test.com',
        password: 'koisa.bhi@password',
      );

      await provider.sendEmailVerification();
      await provider.sendEmailVerification();

      expect(provider.currentUser!.isEmailVerified, true);
    });

    /// ─────────────────────────────────────────────
    /// Logout tests
    /// ─────────────────────────────────────────────

    test('Logout clears current user.', () async {
      await provider.initialize();
      await provider.createUser(
        email: 'sahi.email@test.com',
        password: 'koisa.bhi@password',
      );

      await provider.logOut();
      expect(provider.currentUser, null);
    });

    test('Cannot log out twice.', () async {
      await provider.initialize();
      await provider.createUser(
        email: 'sahi.email@test.com',
        password: 'koisa.bhi@password',
      );

      await provider.logOut();

      expect(
        () => provider.logOut(),
        throwsA(isA<UserNotFoundAuthException>()),
      );
    });

    test("Should be able to log out and login again.", () async {
      await provider.initialize();

      await provider.createUser(
        email: "sahi.email@test.com",
        password: "koisa.bhi@password",
      );

      await provider.logOut();

      await provider.logIn(
        email: "sahi.email@test.com",
        password: "koisa.bhi@password",
      );

      final user = provider.currentUser;
      expect(user, isNotNull);
    });

    /// ─────────────────────────────────────────────
    /// Older User creation & login tests
    /// ─────────────────────────────────────────────

    test("Create user should delegate to logIn function.", () async {
      await provider.initialize();

      // Testing different exceptions of Login
      // 1
      final invalidEmailUser = provider.createUser(
        email: "galat.email@test.com",
        password: "koisa.bhi@password",
      );
      expect(
        invalidEmailUser,
        throwsA(const TypeMatcher<InvalidEmailAuthException>()),
      );

      // 2
      final repeatEmailUser = provider.createUser(
        email: "dobara.email@test.com",
        password: "koisa.bhi@password",
      );
      expect(
        repeatEmailUser,
        throwsA(const TypeMatcher<EmailAlreadyInUseAuthException>()),
      );

      // 3
      final unKnownEmailUser = provider.createUser(
        email: "anjan.email@test.com",
        password: "koisa.bhi@password",
      );
      expect(
        unKnownEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      // 4
      final badPasswordUser = provider.createUser(
        email: "sahi.email@test.com",
        password: "galat#password@123",
      );
      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      // 5
      final weakPasswordUser = provider.createUser(
        email: "sahi.email@test.com",
        password: "kamzor#password@111",
      );
      expect(
        weakPasswordUser,
        throwsA(const TypeMatcher<WeakPasswordAuthException>()),
      );

      // 6
      final emptyPasswordUser = provider.createUser(
        email: "sahi.email@test.com",
        password: "",
      );
      expect(
        emptyPasswordUser,
        throwsA(const TypeMatcher<EmptyFieldsAuthException>()),
      );

      // 7
      final emptyEmailUser = provider.createUser(
        email: "",
        password: "koisa.bhi@password",
      );
      expect(
        emptyEmailUser,
        throwsA(const TypeMatcher<EmptyFieldsAuthException>()),
      );

      // Correct user creation
      final user = await provider.createUser(
        email: "sahi.email@test.com",
        password: "koisa.bhi@password",
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
  });
}
