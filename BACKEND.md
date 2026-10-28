# SocietyOS — backend hand-off

Sign-in is **Google only, limited to @kiit.ac.in**, and all member data lives in Firestore.
The Firebase code is written (`lib/data/firebase/`) and compiled, but it has **not been run
against a real project**: do the steps below and test on a phone before relying on it.
The app still runs on demo data unless you build with `--dart-define=USE_FIREBASE=true`.

## Go live, step by step

1. Create a Firebase project. Turn on **Authentication → Google**. Add your Android SHA-1 and the
   web domain under Authentication → Settings → Authorised domains.
2. Create **Firestore** (production mode) and deploy `firestore.rules`.
3. In this folder run `dart pub global activate flutterfire_cli`, then `flutterfire configure`.
   It overwrites `lib/firebase_options.dart` with your project's settings.
4. One-time data: `cd firebase && npm i firebase-admin`, point `GOOGLE_APPLICATION_CREDENTIALS`
   at a service-account key, then `node bootstrap.mjs president@kiit.ac.in "Full Name"`. It writes
   the organisation, 15 domains and 8 roles, and invites the first President.
5. Run with `flutter run --dart-define=USE_FIREBASE=true` (add the same flag to your release build,
   and set `kDemoMode = false` in `lib/app/app.dart`).
6. Sign in as that President. In **People → Add member** invite the other five core members and every
   domain lead by their kiit.ac.in email. Each one gets their role the first time they tap
   "Continue with Google". Everyone else taps Continue with Google, picks a domain, and waits for
   approval.

## Who can do what (enforced in `firestore.rules`, mirrored in `lib/domain/access.dart`)

- **Join requests** go to the domain lead and to all six core roles (`canReview`).
- **Suspend / restore**: the six core roles can suspend anyone but themselves (`suspendAnyone`);
  a domain lead can suspend only plain members of their own domain (`suspendMembers`). A suspended
  account loses all data access immediately and is sent to the "account suspended" screen.
- **Treasury and the all-domains overview**: the six core roles only.
- **Leads and core are added before they sign in** as invites (`invites/{email}`), claimed on first
  Google sign-in.

## Still to build before the public side works on Firebase

The member side is complete. These need **Cloud Functions** (not written yet) and the rules keep
them closed until then:

- `registerForEvent` / `cancelRegistration`: guest sign-ups (seat check in a transaction, App Check,
  rate limit). Until it exists, visitors cannot register on the Firebase build.
- A `publicEvents` mirror: a trigger copying events marked public (without budget, organisers or
  the check-in secret), so signed-out visitors can read the event list.
- Hardening, optional: move expense stage changes, attendance check-in and notification fan-out into
  callables. Today the rules only check *who* may write, and the app enforces the stage order.

## 1. The seam

| Interface (`lib/data/repositories/repository.dart`) | Local impl today | Firebase impl to write |
|---|---|---|
| `Repository<T>`: `watchAll`, `fetchAll`, `fetch`, `save`, `saveAll`, `delete` | `LocalRepository<T>` (JSON docs in shared_preferences) | `FirestoreRepository<T>` (written) |
| `AuthRepository`: `watchUserId`, `signInWithGoogle`, `signOut` (+ demo-only password methods) | `LocalAuthRepository` | `FirebaseAuthRepository` (written) |

Swap in `lib/data/providers.dart`: `_repo<T>(...)` builds a `LocalRepository` and
`authRepositoryProvider` builds `LocalAuthRepository`. Return the Firebase versions instead,
and delete the seeding in `main.dart`. Every model already has `toJson`/`fromJson`, and dates
are ISO strings, so they map 1:1 onto Firestore (use `Timestamp` converters in the repo if you
want server-side date queries).

```dart
class FirestoreRepository<T extends Entity> implements Repository<T> {
  FirestoreRepository(this._col, this._fromJson, this._toJson);
  final CollectionReference<Map<String, dynamic>> _col; // orgs/{orgId}/{collection}
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;

  @override Stream<List<T>> watchAll() =>
      _col.snapshots().map((s) => [for (final d in s.docs) _fromJson({...d.data(), 'id': d.id})]);
  @override Future<List<T>> fetchAll() async =>
      [for (final d in (await _col.get()).docs) _fromJson({...d.data(), 'id': d.id})];
  @override Future<T?> fetch(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? _fromJson({...d.data()!, 'id': d.id}) : null;
  }
  @override Future<void> save(T item) => _col.doc(item.id).set(_toJson(item));
  @override Future<void> saveAll(Iterable<T> items) async {
    final b = FirebaseFirestore.instance.batch();
    for (final i in items) { b.set(_col.doc(i.id), _toJson(i)); }
    await b.commit();
  }
  @override Future<void> delete(String id) => _col.doc(id).delete();
}
```

For large collections (tasks, attendance, comments) swap `watchAll` for scoped queries
(`where('domainId', whereIn: reachableDomains)`, recent-first, paged). `Repository` already
isolates this, so only the Firestore class changes.

## 2. Firestore layout

Everything is namespaced by `orgs/{orgId}` so multi-society (phase 2) is a data change, not a rewrite.

