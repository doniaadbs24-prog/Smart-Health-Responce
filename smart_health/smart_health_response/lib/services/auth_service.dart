import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/enums.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/exceptions.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        return null;
      }
      final doc = await _db
          .collection(FirestoreCollections.users)
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data()!);
      }
      return _currentUser;
    });
  }

  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _db
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      if (!doc.exists) {
        throw AuthException('User profile not found');
      }
      _currentUser = UserModel.fromJson(doc.data()!);
      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String phone,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final now = DateTime.now();
      final user = UserModel(
        userId: uid,
        email: email,
        phoneNumber: phone,
        fullName: fullName,
        userType: role,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );
      await _db
          .collection(FirestoreCollections.users)
          .doc(uid)
          .set(user.toJson());
      if (role == UserRole.reporter) {
        await _db.collection(FirestoreCollections.reporters).doc(uid).set({
          'reporterId': uid,
          'userId': uid,
          'emergencyContacts': [],
          'medicalProfile': {},
          'address': '',
          'emergencyAlertsSent': 0,
          'averageRating': 0.0,
        });
      } else if (role == UserRole.responder) {
        await _db.collection(FirestoreCollections.responders).doc(uid).set({
          'responderId': uid,
          'userId': uid,
          'certifications': [],
          'isApproved': false,
          'qualificationLevel': enumToString(QualificationLevel.basic),
          'isAvailable': false,
          'averageRating': 0.0,
          'totalCasesResponded': 0,
          'successRate': 0.0,
          'responseTime': 0.0,
          'specializations': [],
        });
      } else if (role == UserRole.facility) {
        await _db.collection(FirestoreCollections.facilities).doc(uid).set({
          'facilityId': uid,
          'facilityName': fullName,
          'facilityType': enumToString(FacilityType.hospital),
          'address': '',
          'location': const GeoPoint(0, 0),
          'contactNumber': phone,
          'email': email,
          'emergencyContactNumber': '',
          'capacity': 0,
          'currentPatientCount': 0,
          'isActive': true,
          'specialties': <String>[],
          'equipmentList': <String>[],
          'averageResponseTime': 0.0,
          'casesReceived': 0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });
      }
      _currentUser = user;
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  Future<bool> verifyOtp(String code) async {
    return true;
  }

  Future<UserModel> emergencyAccess() async {
    try {
      final credential = await _auth.signInAnonymously();
      final uid = credential.user!.uid;
      final now = DateTime.now();
      final user = UserModel(
        userId: uid,
        email: '',
        phoneNumber: '',
        fullName: 'Guest',
        userType: UserRole.reporter,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );
      await _db
          .collection(FirestoreCollections.users)
          .doc(uid)
          .set(user.toJson());
      await _db.collection(FirestoreCollections.reporters).doc(uid).set({
        'reporterId': uid,
        'userId': uid,
        'emergencyContacts': [],
        'medicalProfile': {},
        'address': '',
        'emergencyAlertsSent': 0,
        'averageRating': 0.0,
      });
      _currentUser = user;
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
