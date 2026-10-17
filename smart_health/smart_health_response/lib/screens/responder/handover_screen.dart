import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../models/handover_record_model.dart';
import '../../models/vital_signs_model.dart';
import '../../services/service_locator.dart';
import '../../utils/extensions.dart';
import '../../utils/helpers.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';

class HandoverScreen extends StatefulWidget {
  final EmergencyCase? emergencyCase;
  const HandoverScreen({super.key, this.emergencyCase});

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  final _form = GlobalKey<FormState>();
  final _condition = TextEditingController();
  final _hr = TextEditingController();
  final _bp = TextEditingController();
  final _spo2 = TextEditingController();
  final _treatments = TextEditingController();
  final _staff = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _condition.dispose();
    _hr.dispose();
    _bp.dispose();
    _spo2.dispose();
    _treatments.dispose();
    _staff.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final c = widget.emergencyCase;
    if (c == null) {
      context.showSnack('No active case', isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final record = HandoverRecord(
        handoverId: Helpers.generateId(),
        caseId: c.caseId,
        responderId: c.responderId ?? '',
        facilityId: c.facilityId ?? '',
        handoverTime: DateTime.now(),
        patientCondition: _condition.text.trim(),
        vitalSigns: VitalSigns(
          heartRate: int.tryParse(_hr.text.trim()),
          bloodPressure: _bp.text.trim().isEmpty ? null : _bp.text.trim(),
          oxygenSaturation: double.tryParse(_spo2.text.trim()),
        ),
        treatmentsProvided: _treatments.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        receivingStaffName: _staff.text.trim(),
      );
      await sl.handovers.createHandover(record);
      await sl.cases.updateStatus(c.caseId, CaseStatus.handoverStarted);
    } catch (e) {
      if (mounted) context.showSnack('Failed: $e', isError: true);
      setState(() => _submitting = false);
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    await SuccessDialog.show(context,
        title: 'Handover Submitted',
        message: 'Patient transferred to receiving facility.');
    if (mounted) context.go(AppRoutes.closeCase, extra: widget.emergencyCase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Handover')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          children: [
            Text('Patient Condition', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppDimensions.paddingS),
            AppTextField(controller: _condition, hint: 'Brief description', maxLines: 3),
            const SizedBox(height: AppDimensions.paddingL),
            Text('Vital Signs', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppDimensions.paddingS),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Heart Rate',
                    hint: 'BPM',
                    controller: _hr,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: AppTextField(
                    label: 'BP',
                    hint: '120/80',
                    controller: _bp,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              label: 'SpO₂',
              hint: '%',
              controller: _spo2,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              label: 'Treatments Provided',
              controller: _treatments,
              hint: 'CPR, oxygen, bleeding control...',
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              label: 'Receiving Staff',
              hint: 'Name of receiving doctor / nurse',
              controller: _staff,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(
              label: 'Submit Handover',
              icon: Icons.check_circle_outline,
              onPressed: _submit,
              isLoading: _submitting,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            TextButton(
              onPressed: () => context.showSnack('Saved as draft'),
              child: const Text('Save Draft', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
