import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/dimensions.dart';
import '../../models/first_aid_guide_model.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';

class EditFirstAidScreen extends StatefulWidget {
  final FirstAidGuide guide;
  const EditFirstAidScreen({super.key, required this.guide});

  @override
  State<EditFirstAidScreen> createState() => _EditFirstAidScreenState();
}

class _EditFirstAidScreenState extends State<EditFirstAidScreen> {
  late final _title = TextEditingController(text: widget.guide.title);
  late final _description = TextEditingController(text: widget.guide.description);

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await SuccessDialog.show(context, title: 'Saved', message: 'Guide updated.');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Guide')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          AppTextField(label: 'Title', controller: _title),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(label: 'Description', controller: _description, maxLines: 3),
          const SizedBox(height: AppDimensions.paddingXL),
          PrimaryButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}
