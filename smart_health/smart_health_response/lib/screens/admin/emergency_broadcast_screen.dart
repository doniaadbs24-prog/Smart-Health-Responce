import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/user_model.dart';
import '../../services/service_locator.dart';
import '../../utils/extensions.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/dropdown_field.dart';

class EmergencyBroadcastScreen extends StatefulWidget {
  const EmergencyBroadcastScreen({super.key});

  @override
  State<EmergencyBroadcastScreen> createState() =>
      _EmergencyBroadcastScreenState();
}

class _EmergencyBroadcastScreenState extends State<EmergencyBroadcastScreen> {
  final _form = GlobalKey<FormState>();
  final _message = TextEditingController();
  final _title = TextEditingController(text: 'Emergency Notice');
  String _audience = 'All Responders';
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<List<UserModel>> _resolveAudience() async {
    switch (_audience) {
      case 'All Responders':
        return sl.users.getByRole(UserRole.responder);
      case 'All Reporters':
        return sl.users.getByRole(UserRole.reporter);
      case 'All Facilities':
        return sl.users.getByRole(UserRole.facility);
      case 'Everyone':
      default:
        return sl.users.getAll();
    }
  }

  Future<void> _send() async {
    if (_message.text.trim().isEmpty) {
      context.showSnack('Please enter a message', isError: true);
      return;
    }
    final ok = await ConfirmDialog.show(context,
        title: 'Send Broadcast',
        message: 'Send to "$_audience"?',
        confirmColor: AppColors.error,
        confirmLabel: 'Send');
    if (ok != true) return;
    if (!mounted) return;
    setState(() => _sending = true);
    int delivered = 0;
    try {
      final users = await _resolveAudience();
      for (final u in users) {
        await sl.notifications.push(
          userId: u.userId,
          title: _title.text.trim().isEmpty ? 'Emergency Notice' : _title.text.trim(),
          body: _message.text.trim(),
          type: 'broadcast',
        );
        delivered++;
      }
    } catch (e) {
      if (mounted) context.showSnack('Failed: $e', isError: true);
      setState(() => _sending = false);
      return;
    }
    if (!mounted) return;
    setState(() => _sending = false);
    await SuccessDialog.show(context,
        title: 'Sent', message: 'Broadcast delivered to $delivered recipient(s).');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Broadcast')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign_outlined, color: AppColors.error),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Text('Use only for critical emergencies.',
                        style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppDropdownField<String>(
              label: 'Audience',
              value: _audience,
              items: const [
                'All Responders',
                'All Reporters',
                'All Facilities',
                'Everyone',
              ].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (v) => setState(() => _audience = v ?? 'All Responders'),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(label: 'Title', controller: _title),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(label: 'Message', controller: _message, maxLines: 5),
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(
              label: 'Send Broadcast',
              icon: Icons.send_outlined,
              onPressed: _send,
              isLoading: _sending,
            ),
          ],
        ),
      ),
    );
  }
}
