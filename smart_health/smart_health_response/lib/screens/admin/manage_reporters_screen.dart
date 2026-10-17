import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/reporter_model.dart';
import '../../providers/admin_provider.dart';
import '../../services/service_locator.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/inputs/search_field.dart';

class ManageReportersScreen extends StatefulWidget {
  const ManageReportersScreen({super.key});

  @override
  State<ManageReportersScreen> createState() => _ManageReportersScreenState();
}

class _ManageReportersScreenState extends State<ManageReportersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final reporters = context.watch<AdminProvider>().reporters;
    final users = context.watch<AdminProvider>().users;
    final filtered = reporters.where((r) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      final u = users.where((x) => x.userId == r.userId).firstOrNull;
      return (u?.fullName.toLowerCase().contains(q) ?? false) ||
          r.reporterId.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Reporters')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: SearchField(
              hint: 'Search reporters',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              itemCount: filtered.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (_, i) {
                final r = filtered[i];
                final u = users
                    .where((x) => x.userId == r.userId)
                    .firstOrNull;
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.info,
                      child: Text(
                        (u?.fullName ?? 'R').initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(u?.fullName ?? r.reporterId,
                        style: AppTextStyles.titleSmall),
                    subtitle: Text(
                      '${r.emergencyAlertsSent} alerts · Rating ${r.averageRating.toStringAsFixed(1)}'
                      '\nJoined ${Formatters.date(u?.createdAt)}',
                      style: AppTextStyles.bodySmall,
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (a) =>
                          _handleAction(context, a, r, u),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'details',
                          child: Text('View Details'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    String action,
    ReporterModel reporter,
    dynamic user,
  ) async {
    final admin = context.read<AdminProvider>();
    switch (action) {
      case 'details':
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(user?.fullName ?? reporter.reporterId),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${user?.email ?? '—'}'),
                Text('Phone: ${user?.phoneNumber ?? '—'}'),
                Text('Alerts sent: ${reporter.emergencyAlertsSent}'),
                Text(
                    'Rating: ${reporter.averageRating.toStringAsFixed(1)}'),
                Text('Blood type: ${reporter.medicalProfile.bloodType?.label ?? '—'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
        break;
      case 'delete':
        final ok = await ConfirmDialog.show(context,
            title: 'Delete Reporter',
            message: 'This cannot be undone.',
            confirmColor: AppColors.error);
        if (ok == true && mounted) {
          await sl.reporters.delete(reporter.reporterId);
          await admin.loadAll();
          if (mounted) context.showSnack('Reporter deleted');
        }
        break;
    }
  }
}
