import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/dimensions.dart';
import '../../models/responder_model.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';

class EditResponderScreen extends StatefulWidget {
  final ResponderModel responder;
  const EditResponderScreen({super.key, required this.responder});

  @override
  State<EditResponderScreen> createState() => _EditResponderScreenState();
}

class _EditResponderScreenState extends State<EditResponderScreen> {
  late final TextEditingController _specializations =
      TextEditingController(text: widget.responder.specializations.join(', '));

  @override
  void dispose() {
    _specializations.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await SuccessDialog.show(context,
        title: 'Saved', message: 'Responder profile updated.');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Responder')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          AppTextField(label: 'Specializations', controller: _specializations),
          const SizedBox(height: AppDimensions.paddingXL),
          PrimaryButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}
