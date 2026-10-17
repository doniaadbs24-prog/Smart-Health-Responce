import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/case_closure_report_model.dart';
import '../../models/emergency_case_model.dart';
import '../../services/service_locator.dart';
import '../../utils/extensions.dart';
import '../../utils/helpers.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/dropdown_field.dart';

class CloseCaseScreen extends StatefulWidget {
  final EmergencyCase? emergencyCase;
  const CloseCaseScreen({super.key, this.emergencyCase});

  @override
  State<CloseCaseScreen> createState() => _CloseCaseScreenState();
}

class _CloseCaseScreenState extends State<CloseCaseScreen> {
  CaseOutcome _outcome = CaseOutcome.transferredToHospital;
  final _notes = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
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
      final now = DateTime.now();
      final duration = c.assignedAt != null
          ? now.difference(c.assignedAt!).inMinutes
          : now.difference(c.createdAt).inMinutes;
      final report = CaseClosureReport(
        reportId: Helpers.generateId(),
        caseId: c.caseId,
        responderId: c.responderId ?? '',
        closedAt: now,
        caseOutcome: _outcome,
        finalNotes: _notes.text.trim(),
        caseDuration: duration,
      );
      await sl.closures.createClosure(report);
      await sl.cases.closeCase(c.caseId);
      if (c.responderId != null) {
        await sl.responders.recomputeStats(c.responderId!);
      }
    } catch (e) {
      if (mounted) context.showSnack('Failed: $e', isError: true);
      setState(() => _submitting = false);
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    await SuccessDialog.show(context,
        title: 'Case Closed', message: 'Thank you for your service.');
    if (mounted) context.go(AppRoutes.responderDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Close Case')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.success, size: 32),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(child: Text('Wrap up the case', style: AppTextStyles.titleMedium)),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          AppDropdownField<CaseOutcome>(
            label: 'Outcome',
            value: _outcome,
            prefixIcon: Icons.flag_outlined,
            items: CaseOutcome.values
                .map((o) => DropdownMenuItem(value: o, child: Text(_label(o))))
                .toList(),
            onChanged: (v) =>
                setState(() => _outcome = v ?? CaseOutcome.transferredToHospital),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(
            label: 'Final Notes',
            controller: _notes,
            maxLines: 4,
            hint: 'Anything to add for the report...',
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          PrimaryButton(label: 'Close Case', onPressed: _submit, isLoading: _submitting),
        ],
      ),
    );
  }

  String _label(CaseOutcome o) {
    switch (o) {
      case CaseOutcome.patientStable:
        return 'Patient stable';
      case CaseOutcome.transferredToHospital:
        return 'Transferred to hospital';
      case CaseOutcome.patientDeceased:
        return 'Patient deceased';
      case CaseOutcome.caseCancelled:
        return 'Case cancelled';
      case CaseOutcome.other:
        return 'Other';
    }
  }
}
