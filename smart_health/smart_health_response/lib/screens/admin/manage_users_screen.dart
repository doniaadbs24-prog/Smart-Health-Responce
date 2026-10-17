import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../services/service_locator.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/inputs/search_field.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AdminProvider>().users.where((u) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return u.fullName.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: SearchField(
              hint: 'Search users',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.paddingS),
              itemBuilder: (_, i) {
                final u = users[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: u.isActive ? AppColors.primary : AppColors.textTertiary,
                      child: Text(u.fullName.initials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(u.fullName, style: AppTextStyles.titleSmall),
                    subtitle: Text(
                        '${u.userType.label} · ${u.email}\nJoined ${Formatters.date(u.createdAt)}',
                        style: AppTextStyles.bodySmall),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) => _handleAction(context, action, u),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(u.isActive ? 'Deactivate' : 'Activate'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: AppColors.error)),
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

  Future<void> _handleAction(BuildContext context, String action, UserModel user) async {
    final admin = context.read<AdminProvider>();
    switch (action) {
      case 'toggle':
        final updated = user.copyWith(isActive: !user.isActive, updatedAt: DateTime.now());
        await sl.users.update(updated);
        await admin.loadAll();
        if (mounted) {
          context.showSnack(updated.isActive ? 'User activated' : 'User deactivated');
        }
        break;
      case 'delete':
        final ok = await ConfirmDialog.show(context,
            title: 'Delete User',
            message: 'Delete ${user.fullName}? This cannot be undone.',
            confirmColor: AppColors.error);
        if (ok == true && mounted) {
          await sl.users.delete(user.userId);
          await admin.loadAll();
          if (mounted) context.showSnack('User deleted');
        }
        break;
    }
  }
}
