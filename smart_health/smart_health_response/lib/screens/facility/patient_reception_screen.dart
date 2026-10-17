import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../services/service_locator.dart';
import '../../utils/extensions.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';

class PatientReceptionScreen extends StatefulWidget {
  final EmergencyCase? emergencyCase;
  const PatientReceptionScreen({super.key, this.emergencyCase});

  @override
  State<PatientReceptionScreen> createState() => _PatientReceptionScreenState();
}

class _PatientReceptionScreenState extends State<PatientReceptionScreen> {
  final _staff = TextEditingController();
  final _patientId = TextEditingController();
  final _notes = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _staff.dispose();
    _patientId.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final c = widget.emergencyCase;
    if (c == null) {
      context.showSnack('No active case', isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      await sl.handovers.confirmHandover(c.caseId);
      await sl.cases.updateStatus(c.caseId, CaseStatus.receivedAtFacility);
    } catch (e) {
      if (mounted) context.showSnack('Failed: $e', isError: true);
      setState(() => _submitting = false);
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    await SuccessDialog.show(context,
        title: 'Patient Received', message: 'Handover documentation saved.');
    if (mounted) context.go(AppRoutes.facilityDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Reception')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          Text('Patient: ${widget.emergencyCase?.patientName ?? "Unknown"}',
              style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(label: 'Receiving Staff', controller: _staff),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(label: 'Hospital Patient ID', controller: _patientId),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(label: 'Reception Notes', controller: _notes, maxLines: 4),
          const SizedBox(height: AppDimensions.paddingXL),
          PrimaryButton(
            label: 'Confirm Reception',
            onPressed: _submit,
            isLoading: _submitting,
          ),
        ],
      ),
    );
  }
}
