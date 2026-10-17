import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../providers/admin_provider.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/layout/empty_state.dart';

class ManageCasesScreen extends StatelessWidget {
  const ManageCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    final cases = p.allCases;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Cases')),
      body: cases.isEmpty
          ? const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No cases found',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: cases.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (_, i) => _CaseManageTile(
                emergencyCase: cases[i],
              ),
            ),
    );
  }
}

class _CaseManageTile extends StatelessWidget {
  final EmergencyCase emergencyCase;
  const _CaseManageTile({required this.emergencyCase});

  @override
  Widget build(BuildContext context) {
    final c = emergencyCase;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(_iconForType(c.incidentType), color: AppColors.primary),
            title: Text(c.incidentType.label, style: AppTextStyles.titleSmall),
            subtitle: Text(
              '${c.caseStatus.label} · ${Formatters.relative(c.createdAt)}',
              style: AppTextStyles.bodySmall,
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleAction(context, action),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'status', child: Text('Change Status')),
                const PopupMenuItem(value: 'facility', child: Text('Assign Facility')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Case', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.paddingL,
              right: AppDimensions.paddingL,
              bottom: AppDimensions.paddingM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.description.isNotEmpty)
                  Text(c.description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  'Reporter: ${c.reporterId.substring(0, 8)}…'
                  '${c.responderId != null ? ' · Responder: ${c.responderId!.substring(0, 8)}…' : ''}'
                  '${c.facilityId != null ? ' · Facility: ${c.facilityId!.substring(0, 8)}…' : ''}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(IncidentType type) {
    switch (type) {
      case IncidentType.trafficAccident:
        return Icons.car_crash_outlined;
      case IncidentType.cardiacArrest:
        return Icons.favorite_outline;
      case IncidentType.breathingDifficulty:
        return Icons.air_outlined;
      case IncidentType.severeBleed:
        return Icons.bloodtype_outlined;
      case IncidentType.burns:
        return Icons.local_fire_department_outlined;
      case IncidentType.choking:
        return Icons.warning_amber_outlined;
      case IncidentType.other:
        return Icons.medical_services_outlined;
    }
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    final admin = context.read<AdminProvider>();

    switch (action) {
      case 'status':
        final status = await showDialog<CaseStatus>(
          context: context,
          builder: (_) => SimpleDialog(
            title: const Text('Change Status'),
            children: CaseStatus.values
                .map(
                  (s) => SimpleDialogOption(
                    child: Text(s.label),
                    onPressed: () => Navigator.pop(context, s),
                  ),
                )
                .toList(),
          ),
        );
        if (status != null && context.mounted) {
          await admin.updateCaseStatus(emergencyCase.caseId, status);
          if (context.mounted) {
            context.showSnack('Status updated to ${status.label}');
          }
        }
        break;

      case 'facility':
        final facilities = admin.facilities;
        if (facilities.isEmpty) {
          if (context.mounted) {
            context.showSnack('No facilities available', isError: true);
          }
          return;
        }
        final facilityId = await showDialog<String>(
          context: context,
          builder: (_) => SimpleDialog(
            title: const Text('Assign Facility'),
            children: facilities
                .map(
                  (f) => SimpleDialogOption(
                    child: Text(f.facilityName),
                    onPressed: () => Navigator.pop(context, f.facilityId),
                  ),
                )
                .toList(),
          ),
        );
        if (facilityId != null && context.mounted) {
          await admin.assignFacilityToCase(emergencyCase.caseId, facilityId);
          if (context.mounted) {
            context.showSnack('Facility assigned');
          }
        }
        break;

      case 'delete':
        final ok = await ConfirmDialog.show(
          context,
          title: 'Delete Case',
          message: 'This action cannot be undone.',
          confirmColor: AppColors.error,
        );
        if (ok == true && context.mounted) {
          await admin.deleteCase(emergencyCase.caseId);
          if (context.mounted) context.showSnack('Case deleted');
        }
        break;
    }
  }
}
