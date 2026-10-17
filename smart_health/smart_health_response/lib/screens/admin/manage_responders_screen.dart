import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../models/responder_model.dart';
import '../../providers/admin_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/cards/responder_card.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/inputs/search_field.dart';

class ManageRespondersScreen extends StatefulWidget {
  const ManageRespondersScreen({super.key});

  @override
  State<ManageRespondersScreen> createState() => _ManageRespondersScreenState();
}

class _ManageRespondersScreenState extends State<ManageRespondersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    final filtered = p.responders.where((r) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      final u = p.users.where((x) => x.userId == r.userId).firstOrNull;
      return (u?.fullName.toLowerCase().contains(q) ?? false) ||
          r.responderId.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Responders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addResponder),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: SearchField(
              hint: 'Search responders',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL),
              itemCount: filtered.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (_, i) {
                final r = filtered[i];
                final user = p.users.firstWhere(
                  (u) => u.userId == r.userId,
                  orElse: () => p.users.first,
                );
                return Stack(
                  children: [
                    ResponderCard(
                      responder: r,
                      user: user,
                      onTap: () => context.push(
                          AppRoutes.responderDetails,
                          extra: r),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (a) =>
                            _handleAction(context, a, r),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'approve',
                            child: Text(r.isApproved
                                ? 'Already Approved'
                                : 'Approve'),
                            enabled: !r.isApproved,
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete',
                                style:
                                    TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    ResponderModel responder,
  ) async {
    final admin = context.read<AdminProvider>();
    switch (action) {
      case 'edit':
        context.push(AppRoutes.editResponder, extra: responder);
        break;
      case 'approve':
        await admin.approveResponder(responder.responderId);
        if (mounted) context.showSnack('Responder approved');
        break;
      case 'delete':
        final ok = await ConfirmDialog.show(context,
            title: 'Delete Responder',
            message: 'This cannot be undone.',
            confirmColor: AppColors.error);
        if (ok == true && mounted) {
          await admin.rejectResponder(responder.responderId);
          if (mounted) context.showSnack('Responder deleted');
        }
        break;
    }
  }
}
