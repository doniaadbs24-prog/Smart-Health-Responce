import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';
import '../models/emergency_case_model.dart';
import '../models/facility_model.dart';
import '../services/service_locator.dart';

class FacilityProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  FacilityModel? _facility;
  List<EmergencyCase> _allCases = [];
  Set<String> _knownIncomingIds = {};
  StreamSubscription<List<EmergencyCase>>? _casesSub;

  bool get isLoading => _isLoading;
  String? get error => _error;
  FacilityModel? get facility => _facility;

  /// All cases in the system.
  List<EmergencyCase> get allCases => _allCases;

  /// Incoming: cases that have a responder assigned / in-progress / handover started
  /// (patient is en route to a facility).
  List<EmergencyCase> get incomingCases => _allCases
      .where((c) =>
          c.caseStatus == CaseStatus.responderAssigned ||
          c.caseStatus == CaseStatus.inProgress ||
          c.caseStatus == CaseStatus.handoverStarted)
      .toList();

  /// Current: cases that have been received at the facility or are under treatment.
  List<EmergencyCase> get currentCases => _allCases
      .where((c) =>
          c.caseStatus == CaseStatus.receivedAtFacility ||
          c.caseStatus == CaseStatus.inTreatment)
      .toList();

  /// Closed cases count.
  List<EmergencyCase> get closedCases =>
      _allCases.where((c) => c.caseStatus == CaseStatus.closed).toList();

  int get aedCount => 0;
  int get availableBeds => _facility?.availableBeds ?? 0;
  bool get isAvailable => availableBeds > 0;
  int get totalCasesHandled => _allCases.length;

  Future<void> load(String facilityId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _facility = await sl.facilities.getById(facilityId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();

    // Watch ALL cases so the facility can see everything happening.
    _casesSub?.cancel();
    _casesSub = sl.cases.watchAll().listen((cases) {
      final incoming = cases
          .where((c) =>
              c.caseStatus == CaseStatus.responderAssigned ||
              c.caseStatus == CaseStatus.inProgress ||
              c.caseStatus == CaseStatus.handoverStarted)
          .toList();

      // Notify for new incoming patients.
      final newOnes =
          incoming.where((c) => !_knownIncomingIds.contains(c.caseId)).toList();
      for (final c in newOnes) {
        sl.notifications.showLocalNotification(
          title: 'Incoming Patient',
          body: '${c.incidentType.label} en route',
          payload: c.caseId,
        );
      }
      _knownIncomingIds = incoming.map((c) => c.caseId).toSet();

      _allCases = cases;
      notifyListeners();
    });
  }

  Future<void> updateCaseStatus(String caseId, CaseStatus status) async {
    await sl.cases.updateStatus(caseId, status);
  }

  /// Update the facility's own profile data in Firestore.
  Future<void> updateFacility(FacilityModel updated) async {
    try {
      await sl.facilities.update(updated);
      _facility = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _casesSub?.cancel();
    super.dispose();
  }
}
