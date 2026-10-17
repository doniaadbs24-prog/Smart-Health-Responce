import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/enums.dart';
import '../core/constants/firestore_collections.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<UserModel>> getAll() async {
    final snapshot = await _db.collection(FirestoreCollections.users).get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Future<List<UserModel>> getByRole(UserRole role) async {
    final snapshot = await _db
        .collection(FirestoreCollections.users)
        .where('userType', isEqualTo: enumToString(role))
        .get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Future<UserModel?> getById(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }

  Future<UserModel?> getByEmail(String email) async {
    final snapshot = await _db
        .collection(FirestoreCollections.users)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromJson(snapshot.docs.first.data());
  }

  Future<void> create(UserModel user) async {
    await _db
        .collection(FirestoreCollections.users)
        .doc(user.userId)
        .set(user.toJson());
  }

  Future<void> update(UserModel user) async {
    await _db
        .collection(FirestoreCollections.users)
        .doc(user.userId)
        .update(user.toJson());
  }

  Future<void> delete(String uid) async {
    await _db.collection(FirestoreCollections.users).doc(uid).delete();
  }

  Stream<UserModel?> watchUser(String uid) {
    return _db.collection(FirestoreCollections.users).doc(uid).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    });
  }
}
