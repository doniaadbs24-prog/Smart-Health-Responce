import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/app_config.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/geo_point_extensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../models/responder_model.dart';
import '../../providers/case_provider.dart';
import '../../services/service_locator.dart';
import '../../utils/distance_calculator.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/map/map_markers.dart';
import '../../widgets/map/osm_map_widget.dart';
import '../../widgets/status/eta_widget.dart';

class CaseTrackingScreen extends StatefulWidget {
  final String? caseId;
  const CaseTrackingScreen({super.key, this.caseId});

  @override
  State<CaseTrackingScreen> createState() => _CaseTrackingScreenState();
}

class _CaseTrackingScreenState extends State<CaseTrackingScreen> {
  ResponderModel? _responder;
  StreamSubscription<ResponderModel?>? _responderSub;
  String? _trackedResponderId;

  @override
  void initState() {
    super.initState();
    if (widget.caseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CaseProvider>().watchCase(widget.caseId!);
      });
    }
  }

  void _trackResponder(String responderId) {
    if (_trackedResponderId == responderId) return;
    _trackedResponderId = responderId;
    _responderSub?.cancel();
    _responderSub = sl.responders.watchById(responderId).listen((r) {
      if (!mounted) return;
      setState(() => _responder = r);
    });
  }

  @override
  void dispose() {
    _responderSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CaseProvider>().current;
    if (c?.responderId != null) _trackResponder(c!.responderId!);

    final incidentLatLng =
        c?.incidentLocation.toLatLng() ?? AppConfig.defaultMapCenter;
    final responderLatLng = _responder?.currentLocation?.toLatLng();

    final distanceKm = responderLatLng == null
        ? null
        : DistanceCalculator.haversineKm(incidentLatLng, responderLatLng);
    // ~40 km/h average urban driving speed.
    final etaMinutes = distanceKm == null ? null : (distanceKm / 40 * 60).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: Column(
        children: [
          SizedBox(
            height: 320,
            child: OsmMapWidget(
              center: incidentLatLng,
              markers: [
                MapMarkers.incident(incidentLatLng),
                if (responderLatLng != null) MapMarkers.responder(responderLatLng),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: c == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _bodyContent(c, distanceKm, etaMinutes),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _bodyContent(EmergencyCase c, double? distanceKm, int? etaMinutes) {
    if (c.responderId == null) {
      return [
        const SizedBox(height: AppDimensions.paddingXL),
        const Center(child: Icon(Icons.notifications_active_outlined,
            size: 48, color: AppColors.warning)),
        const SizedBox(height: AppDimensions.paddingM),
        Text('Searching for nearby responders...',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium),
      ];
    }
    final name = _responder == null ? 'Responder' : 'Responder ${c.responderId!.substring(0, 6).toUpperCase()}';
    final initials = name.split(' ').take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return [
      Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: Text(initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: AppDimensions.paddingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleMedium),
                if (_responder != null)
                  Text(
                    '${_responder!.qualificationLevel.name.toUpperCase()} · '
                    '${_responder!.averageRating.toStringAsFixed(1)} ★',
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
          if (etaMinutes != null) EtaWidget(minutes: etaMinutes),
        ],
      ),
      const SizedBox(height: AppDimensions.paddingS),
      if (distanceKm != null)
        Text('${distanceKm.toStringAsFixed(1)} km away',
            style: AppTextStyles.bodySmall),
      const SizedBox(height: AppDimensions.paddingL),
      Row(
        children: [
          Expanded(
            child: OutlinedAppButton(
              label: 'Chat',
              icon: Icons.chat_outlined,
              onPressed: () =>
                  context.push(AppRoutes.chatWithResponder, extra: c),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: PrimaryButton(
              label: 'Call',
              icon: Icons.phone_outlined,
              onPressed: () {},
            ),
          ),
        ],
      ),
      const Spacer(),
      if (c.caseStatus == CaseStatus.closed)
        PrimaryButton(
          label: 'Rate Responder',
          icon: Icons.star_outline,
          onPressed: () =>
              context.push(AppRoutes.serviceRating, extra: c),
        )
      else
        Text('Stay calm. Help is on the way.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
    ];
  }
}

