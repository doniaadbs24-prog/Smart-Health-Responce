import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../providers/admin_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/cards/facility_card.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/inputs/search_field.dart';

class ManageFacilitiesScreen extends StatefulWidget {
  const ManageFacilitiesScreen({super.key});

  @override
  State<ManageFacilitiesScreen> createState() => _ManageFacilitiesScreenState();
}

class _ManageFacilitiesScreenState extends State<ManageFacilitiesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = context.watch<AdminProvider>().facilities.where((f) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return f.facilityName.toLowerCase().contains(q) ||
          f.address.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Facilities')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addFacility),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: SearchField(
              hint: 'Search facilities',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (_, i) {
                final f = list[i];
                return Stack(
                  children: [
                    FacilityCard(
                      facility: f,
                      onTap: () => context.push(
                          AppRoutes.editFacility,
                          extra: f),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (a) =>
                            _handleAction(context, a, f),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(f.isActive
                                ? 'Deactivate'
                                : 'Activate'),
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
    dynamic facility,
  ) async {
    final admin = context.read<AdminProvider>();
    switch (action) {
      case 'edit':
        context.push(AppRoutes.editFacility, extra: facility);
        break;
      case 'toggle':
        final updated = facility.copyWith(
          isActive: !facility.isActive,
          updatedAt: DateTime.now(),
        );
        await admin.updateFacility(updated);
        if (mounted) {
          context.showSnack(
              updated.isActive ? 'Facility activated' : 'Facility deactivated');
        }
        break;
      case 'delete':
        final ok = await ConfirmDialog.show(context,
            title: 'Delete Facility',
            message: 'This cannot be undone.',
            confirmColor: AppColors.error);
        if (ok == true && mounted) {
          await admin.deleteFacility(facility.facilityId);
          if (mounted) context.showSnack('Facility deleted');
        }
        break;
    }
  }
}
