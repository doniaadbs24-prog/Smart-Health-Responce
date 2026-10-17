import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/facility_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/facility_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/dropdown_field.dart';

class FacilityProfileScreen extends StatelessWidget {
  const FacilityProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final f = context.watch<FacilityProvider>().facility;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Profile'),
        actions: [
          if (f != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _openEditSheet(context, f),
            ),
        ],
      ),
      body: f == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              children: [
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: const Icon(Icons.local_hospital_outlined, color: Colors.white, size: 56),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(f.facilityName, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
                Text(f.address, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: AppDimensions.paddingXL),
                _Tile(label: 'Type', value: f.facilityType.name),
                _Tile(label: 'Phone', value: f.contactNumber),
                _Tile(label: 'Email', value: f.email),
                _Tile(label: 'Emergency', value: f.emergencyContactNumber),
                _Tile(label: 'Capacity', value: '${f.capacity} beds'),
                _Tile(label: 'Available', value: '${f.availableBeds} beds'),
                _Tile(label: 'Specialties', value: f.specialties.join(', ')),
                _Tile(label: 'Equipment', value: f.equipmentList.join(', ')),
                const SizedBox(height: AppDimensions.paddingXL),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                  title: Text('Settings', style: AppTextStyles.titleSmall),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                  onTap: () => context.push(AppRoutes.settings),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_outlined, color: AppColors.error),
                  title: Text('Sign Out',
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.error)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                  onTap: () async {
                    await context.read<AuthProvider>().signOut();
                    if (!context.mounted) return;
                    context.go(AppRoutes.onboarding);
                  },
                ),
              ],
            ),
    );
  }

  void _openEditSheet(BuildContext context, FacilityModel facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FacilityEditSheet(facility: facility),
    );
  }
}

// ── Read-only row ────────────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final String label;
  final String value;
  const _Tile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.labelMedium),
          ),
          Expanded(
              child: Text(value.isEmpty ? '—' : value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

// ── Edit bottom sheet ────────────────────────────────────────────────
class _FacilityEditSheet extends StatefulWidget {
  final FacilityModel facility;
  const _FacilityEditSheet({required this.facility});

  @override
  State<_FacilityEditSheet> createState() => _FacilityEditSheetState();
}

class _FacilityEditSheetState extends State<_FacilityEditSheet> {
  late final _name = TextEditingController(text: widget.facility.facilityName);
  late final _address = TextEditingController(text: widget.facility.address);
  late final _phone = TextEditingController(text: widget.facility.contactNumber);
  late final _emergency = TextEditingController(text: widget.facility.emergencyContactNumber);
  late final _capacity = TextEditingController(text: '${widget.facility.capacity}');
  late final _specialties = TextEditingController(text: widget.facility.specialties.join(', '));
  late final _equipment = TextEditingController(text: widget.facility.equipmentList.join(', '));
  late FacilityType _type = widget.facility.facilityType;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _emergency.dispose();
    _capacity.dispose();
    _specialties.dispose();
    _equipment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.facility.copyWith(
      facilityName: _name.text.trim(),
      address: _address.text.trim(),
      contactNumber: _phone.text.trim(),
      emergencyContactNumber: _emergency.text.trim(),
      capacity: int.tryParse(_capacity.text) ?? widget.facility.capacity,
      specialties: _specialties.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      equipmentList: _equipment.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      facilityType: _type,
      updatedAt: DateTime.now(),
    );
    await context.read<FacilityProvider>().updateFacility(updated);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingL,
        right: AppDimensions.paddingL,
        top: AppDimensions.paddingL,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppDimensions.paddingL,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('Edit Facility', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppDimensions.paddingL),
          AppTextField(label: 'Name', controller: _name),
          const SizedBox(height: AppDimensions.paddingM),
          AppDropdownField<FacilityType>(
            label: 'Facility Type',
            value: _type,
            prefixIcon: Icons.local_hospital_outlined,
            items: FacilityType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? FacilityType.hospital),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          AppTextField(label: 'Address', controller: _address),
          const SizedBox(height: AppDimensions.paddingM),
          AppTextField(label: 'Phone', controller: _phone),
          const SizedBox(height: AppDimensions.paddingM),
          AppTextField(label: 'Emergency Phone', controller: _emergency),
          const SizedBox(height: AppDimensions.paddingM),
          AppTextField(
            label: 'Capacity',
            controller: _capacity,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          AppTextField(
            label: 'Specialties (comma separated)',
            controller: _specialties,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          AppTextField(
            label: 'Equipment (comma separated)',
            controller: _equipment,
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          PrimaryButton(label: 'Save', onPressed: _save, isLoading: _saving),
        ],
      ),
    );
  }
}
