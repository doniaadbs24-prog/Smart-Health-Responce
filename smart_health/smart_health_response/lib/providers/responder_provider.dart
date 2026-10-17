import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants/enums.dart';
import '../models/emergency_case_model.dart';
import '../models/responder_model.dart';
import '../services/service_locator.dart';

class ResponderProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAvailable = true;
  String? _error;
  ResponderModel? _profile;
  List<EmergencyCase> _activeCases = [];
  List<EmergencyCase> _nearbyAlerts = [];
  Set<String> _knownAlertCaseIds = {};
  StreamSubscription<List<EmergencyCase>>? _activeSub;
  StreamSubscription<List<EmergencyCase>>? _pendingSub;
  StreamSubscription<LatLng>? _locationSub;
  DateTime _lastLocationWrite = DateTime.fromMillisecondsSinceEpoch(0);

  bool get isLoading => _isLoading;
  bool get isAvailable => _isAvailable;
  String? get error => _error;
  ResponderModel? get profile => _profile;
  List<EmergencyCase> get activeCases => _activeCases;
  List<EmergencyCase> get nearbyAlerts => _nearbyAlerts;

  Future<void> toggleAvailability() async {
    if (_profile == null) return;
    _isAvailable = !_isAvailable;
    notifyListeners();
    await sl.responders.updateAvailability(_profile!.responderId, _isAvailable);
    if (_isAvailable) {
      _startLocationStream();
    } else {
      _stopLocationStream();
    }
  }

  Future<void> load(String responderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await sl.responders.getById(responderId);
      _isAvailable = _profile?.isAvailable ?? true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();

    _activeSub?.cancel();
    _activeSub = sl.cases.watchByResponder(responderId).listen((cases) {
      _activeCases = cases;
      notifyListeners();
    });
    _pendingSub?.cancel();
    _pendingSub = sl.cases.watchPendingAlerts().listen(_onPendingAlerts);

    if (_isAvailable) _startLocationStream();
  }

  void _onPendingAlerts(List<EmergencyCase> cases) {
    final newAlerts = cases.where((c) => !_knownAlertCaseIds.contains(c.caseId)).toList();
    for (final c in newAlerts) {
      sl.notifications.showLocalNotification(
        title: 'Emergency Alert',
        body: '${c.incidentType.label} reported nearby',
        payload: c.caseId,
      );
    }
    _knownAlertCaseIds = cases.map((c) => c.caseId).toSet();
    _nearbyAlerts = cases;
    notifyListeners();
  }

  void _startLocationStream() {
    if (_profile == null) return;
    _locationSub?.cancel();
    _locationSub = sl.location.watchPosition().listen((pos) async {
      // Throttle Firestore writes to once every 30 seconds.
      final now = DateTime.now();
      if (now.difference(_lastLocationWrite).inSeconds < 30) return;
      _lastLocationWrite = now;
      try {
        await sl.responders.updateLocation(
          _profile!.responderId,
          GeoPoint(pos.latitude, pos.longitude),
        );
      } catch (_) {/* Ignore transient write failures. */}
    });
  }

  void _stopLocationStream() {
    _locationSub?.cancel();
    _locationSub = null;
  }

  Future<void> acceptAlert(String caseId) async {
    if (_profile == null) return;
    await sl.cases.assignResponder(caseId, _profile!.responderId);
  }

  Future<void> rejectAlert(String caseId, String reason) async {
    _nearbyAlerts.removeWhere((c) => c.caseId == caseId);
    notifyListeners();
  }

  Future<void> closeCase(String caseId) async {
    await sl.cases.closeCase(caseId);
  }

  @override
  void dispose() {
    _activeSub?.cancel();
    _pendingSub?.cancel();
    _locationSub?.cancel();
    super.dispose();
  }
}
