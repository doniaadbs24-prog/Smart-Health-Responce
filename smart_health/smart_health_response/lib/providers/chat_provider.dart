import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';
import '../models/communication_model.dart';
import '../services/service_locator.dart';

class ChatProvider extends ChangeNotifier {
  String? _caseId;
  List<CommunicationRecord> _messages = [];
  StreamSubscription<List<CommunicationRecord>>? _msgSub;

  List<CommunicationRecord> get messages => _messages;
  String? get caseId => _caseId;

  void open(String caseId) {
    _caseId = caseId;
    _msgSub?.cancel();
    _msgSub = sl.chat.watchMessages(caseId).listen((msgs) {
      _messages = msgs;
      notifyListeners();
    });
  }

  Future<void> send({
    required String senderId,
    required SenderType senderType,
    required String recipientId,
    required String content,
  }) async {
    if (_caseId == null || content.trim().isEmpty) return;
    await sl.chat.sendMessage(
      caseId: _caseId!,
      senderId: senderId,
      senderType: senderType,
      recipientId: recipientId,
      content: content.trim(),
    );
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }
}
