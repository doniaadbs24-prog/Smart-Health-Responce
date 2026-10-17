import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';
import '../core/constants/firestore_collections.dart';
import '../models/alert_history_model.dart';

class AlertHistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createAlert(AlertHistory alert) async {
    await _db
        .collection(FirestoreCollections.cases)
        .doc(alert.caseId)
        .collection(FirestoreCollections.alerts)
        .doc(alert.alertId)
        .set(alert.toJson());
  }

  Future<void> updateAlert(String caseId, AlertHistory alert) async {
    await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .collection(FirestoreCollections.alerts)
        .doc(alert.alertId)
        .update(alert.toJson());
  }

  Future<List<AlertHistory>> getAlertsForCase(String caseId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .collection(FirestoreCollections.alerts)
        .orderBy('alertSentAt', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => AlertHistory.fromJson(doc.data()))
        .toList();
  }

  Stream<List<AlertHistory>> watchPendingForResponder(String responderId) {
    return _db
        .collection(FirestoreCollections.cases)
        .where('caseStatus', isEqualTo: enumToString(CaseStatus.alertSent))
        .snapshots()
        .asyncMap((caseSnapshot) async {
          final alerts = <AlertHistory>[];
          for (final caseDoc in caseSnapshot.docs) {
            final alertSnapshot = await _db
                .collection(FirestoreCollections.cases)
                .doc(caseDoc.id)
                .collection(FirestoreCollections.alerts)
                .where('responderId', isEqualTo: responderId)
                .where(
                  'acceptanceStatus',
                  isEqualTo: enumToString(AlertStatus.pending),
                )
                .get();
            for (final alertDoc in alertSnapshot.docs) {
              alerts.add(AlertHistory.fromJson(alertDoc.data()));
            }
          }
          return alerts;
        });
  }
}
