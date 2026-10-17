import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';
import '../core/constants/firestore_collections.dart';
import '../models/attachment_model.dart';
import '../models/emergency_case_model.dart';
import '../utils/helpers.dart';

class EmergencyCaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<EmergencyCase> createCase({
    required String reporterId,
    required GeoPoint location,
    required IncidentType type,
    required String description,
    String? patientName,
  }) async {
    final now = DateTime.now();
    final caseId = Helpers.generateId();
    final emergencyCase = EmergencyCase(
      caseId: caseId,
      reporterId: reporterId,
      incidentLocation: location,
      incidentType: type,
      caseStatus: CaseStatus.alertSent,
      createdAt: now,
      description: description,
      patientName: patientName,
    );
    await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .set(emergencyCase.toJson());
    return emergencyCase;
  }

  Future<EmergencyCase?> getById(String caseId) async {
    final doc = await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .get();
    if (!doc.exists) return null;
    return EmergencyCase.fromJson(doc.data()!);
  }

  Future<List<EmergencyCase>> getByReporter(String reporterId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.cases)
        .where('reporterId', isEqualTo: reporterId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => EmergencyCase.fromJson(doc.data()))
        .toList();
  }

  Future<List<EmergencyCase>> getByResponder(String responderId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.cases)
        .where('responderId', isEqualTo: responderId)
        .get();
    return snapshot.docs
        .map((doc) => EmergencyCase.fromJson(doc.data()))
        .toList();
  }

  Future<List<EmergencyCase>> getByFacility(String facilityId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.cases)
        .where('facilityId', isEqualTo: facilityId)
        .get();
    return snapshot.docs
        .map((doc) => EmergencyCase.fromJson(doc.data()))
        .toList();
  }

  Future<List<EmergencyCase>> getAll() async {
    final snapshot = await _db.collection(FirestoreCollections.cases).get();
    return snapshot.docs
        .map((doc) => EmergencyCase.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateCase(EmergencyCase updated) async {
    await _db
        .collection(FirestoreCollections.cases)
        .doc(updated.caseId)
        .update(updated.toJson());
  }

  Future<void> assignResponder(String caseId, String responderId) async {
    final caseRef = _db.collection(FirestoreCollections.cases).doc(caseId);
    final alertsRef = caseRef.collection(FirestoreCollections.alerts);
    final pendingSnap = await alertsRef
        .where(
          'acceptanceStatus',
          isEqualTo: enumToString(AlertStatus.pending),
        )
        .get();

    final batch = _db.batch();
    batch.update(caseRef, {
      'responderId': responderId,
      'caseStatus': enumToString(CaseStatus.responderAssigned),
      'assignedAt': DateTime.now().toIso8601String(),
    });
    for (final doc in pendingSnap.docs) {
      final alertResponderId = doc.data()['responderId'] as String?;
      batch.update(doc.reference, {
        'acceptanceStatus': alertResponderId == responderId
            ? enumToString(AlertStatus.accepted)
            : enumToString(AlertStatus.expired),
      });
    }
    await batch.commit();
  }

  Future<void> updateStatus(String caseId, CaseStatus status) async {
    final data = <String, dynamic>{'caseStatus': enumToString(status)};
    if (status == CaseStatus.closed) {
      data['completedAt'] = DateTime.now().toIso8601String();
    }
    await _db.collection(FirestoreCollections.cases).doc(caseId).update(data);
  }

  Future<void> closeCase(String caseId) async {
    await updateStatus(caseId, CaseStatus.closed);
  }

  Stream<List<EmergencyCase>> watchByReporter(String reporterId) {
    return _db
        .collection(FirestoreCollections.cases)
        .where('reporterId', isEqualTo: reporterId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyCase.fromJson(doc.data()))
              .toList(),
        );
  }

  Stream<List<EmergencyCase>> watchByResponder(String responderId) {
    return _db
        .collection(FirestoreCollections.cases)
        .where('responderId', isEqualTo: responderId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyCase.fromJson(doc.data()))
              .toList(),
        );
  }

  Stream<List<EmergencyCase>> watchByFacility(String facilityId) {
    return _db
        .collection(FirestoreCollections.cases)
        .where('facilityId', isEqualTo: facilityId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyCase.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Watch ALL cases in the system (for facility dashboard that needs a global view).
  Stream<List<EmergencyCase>> watchAll() {
    return _db
        .collection(FirestoreCollections.cases)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyCase.fromJson(doc.data()))
              .toList(),
        );
  }

  Stream<EmergencyCase?> watchCase(String caseId) {
    return _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return EmergencyCase.fromJson(doc.data()!);
        });
  }

  Stream<List<EmergencyCase>> watchPendingAlerts() {
    return _db
        .collection(FirestoreCollections.cases)
        .where('responderId', isNull: true)
        .where('caseStatus', isEqualTo: enumToString(CaseStatus.alertSent))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyCase.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Append attachments (photo / voice) to an existing case document.
  Future<void> addAttachments(
    String caseId,
    List<Attachment> attachments,
  ) async {
    await _db.collection(FirestoreCollections.cases).doc(caseId).update({
      'attachments': FieldValue.arrayUnion(
        attachments.map((a) => a.toJson()).toList(),
      ),
    });
  }

  /// Assign a receiving facility to a case.
  Future<void> assignFacility(String caseId, String facilityId) async {
    await _db.collection(FirestoreCollections.cases).doc(caseId).update({
      'facilityId': facilityId,
    });
  }

  /// Delete a case document.
  Future<void> deleteCase(String caseId) async {
    await _db.collection(FirestoreCollections.cases).doc(caseId).delete();
  }
}
