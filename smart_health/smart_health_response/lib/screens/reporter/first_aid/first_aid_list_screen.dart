import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/configuration/colors.dart';
import '../../../core/configuration/dimensions.dart';
import '../../../core/configuration/text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/first_aid_guide_model.dart';
import '../../../providers/first_aid_provider.dart';

class FirstAidListScreen extends StatefulWidget {
  const FirstAidListScreen({super.key});

  @override
  State<FirstAidListScreen> createState() => _FirstAidListScreenState();
}

class _FirstAidListScreenState extends State<FirstAidListScreen> {
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
      appBar: AppBar(title: const Text(AppStrings.firstAidGuide)),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: p.guides.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (_, i) => _GuideCard(
                guide: p.guides[i],
                onTap: () => context.push('/reporter/first-aid/detail',
                    extra: p.guides[i]),
              ),
            ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final FirstAidGuide guide;
  final VoidCallback onTap;
  const _GuideCard({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: const Icon(Icons.medical_services_outlined,
                    color: AppColors.primary, size: AppDimensions.iconL),
              ),
              const SizedBox(width: AppDimensions.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guide.title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text('${guide.steps.length} steps · ${guide.description}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
