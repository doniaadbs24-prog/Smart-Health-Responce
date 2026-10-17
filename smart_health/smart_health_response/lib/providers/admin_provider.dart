import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';
import '../models/aed_model.dart';
import '../models/emergency_case_model.dart';
import '../models/facility_model.dart';
import '../models/reporter_model.dart';
import '../models/responder_model.dart';
import '../models/user_model.dart';
import '../services/service_locator.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<UserModel> _users = [];
  List<ReporterModel> _reporters = [];
  List<ResponderModel> _responders = [];
  List<FacilityModel> _facilities = [];
  List<Aed> _aeds = [];
  List<EmergencyCase> _allCases = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get users => _users;
  List<ReporterModel> get reporters => _reporters;
  List<ResponderModel> get responders => _responders;
  List<FacilityModel> get facilities => _facilities;
  List<Aed> get aeds => _aeds;
  List<EmergencyCase> get allCases => _allCases;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await sl.users.getAll();
      _reporters = await sl.reporters.getAll();
      _responders = await sl.responders.getAll();
      _facilities = await sl.facilities.getAll();
      _aeds = await sl.aeds.getAll();
      _allCases = await sl.cases.getAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Responder management ───────────────────────────────────────────
  Future<void> approveResponder(String responderId) async {
    final r = _responders.firstWhere((x) => x.responderId == responderId);
    await sl.responders.update(
      r.copyWith(isApproved: true, approvalDate: DateTime.now()),
    );
    await sl.audit.log(
      userId: sl.auth.currentUser?.userId ?? 'admin',
      action: AuditActionType.approvalAction,
      resourceType: 'responder',
      resourceId: responderId,
      details: 'approved',
    );
    await loadAll();
  }

  Future<void> rejectResponder(String responderId) async {
    await sl.responders.delete(responderId);
    await sl.audit.log(
      userId: sl.auth.currentUser?.userId ?? 'admin',
      action: AuditActionType.approvalAction,
      resourceType: 'responder',
      resourceId: responderId,
      details: 'rejected',
    );
    await loadAll();
  }

  // ── Facility management ────────────────────────────────────────────
  Future<void> deleteFacility(String id) async {
    await sl.facilities.delete(id);
    await loadAll();
  }

  Future<void> addFacility(FacilityModel facility) async {
    await sl.facilities.create(facility);
    await loadAll();
  }

  Future<void> updateFacility(FacilityModel facility) async {
    await sl.facilities.update(facility);
    await loadAll();
  }

  // ── AED management ─────────────────────────────────────────────────
  Future<void> addAed(Aed aed) async {
    await sl.aeds.create(aed);
    await loadAll();
  }

  Future<void> updateAed(Aed aed) async {
    await sl.aeds.update(aed);
    await loadAll();
  }

  Future<void> deleteAed(String id) async {
    await sl.aeds.delete(id);
    await loadAll();
  }

  // ── Case management ────────────────────────────────────────────────
  Future<void> updateCaseStatus(String caseId, CaseStatus status) async {
    await sl.cases.updateStatus(caseId, status);
    await sl.audit.log(
      userId: sl.auth.currentUser?.userId ?? 'admin',
      action: AuditActionType.dataModification,
      resourceType: 'case',
      resourceId: caseId,
      details: 'status changed to ${status.name}',
    );
    await loadAll();
  }

  Future<void> assignFacilityToCase(String caseId, String facilityId) async {
    await sl.cases.assignFacility(caseId, facilityId);
    await sl.audit.log(
      userId: sl.auth.currentUser?.userId ?? 'admin',
      action: AuditActionType.dataModification,
      resourceType: 'case',
      resourceId: caseId,
      details: 'assigned facility $facilityId',
    );
    await loadAll();
  }

  Future<void> deleteCase(String caseId) async {
    await sl.cases.deleteCase(caseId);
    await sl.audit.log(
      userId: sl.auth.currentUser?.userId ?? 'admin',
      action: AuditActionType.dataModification,
      resourceType: 'case',
      resourceId: caseId,
      details: 'case deleted',
    );
    await loadAll();
  }
}
