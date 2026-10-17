import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../providers/first_aid_provider.dart';

class ManageFirstAidScreen extends StatefulWidget {
  const ManageFirstAidScreen({super.key});

  @override
  State<ManageFirstAidScreen> createState() => _ManageFirstAidScreenState();
}

class _ManageFirstAidScreenState extends State<ManageFirstAidScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FirstAidProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FirstAidProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage First Aid Guides')),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: p.guides.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.paddingS),
              itemBuilder: (_, i) {
                final g = p.guides[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.medical_services_outlined,
                        color: AppColors.primary),
                    title: Text(g.title, style: AppTextStyles.titleSmall),
                    subtitle: Text('${g.steps.length} steps',
                        style: AppTextStyles.bodySmall),
                    trailing: const Icon(Icons.edit_outlined,
                        color: AppColors.textTertiary),
                    onTap: () => context.push(AppRoutes.editFirstAid, extra: g),
                  ),
                );
              },
            ),
    );
  }
}
