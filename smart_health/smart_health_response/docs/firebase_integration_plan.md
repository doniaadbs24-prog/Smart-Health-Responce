# Firebase Integration Plan — Step 2

This document is the complete plan to wire **Firebase Auth** and **Cloud Firestore** (plus Cloud Storage and Cloud Messaging as supporting services) into the Smart Health Response Flutter app built in Step 1. It picks up where the in-memory mock services left off — the service layer interfaces stay the same, only their implementations swap from mock to real Firebase.

---

## 1. Goals

- Replace [lib/services/mock_data_service.dart](../lib/services/mock_data_service.dart), [auth_service.dart](../lib/services/auth_service.dart), [firestore_service.dart](../lib/services/firestore_service.dart), [storage_service.dart](../lib/services/storage_service.dart), and [notification_service.dart](../lib/services/notification_service.dart) with real Firebase implementations.
- Multi-device live flow works end-to-end: Reporter on Device A triggers SOS → nearby Responder on Device B receives FCM push → accepts → both watch live updates from Firestore streams → handover to Facility → close case → reporter rates.
- Enforce role-based access via Firestore Security Rules.
- Keep providers and screens unchanged — they consume the same service interfaces.

---

## 2. Prerequisites

| Item | Why |
|---|---|
| Google account | Required for Firebase Console access |
| Firebase project (Spark or Blaze plan) | Spark works for development. Blaze required for Cloud Functions and SMS-based phone auth in production. |
| Node.js ≥ 18 | Required by Firebase CLI and Functions runtime |
| `firebase-tools` (`npm install -g firebase-tools`) | CLI for deploying functions and rules |
| `flutterfire_cli` (`dart pub global activate flutterfire_cli`) | Generates `firebase_options.dart` |
| `gcloud` CLI (optional) | For advanced Firestore index management |
| Two physical devices or two emulators | To test cross-role flows live |

Firebase project setup (one-time):

1. **Create project** at console.firebase.google.com → name it `smart-health-response`.
2. **Enable Authentication providers**: Email/Password, Phone, Google (optional).
3. **Create Cloud Firestore** in *Native* mode, region `me-central2` (Riyadh) for Saudi-Arabia latency.
4. **Enable Cloud Storage** with default bucket `smart-health-response.appspot.com`.
5. **Enable Cloud Messaging** (no extra setup — required for FCM).
6. **Add Android app** with `applicationId` `com.shr.smart_health_response` → download `google-services.json` → place at `android/app/`.
7. **Add iOS app** with bundle id `com.shr.smartHealthResponse` → download `GoogleService-Info.plist` → place at `ios/Runner/`.
8. Run `flutterfire configure --project=smart-health-response` from the project root → it writes [lib/core/configuration/firebase_options.dart](../lib/core/configuration/firebase_options.dart).

---

## 3. Dependency Additions

Append to [pubspec.yaml](../pubspec.yaml):

```yaml
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.3
  firebase_storage: ^12.3.2
  firebase_messaging: ^15.1.3
  cloud_functions: ^5.1.3
```

Run `flutter pub get`.

Update [lib/main.dart](../lib/main.dart):

```dart
import 'package:firebase_core/firebase_core.dart';
import 'core/configuration/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([...]);
  runApp(const SmartHealthApp());
}
```

---

## 4. Firestore Data Model

Top-level collections match `FirestoreCollections` constants in [lib/core/constants/firestore_collections.dart](../lib/core/constants/firestore_collections.dart):

