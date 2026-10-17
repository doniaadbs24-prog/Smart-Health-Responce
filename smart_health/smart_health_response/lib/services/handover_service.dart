import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../models/handover_record_model.dart';

class HandoverService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createHandover(HandoverRecord record) async {
    await _db
        .collection(FirestoreCollections.cases)
        .doc(record.caseId)
        .collection(FirestoreCollections.handovers)
        .doc('single')
        .set(record.toJson());
  }

  Future<HandoverRecord?> getHandover(String caseId) async {
    final doc = await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .collection(FirestoreCollections.handovers)
        .doc('single')
        .get();
    if (!doc.exists) return null;
    return HandoverRecord.fromJson(doc.data()!);
  }

  Future<void> confirmHandover(String caseId) async {
    await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .collection(FirestoreCollections.handovers)
        .doc('single')
        .update({'confirmedAt': DateTime.now().toIso8601String()});
  }
}
