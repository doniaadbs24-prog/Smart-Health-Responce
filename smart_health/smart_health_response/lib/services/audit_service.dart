import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';
import '../core/constants/firestore_collections.dart';
import '../models/audit_log_model.dart';
import '../utils/helpers.dart';

class AuditService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> log({
    required String userId,
    required AuditActionType action,
    required String resourceType,
    required String resourceId,
    String details = '',
    AuditStatus status = AuditStatus.success,
  }) async {
    final entry = AuditLog(
      logId: Helpers.generateId(),
      userId: userId,
      actionType: action,
      resourceType: resourceType,
      resourceId: resourceId,
      changeDetails: details,
      timestamp: DateTime.now(),
      status: status,
    );
    await _db
        .collection(FirestoreCollections.auditLogs)
        .doc(entry.logId)
        .set(entry.toJson());
  }

  Future<List<AuditLog>> getAll() async {
    final snapshot = await _db
        .collection(FirestoreCollections.auditLogs)
        .orderBy('timestamp', descending: true)
        .get();
    final results = <AuditLog>[];
    for (final doc in snapshot.docs) {
      try {
        results.add(AuditLog.fromJson(doc.data()));
      } catch (_) {
        // Skip malformed documents instead of crashing.
      }
    }
    return results;
  }

  Stream<List<AuditLog>> watchAll() {
    return _db
        .collection(FirestoreCollections.auditLogs)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuditLog.fromJson(doc.data()))
              .toList(),
        );
  }
}