| Collection | Doc ID | Purpose | Key fields |
|---|---|---|---|
| `users` | Firebase Auth `uid` | Base user record for all roles | `userId`, `email`, `phoneNumber`, `fullName`, `userType`, `isActive`, `fcmToken`, `createdAt`, `updatedAt` |
| `reporters` | same as `userId` | Reporter-specific profile | `reporterId`, `userId`, `emergencyContacts[]`, `medicalProfile`, `address`, `emergencyAlertsSent`, `averageRating` |
| `responders` | same as `userId` | Responder-specific profile | `responderId`, `userId`, `certifications[]`, `isApproved`, `qualificationLevel`, `currentLocation` (GeoPoint), `isAvailable`, `averageRating`, `totalCasesResponded`, `responseTime`, `specializations[]` |
| `facilities` | auto-id | Hospital / clinic record | `facilityId`, `facilityName`, `facilityType`, `location` (GeoPoint), `address`, `contactNumber`, `capacity`, `currentPatientCount`, `specialties[]`, `equipmentList[]` |
| `cases` | auto-id | Emergency case lifecycle | `caseId`, `reporterId`, `responderId?`, `facilityId?`, `incidentLocation` (GeoPoint), `incidentType`, `caseStatus`, `description`, `attachments[]`, `createdAt`, `assignedAt?`, `completedAt?` |
| `cases/{caseId}/alerts` | auto-id | Sub-collection — one doc per responder alerted | `alertId`, `responderId`, `alertSentAt`, `acceptanceStatus`, `distance`, `rejectionReason?` |
| `cases/{caseId}/messages` | auto-id | Sub-collection — chat | `communicationId`, `senderId`, `senderType`, `recipientId`, `messageContent`, `attachments[]`, `sentAt`, `readAt?` |
| `cases/{caseId}/handover` | `single` | One-doc handover record | `handoverId`, `responderId`, `facilityId`, `vitalSigns`, `treatmentsProvided[]`, `receivingStaffName`, `confirmedAt?` |
| `cases/{caseId}/closure` | `single` | One-doc case closure report | `reportId`, `caseOutcome`, `finalNotes`, `caseDuration`, `distanceTraveled`, `responderRating?`, `reporterFeedback?` |
| `aeds` | auto-id | AED locations | `aedId`, `location` (GeoPoint), `facilityId?`, `address`, `isActive`, `lastServiceDate`, `nextServiceDate`, `accessInstructions` |
| `ratings` | auto-id | Service ratings | `ratingId`, `caseId`, `responderId`, `raterId`, `ratingScore`, `feedbackText`, `categories[]`, `ratedAt` |
| `notifications` | auto-id | In-app notification feed | `notificationId`, `userId`, `title`, `body`, `caseId?`, `type`, `isRead`, `createdAt` |
| `first_aid_guides` | `cpr`/`choking`/etc. | Editable first-aid content (admin-managed) | `guideId`, `guidanceType`, `title`, `description`, `steps[]`, `prerequisites[]`, `warnings[]`, `emergencyHotline` |
| `audit_logs` | auto-id | All sensitive actions | `logId`, `userId`, `actionType`, `resourceType`, `resourceId`, `changeDetails`, `timestamp`, `ipAddress?`, `status` |
| `system_config` | by `configKey` | Tunable parameters | `configKey`, `configValue`, `dataType`, `isActive`, `updatedAt` |

### Composite indexes to create

Firestore will prompt for these the first time the queries run, but pre-creating speeds up dev:

```
cases:            (caseStatus ASC, createdAt DESC)
cases:            (responderId ASC, caseStatus ASC, createdAt DESC)
cases:            (facilityId ASC, caseStatus ASC, createdAt DESC)
cases:            (reporterId ASC, createdAt DESC)
notifications:    (userId ASC, isRead ASC, createdAt DESC)
audit_logs:       (userId ASC, timestamp DESC)
ratings:          (responderId ASC, ratedAt DESC)
```

### Geohash field for nearby queries

Firestore can't natively do "responders within 5 km". The simplest approach: store a `geohash` string (5–6 char precision) on the responder document alongside `currentLocation`. Use the [`geoflutterfire_plus`](https://pub.dev/packages/geoflutterfire_plus) package to compute geohash queries.

Add to dependencies:

```yaml
  geoflutterfire_plus: ^0.0.30
```

`responders` doc gets two new fields: `geohash` (String) and `geopoint` (GeoPoint), updated whenever location changes.

---

## 5. Authentication

