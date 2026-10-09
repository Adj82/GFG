import '../models/json.dart';

/// Collection names. With Firestore these become sub-collections of
/// `orgs/{orgId}/…` (see BACKEND.md), which keeps every society isolated.
abstract final class Collections {
  static const organization = 'organization';
  static const domains = 'domains';
  static const roles = 'roles';
  static const members = 'members';
  static const applications = 'applications';
  static const tasks = 'tasks';
  static const events = 'events';
  static const attendance = 'attendance';
  static const announcements = 'announcements';
  static const expenses = 'expenses';
  static const income = 'income';
  static const meetings = 'meetings';
  static const vault = 'vault';
  static const comments = 'comments';
  static const notices = 'notices';
  static const audit = 'audit';
  static const registrations = 'registrations';

  /// Local-only: stands in for Firebase Auth. Not created in Firestore.
  static const credentials = 'credentials';

  static const all = [
    organization,
    domains,
    roles,
    members,
    applications,
    tasks,
    events,
    attendance,
    announcements,
    expenses,
    income,
    meetings,
    vault,
    comments,
    notices,
    audit,
    registrations,
    credentials,
  ];
}

/// The only contract the app depends on for data.
///
/// Today it is implemented by `LocalRepository` (device storage). The backend
/// phase adds a `FirestoreRepository<T>` with the same five methods and swaps
/// it in `data/providers.dart` — no screen changes.
abstract interface class Repository<T extends Entity> {
  /// Live list of every record in the collection.
  Stream<List<T>> watchAll();

  /// Last value seen by [watchAll], if any. Lets the first frame render
  /// without a loading flash.
  List<T>? get cached;

  Future<List<T>> fetchAll();

  Future<T?> fetch(String id);

  Future<void> save(T item);

  Future<void> saveAll(Iterable<T> items);

  Future<void> delete(String id);
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Mirrors the parts of Firebase Auth the app uses.
abstract interface class AuthRepository {
  /// Signed-in user id, or null.
  String? get currentUserId;

  Stream<String?> watchUserId();

  Future<String> signIn({required String email, required String password});

  /// Self sign-up (members joining via a join request).
  Future<String> signUp({required String email, required String password});

  /// Creates an account for someone else with a temporary password
  /// (President adding core team / leads, doc §4).
  /// Backend: a callable Cloud Function using the Admin SDK, so the
  /// President's own session is not replaced.
  Future<String> createAccount({
    required String email,
    required String temporaryPassword,
  });

  Future<void> changePassword({required String newPassword});

  /// Backend: `sendPasswordResetEmail`. Locally this only validates the email.
  Future<void> requestPasswordReset({required String email});

  Future<void> signOut();
}
