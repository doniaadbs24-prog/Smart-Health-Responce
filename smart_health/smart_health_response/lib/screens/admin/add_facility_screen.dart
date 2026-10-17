import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';
import '../../models/facility_model.dart';
import '../../providers/admin_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/dropdown_field.dart';

class AddFacilityScreen extends StatefulWidget {
  const AddFacilityScreen({super.key});

  @override
  State<AddFacilityScreen> createState() => _AddFacilityScreenState();
}

class _AddFacilityScreenState extends State<AddFacilityScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _capacity = TextEditingController(text: '20');
  FacilityType _type = FacilityType.hospital;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final now = DateTime.now();
    final f = FacilityModel(
      facilityId: 'fac_${Helpers.generateId()}',
      facilityName: _name.text.trim(),
      facilityType: _type,
      address: _address.text.trim(),
      location: const GeoPoint(16.8892, 42.5611),
      contactNumber: _phone.text.trim(),
      capacity: int.tryParse(_capacity.text) ?? 0,
      createdAt: now,
      updatedAt: now,
    );
    await context.read<AdminProvider>().addFacility(f);
    if (!mounted) return;
    await SuccessDialog.show(
      context,
      title: 'Added',
      message: 'Facility created.',
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Facility')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          children: [
            AppTextField(
              label: 'Facility Name',
              controller: _name,
              validator: Validators.required,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppDropdownField<FacilityType>(
              label: 'Type',
              value: _type,
              items: FacilityType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _type = v ?? FacilityType.hospital),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              label: 'Address',
              controller: _address,
              validator: Validators.required,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              label: 'Phone',
              controller: _phone,
              validator: Validators.phone,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              label: 'Capacity (beds)',
              controller: _capacity,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(label: 'Save', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
