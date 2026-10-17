import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';
import '../core/constants/firestore_collections.dart';
import '../models/communication_model.dart';
import '../utils/helpers.dart';

class CommunicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<CommunicationRecord>> getMessages(String caseId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .collection(FirestoreCollections.messages)
        .orderBy('sentAt', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => CommunicationRecord.fromJson(doc.data()))
        .toList();
  }

  Future<CommunicationRecord> sendMessage({
    required String caseId,
    required String senderId,
    required SenderType senderType,
    required String recipientId,
    required String content,
  }) async {
    final now = DateTime.now();
    final record = CommunicationRecord(
      communicationId: Helpers.generateId(),
      caseId: caseId,
      senderId: senderId,
      senderType: senderType,
      recipientId: recipientId,
      messageContent: content,
      sentAt: now,
    );
    await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .collection(FirestoreCollections.messages)
        .doc(record.communicationId)
        .set(record.toJson());
    return record;
  }

  Stream<List<CommunicationRecord>> watchMessages(String caseId) {
    return _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .collection(FirestoreCollections.messages)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunicationRecord.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> markAsRead(String caseId, String messageId) async {
    await _db
        .collection(FirestoreCollections.cases)
        .doc(caseId)
        .collection(FirestoreCollections.messages)
        .doc(messageId)
        .update({'readAt': DateTime.now().toIso8601String()});
  }
}
