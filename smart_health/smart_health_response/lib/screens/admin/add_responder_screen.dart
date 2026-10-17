import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/dimensions.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/file_upload_field.dart';

class AddResponderScreen extends StatefulWidget {
  const AddResponderScreen({super.key});

  @override
  State<AddResponderScreen> createState() => _AddResponderScreenState();
}

class _AddResponderScreenState extends State<AddResponderScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await SuccessDialog.show(context,
        title: 'Responder Added', message: 'Pending verification of certificates.');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Responder')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          children: [
            AppTextField(label: 'Full Name', controller: _name, validator: Validators.required),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(label: 'Email', controller: _email, validator: Validators.email),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(label: 'Phone', controller: _phone, validator: Validators.phone),
            const SizedBox(height: AppDimensions.paddingL),
            const FileUploadField(label: 'CPR Certificate (PDF)'),
            const SizedBox(height: AppDimensions.paddingL),
            const FileUploadField(label: 'First-Aid Certificate (PDF)'),
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(label: 'Save', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
