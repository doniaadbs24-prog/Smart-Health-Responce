import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';
import '../models/case_closure_report_model.dart';

class CaseClosureService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createClosure(CaseClosureReport report) async {
    await _db
        .collection(FirestoreCollections.cases)
        .doc(report.caseId)
        .collection(FirestoreCollections.closures)
        .doc('single')
        .set(report.toJson());
  }

  Future<CaseClosureReport?> getClosure(String caseId) async {
    final doc = await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .collection(FirestoreCollections.closures)
        .doc('single')
        .get();
    if (!doc.exists) return null;
    return CaseClosureReport.fromJson(doc.data()!);
  }
}
