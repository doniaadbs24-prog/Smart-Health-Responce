import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../models/emergency_case_model.dart';
import '../../models/rating_feedback_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/service_locator.dart';
import '../../utils/extensions.dart';
import '../../utils/helpers.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/status/rating_stars.dart';

class ServiceRatingScreen extends StatefulWidget {
  final EmergencyCase? emergencyCase;
  const ServiceRatingScreen({super.key, this.emergencyCase});

  @override
  State<ServiceRatingScreen> createState() => _ServiceRatingScreenState();
}

class _ServiceRatingScreenState extends State<ServiceRatingScreen> {
  double _rating = 5;
  final _feedback = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final c = widget.emergencyCase;
    final raterId = context.read<AuthProvider>().currentUser?.userId;
    if (c == null || c.responderId == null || raterId == null) {
      context.showSnack('Cannot submit rating right now', isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final rating = RatingFeedback(
        ratingId: Helpers.generateId(),
        caseId: c.caseId,
        responderId: c.responderId!,
        raterId: raterId,
        ratingScore: _rating.round(),
        feedbackText: _feedback.text.trim(),
        ratedAt: DateTime.now(),
      );
      await sl.ratings.create(rating);
      await sl.responders.recomputeStats(c.responderId!);
    } catch (e) {
      if (mounted) context.showSnack('Failed: $e', isError: true);
      setState(() => _submitting = false);
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    context.showSnack('Thanks for your feedback!');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Service')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.paddingXL),
              Text('How was your responder?',
                  style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.paddingL),
              Center(
                child: RatingStars(
                  rating: _rating,
                  size: 48,
                  onChanged: (v) => setState(() => _rating = v),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              AppTextField(
                label: 'Feedback',
                hint: 'Tell us about your experience',
                controller: _feedback,
                maxLines: 4,
              ),
              const Spacer(),
              PrimaryButton(label: 'Submit', onPressed: _submit, isLoading: _submitting),
              const SizedBox(height: AppDimensions.paddingM),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
