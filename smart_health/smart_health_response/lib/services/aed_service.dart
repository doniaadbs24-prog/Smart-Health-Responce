import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../models/aed_model.dart';

class AedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Aed>> getAll() async {
    final snapshot = await _db.collection(FirestoreCollections.aeds).get();
    return snapshot.docs.map((doc) => Aed.fromJson(doc.data())).toList();
  }

  Future<Aed?> getById(String aedId) async {
    final doc = await _db
        .collection(FirestoreCollections.aeds)
        .doc(aedId)
        .get();
    if (!doc.exists) return null;
    return Aed.fromJson(doc.data()!);
  }

  Future<void> create(Aed aed) async {
    await _db
        .collection(FirestoreCollections.aeds)
        .doc(aed.aedId)
        .set(aed.toJson());
  }

  Future<void> update(Aed aed) async {
    await _db
        .collection(FirestoreCollections.aeds)
        .doc(aed.aedId)
        .update(aed.toJson());
  }

  Future<void> delete(String aedId) async {
    await _db.collection(FirestoreCollections.aeds).doc(aedId).delete();
  }
}
