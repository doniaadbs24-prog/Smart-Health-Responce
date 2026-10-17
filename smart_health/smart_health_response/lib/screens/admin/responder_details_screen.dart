import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../models/responder_model.dart';
import '../../providers/admin_provider.dart';
import '../../utils/extensions.dart';
import '../../utils/formatters.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/confirm_dialog.dart';

class ResponderDetailsScreen extends StatelessWidget {
  final ResponderModel responder;
  const ResponderDetailsScreen({super.key, required this.responder});

  Future<void> _approve(BuildContext context) async {
    final ok = await ConfirmDialog.show(context,
        title: 'Approve Responder', message: 'Approve this responder?');
    if (ok == true && context.mounted) {
      await context.read<AdminProvider>().approveResponder(responder.responderId);
      if (context.mounted) {
        context.showSnack('Approved');
        context.pop();
      }
    }
  }

  Future<void> _reject(BuildContext context) async {
    final ok = await ConfirmDialog.show(context,
        title: 'Reject Responder',
        message: 'This will permanently remove the responder.',
        confirmColor: AppColors.error);
    if (ok == true && context.mounted) {
      await context.read<AdminProvider>().rejectResponder(responder.responderId);
      if (context.mounted) {
        context.showSnack('Removed');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responder Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: Text('R', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _Field('ID', responder.responderId),
          _Field('Status', responder.isApproved ? 'Approved' : 'Pending Approval'),
          _Field('Qualification', responder.qualificationLevel.name),
          _Field('Cases responded', '${responder.totalCasesResponded}'),
          _Field('Avg rating', responder.averageRating.toStringAsFixed(1)),
          _Field('Specializations', responder.specializations.join(', ')),
          const SizedBox(height: AppDimensions.paddingL),
          Text('Certifications', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.paddingS),
          ...responder.certifications.map((c) => Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(c.isVerified ? Icons.verified : Icons.pending,
                        color: c.isVerified ? AppColors.success : AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.certificationType.name.toUpperCase(),
                              style: AppTextStyles.titleSmall),
                          Text('Expires ${Formatters.date(c.expiryDate)}',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: AppDimensions.paddingXL),
          if (!responder.isApproved) ...[
            PrimaryButton(label: 'Approve', onPressed: () => _approve(context)),
            const SizedBox(height: AppDimensions.paddingM),
            OutlinedAppButton(
              label: 'Reject',
              color: AppColors.error,
              onPressed: () => _reject(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppTextStyles.labelMedium)),
          Expanded(child: Text(value.isEmpty ? '—' : value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
