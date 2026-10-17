import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../utils/extensions.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/status/rating_stars.dart';

class FacilityFeedbackScreen extends StatefulWidget {
  const FacilityFeedbackScreen({super.key});

  @override
  State<FacilityFeedbackScreen> createState() => _FacilityFeedbackScreenState();
}

class _FacilityFeedbackScreenState extends State<FacilityFeedbackScreen> {
  double _rating = 5;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    context.showSnack('Feedback submitted');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responder Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Rate the responder', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppDimensions.paddingS),
            Center(
              child: RatingStars(rating: _rating, size: 36, onChanged: (v) => setState(() => _rating = v)),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(label: 'Outcome notes', controller: _notes, maxLines: 4),
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(label: 'Submit', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
