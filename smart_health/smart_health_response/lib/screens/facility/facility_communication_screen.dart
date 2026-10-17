import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/constants/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/chat_input.dart';

class FacilityCommunicationScreen extends StatefulWidget {
  const FacilityCommunicationScreen({super.key});

  @override
  State<FacilityCommunicationScreen> createState() => _FacilityCommunicationScreenState();
}

class _FacilityCommunicationScreenState extends State<FacilityCommunicationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().open('case_1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().currentUser;
    final messages = context.watch<ChatProvider>().messages;
    return Scaffold(
      appBar: AppBar(title: const Text('Coordinate with Responder')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('Coordinate ER readiness here', style: TextStyle(color: AppColors.textTertiary)))
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
            onSend: (text) => context.read<ChatProvider>().send(
                  senderId: me?.userId ?? 'fac_1',
                  senderType: SenderType.facility,
                  recipientId: 'rsp_1',
                  content: text,
                ),
          ),
        ],
      ),
    );
  }
}
