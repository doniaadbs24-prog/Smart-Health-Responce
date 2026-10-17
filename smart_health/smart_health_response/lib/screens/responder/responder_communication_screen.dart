import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/constants/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/chat_input.dart';

class ResponderCommunicationScreen extends StatefulWidget {
  final String? caseId;
  const ResponderCommunicationScreen({super.key, this.caseId});

  @override
  State<ResponderCommunicationScreen> createState() => _ResponderCommunicationScreenState();
}

class _ResponderCommunicationScreenState extends State<ResponderCommunicationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().open(widget.caseId ?? 'case_1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().currentUser;
    final messages = context.watch<ChatProvider>().messages;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinate'),
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Coordinate with reporter and hospital here',
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
            onSend: (text) => context.read<ChatProvider>().send(
                  senderId: me?.userId ?? 'rsp_1',
                  senderType: SenderType.responder,
                  recipientId: 'r_1',
                  content: text,
                ),
          ),
        ],
      ),
    );
  }
}
