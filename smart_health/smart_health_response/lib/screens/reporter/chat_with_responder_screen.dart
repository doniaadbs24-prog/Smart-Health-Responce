import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/chat_input.dart';

class ChatWithResponderScreen extends StatefulWidget {
  final EmergencyCase? emergencyCase;
  const ChatWithResponderScreen({super.key, this.emergencyCase});

  @override
  State<ChatWithResponderScreen> createState() => _ChatWithResponderScreenState();
}

class _ChatWithResponderScreenState extends State<ChatWithResponderScreen> {
  @override
  void initState() {
    super.initState();
    final caseId = widget.emergencyCase?.caseId;
    if (caseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatProvider>().open(caseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().currentUser;
    final messages = context.watch<ChatProvider>().messages;
    final responderId = widget.emergencyCase?.responderId;
    final initials = responderId == null
        ? '?'
        : Helpers.shortId(responderId, length: 2);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(initials,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Text(responderId == null ? 'Responder' : 'Responder ${Helpers.shortId(responderId)}'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Start the conversation',
                        style: TextStyle(color: AppColors.textTertiary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      return ChatBubble(message: m, isMe: m.senderId == me?.userId);
                    },
                  ),
          ),
          ChatInput(
            onSend: (text) {
              if (responderId == null) return;
              context.read<ChatProvider>().send(
                    senderId: me?.userId ?? 'guest',
                    senderType: SenderType.reporter,
                    recipientId: responderId,
                    content: text,
                  );
            },
          ),
        ],
      ),
    );
  }
}
