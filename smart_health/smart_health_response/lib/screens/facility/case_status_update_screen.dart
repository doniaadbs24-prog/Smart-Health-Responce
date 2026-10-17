import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../providers/facility_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/dropdown_field.dart';

class CaseStatusUpdateScreen extends StatefulWidget {
  final EmergencyCase emergencyCase;
  const CaseStatusUpdateScreen({super.key, required this.emergencyCase});

  @override
  State<CaseStatusUpdateScreen> createState() => _CaseStatusUpdateScreenState();
}

class _CaseStatusUpdateScreenState extends State<CaseStatusUpdateScreen> {
  late CaseStatus _status = widget.emergencyCase.caseStatus;

  Future<void> _submit() async {
    await context.read<FacilityProvider>().updateCaseStatus(widget.emergencyCase.caseId, _status);
    if (!mounted) return;
    context.showSnack('Status updated');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Status')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Patient: ${widget.emergencyCase.patientName ?? "Unknown"}',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: AppDimensions.paddingL),
            AppDropdownField<CaseStatus>(
              label: 'Status',
              value: _status,
              items: const [
                CaseStatus.receivedAtFacility,
                CaseStatus.inTreatment,
                CaseStatus.closed,
              ]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(label: 'Update', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
