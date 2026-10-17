import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/configuration/app_config.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/geo_point_extensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reporter_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/dropdown_field.dart';
import '../../widgets/map/map_markers.dart';
import '../../widgets/map/osm_map_widget.dart';

class SosAlertScreen extends StatefulWidget {
  const SosAlertScreen({super.key});

  @override
  State<SosAlertScreen> createState() => _SosAlertScreenState();
}

class _SosAlertScreenState extends State<SosAlertScreen> {
  final _form = GlobalKey<FormState>();
  IncidentType _type = IncidentType.cardiacArrest;
  final _description = TextEditingController();
  LatLng _location = AppConfig.defaultMapCenter;

  // ── Photo ──────────────────────────────────────────────────────────
  final ImagePicker _picker = ImagePicker();
  File? _photo;

  // ── Voice ──────────────────────────────────────────────────────────
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  File? _voiceFile;

  @override
  void dispose() {
    _description.dispose();
    _recorder.dispose();
    super.dispose();
  }

  // ── Pick photo from camera or gallery ──────────────────────────────
  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  // ── Record voice toggle ────────────────────────────────────────────
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        setState(() {
          _voiceFile = File(path);
          _isRecording = false;
        });
        if (mounted) context.showSnack('Voice recorded');
      }
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          context.showSnack('Microphone permission required', isError: true);
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/sos_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      setState(() => _isRecording = true);
    }
  }

  // ── Submit SOS ─────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final reporter = context.read<ReporterProvider>();
    final c = await reporter.submitSos(
      reporterId: user.userId,
      location: _location.toGeoPoint(),
      type: _type,
      description: _description.text.trim(),
      patientName: user.fullName,
      photoFile: _photo,
      voiceFile: _voiceFile,
    );
    if (!mounted) return;
    if (c != null) {
      context.pushReplacement('${AppRoutes.caseTracking}?caseId=${c.caseId}');
    } else {
      context.showSnack(
        reporter.error ?? AppStrings.somethingWentWrong,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<ReporterProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.sosTitle)),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            children: [
              SizedBox(
                height: 220,
                child: OsmMapWidget(
                  center: _location,
                  markers: [MapMarkers.incident(_location)],
                  onTap: (_, p) => setState(() => _location = p),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'Tap on the map to adjust the incident location.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              AppDropdownField<IncidentType>(
                label: AppStrings.emergencyType,
                value: _type,
                prefixIcon: Icons.warning_amber_outlined,
                items: IncidentType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _type = v ?? IncidentType.other),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              AppTextField(
                label: AppStrings.description,
                hint: 'Describe the situation briefly',
                controller: _description,
                maxLines: 4,
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // ── Attachment buttons ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedAppButton(
                      label: _photo != null ? 'Photo ✓' : AppStrings.addPhoto,
                      icon: Icons.photo_camera_outlined,
                      onPressed: _pickPhoto,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: OutlinedAppButton(
                      label: _isRecording
                          ? 'Stop ●'
                          : _voiceFile != null
                              ? 'Voice ✓'
                              : AppStrings.recordVoice,
                      icon: _isRecording
                          ? Icons.stop_circle_outlined
                          : Icons.mic_outlined,
                      onPressed: _toggleRecording,
                    ),
                  ),
                ],
              ),

              // ── Photo preview ──
              if (_photo != null) ...[
                const SizedBox(height: AppDimensions.paddingM),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusM),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(_photo!, height: 140, fit: BoxFit.cover,
                          width: double.infinity),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.black38),
                        onPressed: () => setState(() => _photo = null),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Voice indicator ──
              if (_voiceFile != null && !_isRecording) ...[
                const SizedBox(height: AppDimensions.paddingM),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.audiotrack_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                          child: Text('Voice recording attached')),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () =>
                            setState(() => _voiceFile = null),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppDimensions.paddingXL),
              PrimaryButton(
                label: 'Send Alert',
                icon: Icons.send_outlined,
                onPressed: _submit,
                isLoading: loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
