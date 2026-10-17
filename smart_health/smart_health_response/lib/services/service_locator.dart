import 'aed_service.dart';
import 'alert_history_service.dart';
import 'audit_service.dart';
import 'auth_service.dart';
import 'case_closure_service.dart';
import 'communication_service.dart';
import 'emergency_case_service.dart';
import 'facility_service.dart';
import 'first_aid_service.dart';
import 'handover_service.dart';
import 'location_service.dart';
import 'maps_service.dart';
import 'notification_service.dart';
import 'rating_service.dart';
import 'reporter_service.dart';
import 'responder_service.dart';
import 'storage_service.dart';
import 'system_config_service.dart';
import 'user_service.dart';

class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  final AuthService auth = AuthService();
  final UserService users = UserService();
  final ReporterService reporters = ReporterService();
  final ResponderService responders = ResponderService();
  final FacilityService facilities = FacilityService();
  final EmergencyCaseService cases = EmergencyCaseService();
  final AlertHistoryService alerts = AlertHistoryService();
  final CommunicationService chat = CommunicationService();
  final HandoverService handovers = HandoverService();
  final CaseClosureService closures = CaseClosureService();
  final AedService aeds = AedService();
  final RatingService ratings = RatingService();
  final NotificationService notifications = NotificationService();
  final AuditService audit = AuditService();
  final SystemConfigService systemConfig = SystemConfigService();
  final StorageService storage = StorageService();
  final LocationService location = LocationService();
  final MapsService maps = MapsService();
  final FirstAidService firstAid = FirstAidService();
}

ServiceLocator get sl => ServiceLocator.instance;
