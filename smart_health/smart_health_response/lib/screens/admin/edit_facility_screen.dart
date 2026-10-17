import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/constants/enums.dart';
import '../../models/facility_model.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/dropdown_field.dart';

class EditFacilityScreen extends StatefulWidget {
  final FacilityModel facility;
  const EditFacilityScreen({super.key, required this.facility});

  @override
  State<EditFacilityScreen> createState() => _EditFacilityScreenState();
}

class _EditFacilityScreenState extends State<EditFacilityScreen> {
  late final _name = TextEditingController(text: widget.facility.facilityName);
  late final _address = TextEditingController(text: widget.facility.address);
  late final _phone = TextEditingController(text: widget.facility.contactNumber);
  late final _capacity = TextEditingController(text: '${widget.facility.capacity}');
  late FacilityType _selectedType = widget.facility.facilityType;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = widget.facility.copyWith(
      facilityName: _name.text.trim(),
      address: _address.text.trim(),
      contactNumber: _phone.text.trim(),
      capacity: int.tryParse(_capacity.text) ?? widget.facility.capacity,
      facilityType: _selectedType,
      updatedAt: DateTime.now(),
    );
    await context.read<AdminProvider>().updateFacility(updated);
    if (!mounted) return;
    await SuccessDialog.show(context, title: 'Saved', message: 'Facility updated.');
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final ok = await ConfirmDialog.show(context,
        title: 'Delete Facility',
        message: 'This action cannot be undone.',
        confirmColor: AppColors.error);
    if (ok == true && mounted) {
      await context.read<AdminProvider>().deleteFacility(widget.facility.facilityId);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Facility')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          AppTextField(label: 'Name', controller: _name),
          const SizedBox(height: AppDimensions.paddingL),
          AppDropdownField<FacilityType>(
            label: 'Facility Type',
            value: _selectedType,
            prefixIcon: Icons.local_hospital_outlined,
            items: FacilityType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedType = v ?? FacilityType.hospital),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(label: 'Address', controller: _address),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(label: 'Phone', controller: _phone),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(
            label: 'Capacity',
            controller: _capacity,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          PrimaryButton(label: 'Save', onPressed: _save),
          const SizedBox(height: AppDimensions.paddingM),
          OutlinedAppButton(label: 'Delete', color: AppColors.error, onPressed: _delete),
        ],
      ),
    );
  }
}
