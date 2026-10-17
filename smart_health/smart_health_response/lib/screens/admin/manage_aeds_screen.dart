import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/configuration/routes.dart';
import '../../providers/admin_provider.dart';

class ManageAedsScreen extends StatelessWidget {
  const ManageAedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = context.watch<AdminProvider>().aeds;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage AEDs')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.editAed),
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.paddingM),
        itemBuilder: (_, i) {
          final a = list[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: a.isActive ? AppColors.success : AppColors.textTertiary,
                child: const Text('AED',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              title: Text(a.address.isEmpty ? 'AED #${a.aedId}' : a.address,
                  style: AppTextStyles.titleSmall),
              subtitle: Text(a.accessInstructions.isEmpty ? 'No access notes' : a.accessInstructions,
                  style: AppTextStyles.bodySmall),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              onTap: () => context.push(AppRoutes.editAed, extra: a),
            ),
          );
        },
      ),
    );
  }
}
