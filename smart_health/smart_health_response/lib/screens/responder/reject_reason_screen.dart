import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/dimensions.dart';
import '../../models/emergency_case_model.dart';
import '../../providers/responder_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';

class RejectReasonScreen extends StatefulWidget {
  final EmergencyCase emergencyCase;
  const RejectReasonScreen({super.key, required this.emergencyCase});

  @override
  State<RejectReasonScreen> createState() => _RejectReasonScreenState();
}

class _RejectReasonScreenState extends State<RejectReasonScreen> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await context.read<ResponderProvider>().rejectAlert(
          widget.emergencyCase.caseId,
          _reason.text.trim(),
        );
    if (!mounted) return;
    context.showSnack('Alert rejected');
    context.go('/responder/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reject Alert')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Reason',
              hint: 'Please tell us why you cannot respond',
              controller: _reason,
              maxLines: 4,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(label: 'Submit', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