### Methods to enable
- **Email + password** — primary for desktop/Admin sign-in.
- **Phone (SMS OTP)** — primary for Reporter and Responder mobile sign-in (matches the app's UX of phone verification).
- Optional later: Google sign-in for one-tap.

### `auth_service.dart` rewrite

Replace [lib/services/auth_service.dart](../lib/services/auth_service.dart) — same public surface, real Firebase underneath:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';
import '../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../utils/helpers.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<UserModel?> authStateChanges() => _auth.authStateChanges().asyncMap((u) async {
    if (u == null) return null;
    final snap = await _db.collection('users').doc(u.uid).get();
    return snap.exists ? UserModel.fromJson(snap.data()!) : null;
  });

  UserModel? get currentUser => /* keep cached UserModel */;

  Future<UserModel> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _loadUserDoc(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), code: e.code);
    }
  }

  Future<UserModel> signUp({
    required String email, required String phone, required String fullName,
    required String password, required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = UserModel(
      userId: cred.user!.uid,
      email: email, phoneNumber: phone, fullName: fullName, userType: role,
      createdAt: DateTime.now(), updatedAt: DateTime.now(), lastLoginAt: DateTime.now(),
    );
    await _db.collection('users').doc(user.userId).set(user.toJson());
    // Role-specific sub-doc:
    if (role == UserRole.reporter) {
      await _db.collection('reporters').doc(user.userId).set({
        'reporterId': user.userId, 'userId': user.userId,
        'emergencyContacts': [], 'medicalProfile': {}, 'address': '',
        'emergencyAlertsSent': 0, 'averageRating': 0.0,
      });
    } else if (role == UserRole.responder) {
      await _db.collection('responders').doc(user.userId).set({
        'responderId': user.userId, 'userId': user.userId,
        'certifications': [], 'isApproved': false,
        'qualificationLevel': 'basic', 'isAvailable': false,
        'averageRating': 0.0, 'totalCasesResponded': 0, 'specializations': [],
      });
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<String> sendPhoneVerification(String phone) async {
    final completer = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (cred) => _auth.signInWithCredential(cred),
      verificationFailed: (e) => completer.completeError(AuthException(e.message ?? '')),
      codeSent: (verId, _) => completer.complete(verId),
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  Future<UserModel> verifyOtpAndSignIn(String verificationId, String code) async {
    final cred = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
    final result = await _auth.signInWithCredential(cred);
    return _loadUserDoc(result.user!.uid);
  }

  Future<UserModel> _loadUserDoc(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) throw AuthException('User profile not found');
    final user = UserModel.fromJson(snap.data()!);
    await _db.collection('users').doc(uid).update({'lastLoginAt': DateTime.now().toIso8601String()});
    return user;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No account with this email';
      case 'wrong-password': return 'Incorrect password';
      case 'email-already-in-use': return 'An account with this email exists';
      case 'invalid-email': return 'Invalid email address';
      case 'weak-password': return 'Password too weak';
      default: return e.message ?? 'Authentication failed';
    }
  }
}
```

### `AuthProvider` adjustments

[lib/providers/auth_provider.dart](../lib/providers/auth_provider.dart) needs to listen to `authStateChanges()` so a backgrounded sign-in (or token expiry) is reflected immediately:

```dart
StreamSubscription? _sub;
AuthProvider() {
  _sub = sl.auth.authStateChanges().listen((user) {
    _user = user;
    notifyListeners();
  });
}
@override void dispose() { _sub?.cancel(); super.dispose(); }
```

---

## 6. Firestore Service

Replace [lib/services/firestore_service.dart](../lib/services/firestore_service.dart) using `withConverter<T>` for type-safe reads/writes. Pattern for one collection:

```dart
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<EmergencyCase> get _casesRef =>
      _db.collection('cases').withConverter<EmergencyCase>(
        fromFirestore: (snap, _) => EmergencyCase.fromJson(snap.data()!..['caseId'] = snap.id),
        toFirestore: (c, _) => c.toJson()..remove('caseId'),
      );

  Future<void> addCase(EmergencyCase c) async {
    await _casesRef.doc(c.caseId.isEmpty ? null : c.caseId).set(c);
  }

  Future<void> updateCase(EmergencyCase c) =>
      _casesRef.doc(c.caseId).update(c.toJson());

  Stream<List<EmergencyCase>> watchCases({
    String? reporterId, String? responderId, String? facilityId,
  }) {
    Query<EmergencyCase> q = _casesRef;
    if (reporterId != null) q = q.where('reporterId', isEqualTo: reporterId);
    if (responderId != null) q = q.where('responderId', isEqualTo: responderId);
    if (facilityId != null) q = q.where('facilityId', isEqualTo: facilityId);
    return q.orderBy('createdAt', descending: true).snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }
}
```

> **Note on `GeoPoint`:** the project's [lib/core/configuration/geo_point.dart](../lib/core/configuration/geo_point.dart) is a custom value class. Add a converter in `toJson()`/`fromJson()` to translate to/from `cloud_firestore.GeoPoint` so Firestore stores it natively (allows future range queries).

### Provider changes — switch from polling to streams

Each provider currently calls `await sl.firestore.getCases(...)` once. Switch to `StreamSubscription` so Firestore listeners drive UI updates:

```dart
class ResponderProvider extends ChangeNotifier {
  StreamSubscription? _activeSub;
  StreamSubscription? _alertsSub;

