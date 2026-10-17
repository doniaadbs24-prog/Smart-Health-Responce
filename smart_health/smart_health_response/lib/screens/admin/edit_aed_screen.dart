import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/aed_model.dart';
import '../../providers/admin_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';

class EditAedScreen extends StatefulWidget {
  final Aed? aed;
  const EditAedScreen({super.key, this.aed});

  @override
  State<EditAedScreen> createState() => _EditAedScreenState();
}

class _EditAedScreenState extends State<EditAedScreen> {
  late final _address = TextEditingController(text: widget.aed?.address ?? '');
  late final _instructions = TextEditingController(
    text: widget.aed?.accessInstructions ?? '',
  );

  @override
  void dispose() {
    _address.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final p = context.read<AdminProvider>();
    if (widget.aed == null) {
      final a = Aed(
        aedId: 'aed_${Helpers.generateId()}',
        location: const GeoPoint(16.8892, 42.5611),
        address: _address.text.trim(),
        accessInstructions: _instructions.text.trim(),
      );
      await p.addAed(a);
    } else {
      await p.updateAed(
        widget.aed!.copyWith(
          address: _address.text.trim(),
          accessInstructions: _instructions.text.trim(),
        ),
      );
    }
    if (!mounted) return;
    await SuccessDialog.show(context, title: 'Saved', message: 'AED saved.');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.aed == null ? 'Add AED' : 'Edit AED')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          AppTextField(label: 'Address', controller: _address),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(
            label: 'Access Instructions',
            controller: _instructions,
            maxLines: 3,
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          PrimaryButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}
