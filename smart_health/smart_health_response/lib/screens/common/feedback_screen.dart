import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/dimensions.dart';
import '../../utils/extensions.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  void _send() {
    context.showSnack('Thanks for your feedback');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          AppTextField(label: 'Subject', controller: _subject),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(label: 'Message', controller: _message, maxLines: 6),
          const SizedBox(height: AppDimensions.paddingXL),
          PrimaryButton(label: 'Send', onPressed: _send),
        ],
      ),
    );
  }
}