```
orgs/{orgId}/meta/org            name, term, recruitmentOpen, emailDomain
orgs/{orgId}/domains/{id}
orgs/{orgId}/roles/{id}          permissions[], scope, tier, rank
orgs/{orgId}/members/{uid}       roleId, status, domainId, department, history[]
orgs/{orgId}/applications/{id}
orgs/{orgId}/tasks/{id}
orgs/{orgId}/events/{id}         + events/{id}/private/secret  { checkInSecret }
orgs/{orgId}/publicEvents/{id}   read-only mirror of events with isPublic, safe fields only
orgs/{orgId}/registrations/{eventId_emailKey}   guest sign-ups, written by a function only
orgs/{orgId}/attendance/{eventId_memberId}
orgs/{orgId}/announcements/{id}
orgs/{orgId}/meetings/{id}
orgs/{orgId}/expenses/{id}       history[] is append-only
orgs/{orgId}/income/{id}
orgs/{orgId}/vault/{id}          files live in Storage: orgs/{orgId}/vault/{id}/{name}
orgs/{orgId}/comments/{id}
orgs/{orgId}/notices/{id}
orgs/{orgId}/audit/{id}
```

`firestore.rules` is already written against this layout and mirrors `Access` and `ExpenseRules`.
It also **fixes the old escalation hole**: members may only update a whitelist of profile fields,
so nobody can write their own `roleId`.

Indexes you will need: `tasks (domainId, status)`, `expenses (stage, domainId)`,
`attendance (targetId, memberId)`, `notices (recipientId, createdAt desc)`.

## 3. Cloud Functions (hardening; only the guest ones are required)

The current rules let the app write most things directly after checking *who* may. The table below is
what to move server-side. Required for the public side: `registerForEvent`, `cancelRegistration`,
`mirrorPublicEvent`. The rest is optional hardening.

Each one re-checks permission server-side with the same logic as `lib/domain`, then writes with the Admin SDK.

| Function | Replaces (Dart) | Notes |
|---|---|---|
| `acceptApplication`, `declineApplication` | `PeopleActions.accept/decline` | Checks `approveMembers` + reach. |
| `changeRole`, `setDisabled` | `PeopleActions.changeRole/setDisabled` | `Access.canManageMember`. Also revoke refresh tokens when disabling. |
| `submitExpense` | `FinanceActions.submit` | Computes the entry stage with `ExpenseRules.entryStage` from the caller's *server-side* role. |
| `decideExpense` | `FinanceActions.decide` | Port `canAct`, `highestStageFor`, `stageAfterApproval`. Must be a transaction. Self-approval is rejected. |
| `markReimbursed`, `logIncome` | `FinanceActions` | Needs `reimburse` / `logIncome`. |
| `checkIn` | `EventActions.checkIn` | Reads `events/{id}/private/secret`, verifies the HMAC (`CheckInCode.verify`, 30 s window), writes attendance. The secret never reaches a client except the host's screen via a callable. |
| `registerForEvent`, `cancelRegistration` | `GuestActions.register/cancel` | Callable that works **signed out** (use App Check and a rate limit). Re-runs `RegistrationRules.blockFor` inside a transaction so the last seat can't be double-booked; seats are `rsvpIds.length + registrations`. Id is the leader's `EventRegistration.idFor`. Team events carry `teamName` and `members[]`; the function re-runs `RegistrationRules.validateTeam` and `conflictFor` so nobody holds two places. For team events, seats count teams. |
| `mirrorPublicEvent` | `publicEventsProvider` | Firestore trigger: copies title, type, times, venue, description, capacity, outcome of events with `isPublic` into `publicEvents`. The visitor screens read only this collection, never `events`. |
| `startNewTerm` | `TermActions.startNewTerm` | One batch: history, roles, disable alumni, bump term. Requires `manageTerm`. |
| `onWrite` triggers | `ActionsBase.notify`, `audit` | Fan out `notices` and write `audit` from document changes, so they cannot be skipped or forged. Push via FCM. |

The Dart `notify`/`audit` helpers are commented as moving to functions; once the triggers exist,
make them no-ops.

## 4. Auth

- Email/password, restricted to `@kiit.ac.in` (`blockingFunctions` `beforeCreate`, plus the existing client check).
- Self sign-up creates `members/{uid}` with `status: pending`, `roleId: member`. A lead accepts it.
- Put `orgId` and `roleId` in custom claims for cheap rules checks if `get()` cost matters later.
- Password reset: `sendPasswordResetEmail`. `needsPasswordReset` drives the forced change screen.

## 5. Storage and files

Receipts and vault files: upload to Storage first, store the path in `receiptRef` / `fileRef`
(the action methods already take a ref, not bytes). Storage rules: read for active members,
write for the uploader to their own `expenses/{uid}/...` and for `manageVault` to `vault/...`.

## 6. Cut-over checklist

1. `flutterfire configure`, add `firebase_core`, `cloud_firestore`, `firebase_auth`, `cloud_functions`, `firebase_storage`.
2. Write `FirestoreRepository` and `FirebaseAuthRepository`, swap in `providers.dart`.
3. Deploy `firestore.rules`, indexes and the functions above. Test rules with the emulator using the roles in `default_roles.dart`.
4. Seed production once: org, domains, roles from `DefaultRoles.all`, and the first President (a script, not the app).
5. Set `kDemoMode = false` in `lib/app/app.dart`.
6. Port the unit tests in `test/` to run against the emulator for the function logic (same cases).

## 7. Phase 2 hooks already in place

- Everything is keyed to an org, so a second society is another `orgs/{id}` document tree.
- Roles and permissions are data (`Role`), editable per society without code changes.
- The college-wide layer needs only a read-only aggregate collection fed by functions; none of the society screens change.
