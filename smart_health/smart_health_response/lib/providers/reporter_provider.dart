import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/configuration/app_config.dart';
import '../core/configuration/geo_point_extensions.dart';
import '../core/constants/enums.dart';
import '../models/attachment_model.dart';
import '../models/emergency_case_model.dart';
import '../models/alert_history_model.dart';
import '../services/service_locator.dart';
import '../utils/distance_calculator.dart';
import '../utils/helpers.dart';

class ReporterProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  EmergencyCase? _activeCase;
  List<EmergencyCase> _myCases = [];
  StreamSubscription<List<EmergencyCase>>? _casesSub;

  bool get isLoading => _isLoading;
  String? get error => _error;
  EmergencyCase? get activeCase => _activeCase;
  List<EmergencyCase> get myCases => _myCases;

  void watchMyCases(String reporterId) {
    _casesSub?.cancel();
    _casesSub = sl.cases.watchByReporter(reporterId).listen((cases) {
      _myCases = cases;
      notifyListeners();
    });
  }

  Future<EmergencyCase?> submitSos({
    required String reporterId,
    required GeoPoint location,
    required IncidentType type,
    required String description,
    String? patientName,
    File? photoFile,
    File? voiceFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final c = await sl.cases.createCase(
        reporterId: reporterId,
        location: location,
        type: type,
        description: description,
        patientName: patientName,
      );
      _activeCase = c;
      _error = null;

      // ── Upload attachments to file server ──────────────────────────
      final attachments = <Attachment>[];

      if (photoFile != null) {
        final attachId = Helpers.generateId();
        final relativePath = await sl.storage.uploadAttachment(
          c.caseId,
          attachId,
          photoFile,
        );
        attachments.add(Attachment(
          attachmentId: attachId,
          attachmentType: AttachmentType.photo,
          attachmentURL: relativePath,
          uploadedAt: DateTime.now(),
        ));
      }

      if (voiceFile != null) {
        final attachId = Helpers.generateId();
        final relativePath = await sl.storage.uploadAttachment(
          c.caseId,
          attachId,
          voiceFile,
        );
        attachments.add(Attachment(
          attachmentId: attachId,
          attachmentType: AttachmentType.voice,
          attachmentURL: relativePath,
          uploadedAt: DateTime.now(),
        ));
      }

      if (attachments.isNotEmpty) {
        await sl.cases.addAttachments(c.caseId, attachments);
        _activeCase = c.copyWith(attachments: attachments);
      }

      // ── Audit log ──────────────────────────────────────────────────
      await sl.audit.log(
        userId: reporterId,
        action: AuditActionType.alertCreation,
        resourceType: 'case',
        resourceId: c.caseId,
        details: 'SOS submitted: ${type.name}',
      );

      // ── Notify nearby responders ──────────────────────────────────
      final nearby = await sl.responders.findNearbyAvailable(
        location,
        AppConfig.initialAlertRadiusKm,
      );
      for (final r in nearby) {
        final dist = DistanceCalculator.haversineKm(
          location.toLatLng(),
          r.currentLocation!.toLatLng(),
        );
        await sl.alerts.createAlert(
          AlertHistory(
            alertId:
                'alert_${DateTime.now().millisecondsSinceEpoch}_${r.responderId}',
            caseId: c.caseId,
            responderId: r.responderId,
            alertSentAt: DateTime.now(),
            distance: dist,
            acceptanceStatus: AlertStatus.pending,
            alertType: AlertType.inApp,
          ),
        );
        await sl.notifications.push(
          userId: r.userId,
          title: 'Emergency Alert',
          body: '${type.label} case ${dist.toStringAsFixed(1)} km away',
          caseId: c.caseId,
          type: 'alert',
        );
      }

      return _activeCase;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearActive() {
    _activeCase = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _casesSub?.cancel();
    super.dispose();
  }
}