  void watch(String responderId) {
    _activeSub = sl.firestore.watchCases(responderId: responderId).listen((list) {
      _activeCases = list.where((c) => c.caseStatus != CaseStatus.closed).toList();
      notifyListeners();
    });
    _alertsSub = sl.firestore.watchPendingAlerts(responderId).listen(...);
  }

  @override void dispose() {
    _activeSub?.cancel(); _alertsSub?.cancel();
    super.dispose();
  }
}
```

Apply this pattern to: `ReporterProvider`, `ResponderProvider`, `FacilityProvider`, `AdminProvider`, `CaseProvider`, `ChatProvider`, `NotificationProvider`.

---

## 7. Storage Service

Replace [lib/services/storage_service.dart](../lib/services/storage_service.dart):

```dart
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePhoto(String userId, File file) async {
    final ref = _storage.ref('users/$userId/profile.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadCertificate(String responderId, String certId, File file) async {
    final ref = _storage.ref('responders/$responderId/certs/$certId.pdf');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadAttachment(String caseId, String attachmentId, File file) async {
    final ext = file.path.split('.').last;
    final ref = _storage.ref('cases/$caseId/attachments/$attachmentId.$ext');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deleteAt(String fullPath) => _storage.ref(fullPath).delete();
}
```

Path layout enforced server-side by Storage rules (section 9).

---

## 8. Cloud Messaging (FCM)

Replace [lib/services/notification_service.dart](../lib/services/notification_service.dart):

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    await _local.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onBackgroundMessage(_onBackground);
  }

  Future<String?> getToken() => _fcm.getToken();

  Future<void> saveTokenForUser(String userId) async {
    final token = await _fcm.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(userId)
        .update({'fcmToken': token});
  }

  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) => _fcm.unsubscribeFromTopic(topic);

  void _onForeground(RemoteMessage msg) {
    _local.show(
      msg.hashCode,
      msg.notification?.title ?? 'Smart Health Response',
      msg.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails('shr_alerts', 'Emergency alerts',
            importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      payload: msg.data['caseId'],
    );
  }
}

@pragma('vm:entry-point')
Future<void> _onBackground(RemoteMessage msg) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Persist notification doc for in-app feed
}
```

Topic subscriptions to use:
- `responders_jazan` — broadcast alerts to all approved responders.
- `facility_{facilityId}` — incoming-case alerts for that hospital only.
- `admin_alerts` — system-level events to admin dashboard.

---

## 9. Cloud Functions (Backend Logic)

A `functions/` folder at project root, written in TypeScript. These run server-side and are triggered by Firestore events.

```
functions/
├── package.json
├── tsconfig.json
└── src/
    ├── index.ts             # exports all handlers
    ├── on_case_created.ts   # match nearby responders + send FCM
    ├── on_alert_response.ts # accept/reject side-effects
    ├── on_alert_expired.ts  # 60s timeout → expand radius
    ├── on_case_closed.ts    # recompute responder stats
    ├── scheduled_certs.ts   # daily cron: certification expiry
    └── lib/distance.ts      # haversine helper
```

### Key handlers

**`onCaseCreated`** — trigger: `cases/{caseId}` create.
1. Read `incidentLocation` from new case doc.
2. Query `responders` where `isAvailable == true` and `isApproved == true`, then filter client-side by Haversine distance ≤ 5 km.
3. For each responder, write `cases/{caseId}/alerts/{alertId}` with `acceptanceStatus = 'pending'`.
4. Send FCM data message to each responder's `fcmToken`:
   ```json
   { "data": { "caseId": "...", "incidentType": "...", "distance": "..." },
     "notification": { "title": "Emergency Alert", "body": "..." } }
   ```
5. Schedule `onAlertExpired` after 60 s.

**`onAlertResponse`** — trigger: `cases/{caseId}/alerts/{alertId}` update on `acceptanceStatus`.
- If `accepted`: set parent case `responderId`, `caseStatus = 'responder_assigned'`, `assignedAt = now`. Mark all other alerts for the case as `expired`. Send "Help is on the way" FCM to reporter.
- If `rejected`: leave alert as-is, no other side-effects.

**`onAlertExpired`** — scheduled. If after 60 s no alert is accepted, recompute responders within 10 km (expanded radius) and write fresh alert docs.

**`onCaseClosed`** — trigger: `cases/{caseId}` update on `caseStatus → closed`.
- Compute case duration, distance traveled.
- Write `cases/{caseId}/closure` doc.
- If a `ratings/{ratingId}` exists for this case, recompute `responders/{responderId}.averageRating` (running mean).
- Increment `responders/{responderId}.totalCasesResponded`.

**`scheduledCertificationCheck`** — scheduled cron `0 8 * * *` (daily 08:00 UTC).
- Find all `responders.certifications[*].expiryDate` within next 30 days.
- Send FCM "Your CPR certification expires in N days" to each.

Deploy with `firebase deploy --only functions`.

---

## 10. Security Rules

### Firestore — `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function signedIn() { return request.auth != null; }
    function isOwner(uid) { return request.auth.uid == uid; }
    function role() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType;
    }
    function isAdmin() { return signedIn() && role() == 'admin'; }
    function isResponder() { return signedIn() && role() == 'responder'; }
    function isFacility() { return signedIn() && role() == 'facility'; }
    function isReporter() { return signedIn() && role() == 'reporter'; }

    match /users/{uid} {
      allow read: if signedIn() && (isOwner(uid) || isAdmin());
      allow create: if signedIn() && isOwner(uid);
      allow update: if isOwner(uid) || isAdmin();
      allow delete: if isAdmin();
    }

    match /reporters/{uid} {
      allow read, write: if isOwner(uid) || isAdmin();
    }

    match /responders/{uid} {
      // Anyone signed-in can READ approved responders (Reporter sees responder profile during a case).
      allow read: if signedIn();
      // Only responder themselves can update most fields. Admin can flip `isApproved`.
      allow create: if isOwner(uid);
      allow update: if isOwner(uid) || isAdmin();
      allow delete: if isAdmin();
    }

    match /facilities/{facilityId} {
      allow read: if signedIn();
      allow write: if isAdmin();
    }

    match /cases/{caseId} {
      allow read: if signedIn() && (
        resource.data.reporterId == request.auth.uid ||
        resource.data.responderId == request.auth.uid ||
        resource.data.facilityId == request.auth.uid ||
        isAdmin()
      );
      allow create: if isReporter() && request.resource.data.reporterId == request.auth.uid;
      allow update: if signedIn() && (
        resource.data.responderId == request.auth.uid ||
        resource.data.facilityId == request.auth.uid ||
        isAdmin()
      );

      match /alerts/{alertId} {
        allow read: if signedIn() && (
          resource.data.responderId == request.auth.uid ||
          isAdmin()
        );
        // Only Cloud Functions create alerts; clients can update only their own (accept/reject).
        allow update: if signedIn() && resource.data.responderId == request.auth.uid;
      }

      match /messages/{msgId} {
        allow read, create: if signedIn() && (
          get(/databases/$(database)/documents/cases/$(caseId)).data.reporterId == request.auth.uid ||
          get(/databases/$(database)/documents/cases/$(caseId)).data.responderId == request.auth.uid ||
          get(/databases/$(database)/documents/cases/$(caseId)).data.facilityId == request.auth.uid ||
          isAdmin()
        );
      }

      match /handover/{docId} {
        allow read: if signedIn() && (
          get(/databases/$(database)/documents/cases/$(caseId)).data.responderId == request.auth.uid ||
          get(/databases/$(database)/documents/cases/$(caseId)).data.facilityId == request.auth.uid ||
          isAdmin()
        );
        allow write: if signedIn() && (
          get(/databases/$(database)/documents/cases/$(caseId)).data.responderId == request.auth.uid ||
          get(/databases/$(database)/documents/cases/$(caseId)).data.facilityId == request.auth.uid
        );
      }
    }

    match /aeds/{aedId} {
      allow read: if signedIn();
      allow write: if isAdmin();
    }

    match /ratings/{ratingId} {
      allow read: if signedIn();
      allow create: if signedIn();
    }

    match /first_aid_guides/{guideId} {
      allow read: if true; // Public — first aid is critical safety content
      allow write: if isAdmin();
    }

    match /audit_logs/{logId} {
      allow read: if isAdmin();
      // Only Cloud Functions create audit logs.
    }

    match /system_config/{configId} {
      allow read: if signedIn();
      allow write: if isAdmin();
    }

    match /notifications/{nId} {
      allow read, update: if signedIn() && resource.data.userId == request.auth.uid;
    }
  }
}
```

Deploy with `firebase deploy --only firestore:rules`.

### Storage — `storage.rules`

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    match /users/{uid}/profile.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid && request.resource.size < 5 * 1024 * 1024;
    }

    match /responders/{uid}/certs/{certId}.pdf {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid && request.resource.size < 10 * 1024 * 1024;
    }

    match /cases/{caseId}/attachments/{name} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 11. Migration Strategy

The mock service classes already define the interface. Switching to Firebase is a **drop-in replacement** — providers and screens don't change.

**Step-by-step order to avoid breaking the app mid-migration:**

1. Add Firebase deps + `flutterfire configure`.
2. Create the Firebase project + enable Auth providers.
3. Replace [auth_service.dart](../lib/services/auth_service.dart) → confirm sign-up creates a user doc.
4. Replace [firestore_service.dart](../lib/services/firestore_service.dart) → switch one provider at a time to use streams (start with `ReporterProvider` since the SOS flow is the smallest end-to-end test).
5. Replace [notification_service.dart](../lib/services/notification_service.dart) and call `init()` from `app.dart`.
6. Replace [storage_service.dart](../lib/services/storage_service.dart) — wire the certificate-upload flow in `add_responder_screen.dart`.
7. Deploy security rules.
8. Deploy Cloud Functions.
9. Delete [mock_data_service.dart](../lib/services/mock_data_service.dart) and the demo-login shortcut in `AuthProvider.loginAsDemo()`.

**Rollback strategy:** keep the mock classes behind a feature flag in [lib/core/configuration/app_config.dart](../lib/core/configuration/app_config.dart) (`useMockServices: bool`) until end-to-end Firebase is verified. Then delete the mocks.

---

## 12. Testing Plan

### Unit
- Each model's `fromJson` / `toJson` round-trips against a Firestore `GeoPoint` payload.
- `responder_assignment_service` finds correct nearby responders via geohash query.

### Integration (using Firebase Emulator Suite)
```bash
firebase emulators:start --only auth,firestore,storage,functions
```
- Sign up Reporter via emulator Auth → Firestore `users` doc created.
- Trigger `onCaseCreated` → alert sub-docs appear.
- Mock-accept an alert → case `caseStatus` flips to `responder_assigned`.

### End-to-end (real Firebase)
- Two physical devices, one Reporter / one Responder.
- Reporter taps SOS → Responder's device receives FCM push within 5 s.
- Responder accepts → Reporter's tracking screen updates with responder location stream.
- Close case → both devices reflect closure.
- Inspect `audit_logs` collection — every write produced an entry.

### Load
- Use [Firestore Bulk Loader](https://firebase.google.com/docs/firestore/manage-data/import-export) to seed 10 000 responder docs and verify a 5 km query still returns ≤ 200 ms.

---

## 13. Cost & Scaling Notes

- **Spark plan limits**: 50 K reads, 20 K writes, 20 K deletes per day; 1 GiB Firestore storage.
- **Phone Auth on Spark**: 10 SMS per day, country-allowlist required.
- For production: upgrade to **Blaze** with a budget alert at $50/month. Cloud Functions and SMS phone auth require Blaze.
- Firestore reads are the dominant cost. Mitigate by:
  - Caching active case data in memory; read once per case open.
  - Using `snapshots()` only for screens currently visible (cancel stream on dispose).
  - Paginating `manage_cases_screen` (limit 20 per page).

---

## 14. Open Questions / Decisions Needed

| Question | Default |
|---|---|
| Use Firebase phone auth (Blaze) or third-party SMS (Twilio)? | Firebase Phone Auth, Blaze |
| Region for Firestore? | `me-central2` (Riyadh) |
| Use Firestore native or Realtime Database for chat? | Firestore — single tech stack, sub-collection pattern fits |
| Use App Check? | Yes, in production — prevents abuse of unauthenticated FCM endpoints |
| Logging / observability? | Firebase Crashlytics + Cloud Logging |

---

## 15. Acceptance Criteria

- [ ] User can sign up, sign in, and sign out via real Firebase Auth.
- [ ] Reporter SOS creates a Firestore case doc visible to a Responder within 3 s.
- [ ] Accepted alert flips case status; Reporter sees responder location update live.
- [ ] Hospital handover form writes `cases/{id}/handover/single` correctly.
- [ ] Case closure recomputes responder rating and total cases.
- [ ] Admin web view (Flutter) sees all cases on the live incident map.
- [ ] Security rules deny cross-user reads (verified by writing a deliberate "evil" test).
- [ ] FCM push arrives on Android and iOS within 5 s of case creation.
- [ ] App still runs offline for first-aid guides (already cached in assets).
