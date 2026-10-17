import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../models/reporter_model.dart';

class ReporterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ReporterModel>> getAll() async {
    final snapshot = await _db.collection(FirestoreCollections.reporters).get();
    return snapshot.docs
        .map((doc) => ReporterModel.fromJson(doc.data()))
        .toList();
  }

  Future<ReporterModel?> getById(String reporterId) async {
    final doc = await _db
        .collection(FirestoreCollections.reporters)
        .doc(reporterId)
        .get();
    if (!doc.exists) return null;
    return ReporterModel.fromJson(doc.data()!);
  }

  Future<void> create(ReporterModel reporter) async {
    await _db
        .collection(FirestoreCollections.reporters)
        .doc(reporter.reporterId)
        .set(reporter.toJson());
  }

  Future<void> update(ReporterModel reporter) async {
    await _db
        .collection(FirestoreCollections.reporters)
        .doc(reporter.reporterId)
        .update(reporter.toJson());
  }

  Future<void> delete(String reporterId) async {
    await _db
        .collection(FirestoreCollections.reporters)
        .doc(reporterId)
        .delete();
  }
}
