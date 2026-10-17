import 'package:go_router/go_router.dart';
import 'core/configuration/routes.dart';
import 'core/constants/enums.dart';
import 'models/aed_model.dart';
import 'models/emergency_case_model.dart';
import 'models/facility_model.dart';
import 'models/first_aid_guide_model.dart';
import 'models/responder_model.dart';
import 'screens/admin/add_facility_screen.dart';
import 'screens/admin/admin_profile_screen.dart';
import 'screens/admin/add_responder_screen.dart';
import 'screens/admin/admin_console_screen.dart';
import 'screens/admin/data_management_screen.dart';
import 'screens/admin/edit_aed_screen.dart';
import 'screens/admin/edit_facility_screen.dart';
import 'screens/admin/edit_first_aid_screen.dart';
import 'screens/admin/edit_responder_screen.dart';
import 'screens/admin/emergency_broadcast_screen.dart';
import 'screens/admin/live_incident_map_screen.dart';
import 'screens/admin/manage_aeds_screen.dart';
import 'screens/admin/manage_cases_screen.dart';
import 'screens/admin/manage_facilities_screen.dart';
import 'screens/admin/manage_first_aid_screen.dart';
import 'screens/admin/manage_reporters_screen.dart';
import 'screens/admin/manage_responders_screen.dart';
import 'screens/admin/manage_users_screen.dart';
import 'screens/admin/reports_screen.dart';
import 'screens/admin/responder_details_screen.dart';
import 'screens/admin/system_log_screen.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/emergency_access_before_screen.dart';
import 'screens/auth/emergency_access_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/common/about_screen.dart';
import 'screens/common/feedback_screen.dart';
import 'screens/common/help_screen.dart';
import 'screens/common/more_menu_screen.dart';
import 'screens/common/notifications_screen.dart';
import 'screens/common/settings_screen.dart';
import 'screens/facility/case_status_update_screen.dart';
import 'screens/facility/facility_communication_screen.dart';
import 'screens/facility/facility_dashboard_screen.dart';
import 'screens/facility/facility_feedback_screen.dart';
import 'screens/facility/facility_profile_screen.dart';
import 'screens/facility/facility_reports_screen.dart';
import 'screens/facility/facility_responder_tracking_screen.dart';
import 'screens/facility/incoming_case_screen.dart';
import 'screens/facility/patient_reception_screen.dart';
import 'screens/reporter/case_history_screen.dart';
import 'screens/reporter/case_tracking_screen.dart';
import 'screens/reporter/chat_with_responder_screen.dart';
import 'screens/reporter/first_aid/first_aid_detail_screen.dart';
import 'screens/reporter/first_aid/first_aid_list_screen.dart';
import 'screens/reporter/reporter_dashboard_screen.dart';
import 'screens/reporter/reporter_profile_screen.dart';
import 'screens/reporter/service_rating_screen.dart';
import 'screens/reporter/sos_alert_screen.dart';
import 'screens/responder/alert_notification_screen.dart';
import 'screens/responder/alert_statistics_screen.dart';
import 'screens/responder/case_details_screen.dart';
import 'screens/responder/case_track_details_screen.dart';
import 'screens/responder/close_case_screen.dart';
import 'screens/responder/handover_screen.dart';
import 'screens/responder/medical_protocol_screen.dart';
import 'screens/responder/navigation_to_case_screen.dart';
import 'screens/responder/nearby_cases_screen.dart';
import 'screens/responder/receiving_case_screen.dart';
import 'screens/responder/reject_reason_screen.dart';
import 'screens/responder/responder_communication_screen.dart';
import 'screens/responder/responder_dashboard_screen.dart';
import 'screens/responder/responder_profile_screen.dart';
import 'screens/shared/how_it_works_screen.dart';
import 'screens/shared/onboarding_screen.dart';
import 'screens/shared/select_role_screen.dart';
import 'screens/shared/splash_screen.dart';
import 'providers/auth_provider.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(AuthProvider auth) => GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // Splash + onboarding are bootstrap screens; let them run their own logic.
      if (loc == AppRoutes.splash || loc == AppRoutes.onboarding) return null;

      final loggedIn = auth.isAuthenticated;
      final isAuthArea = loc.startsWith('/auth') ||
          loc == AppRoutes.selectRole ||
          loc == AppRoutes.howItWorks;

      if (!loggedIn && !isAuthArea) return AppRoutes.login;
      if (loggedIn && isAuthArea) {
        switch (auth.role) {
          case UserRole.reporter:
            return AppRoutes.reporterDashboard;
          case UserRole.responder:
            return AppRoutes.responderDashboard;
          case UserRole.facility:
            return AppRoutes.facilityDashboard;
          case UserRole.admin:
            return AppRoutes.adminConsole;
          case null:
            return null;
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.howItWorks, builder: (_, _) => const HowItWorksScreen()),
      GoRoute(path: AppRoutes.selectRole, builder: (_, _) => const SelectRoleScreen()),

      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: AppRoutes.createAccount, builder: (_, _) => const CreateAccountScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.otpVerification, builder: (_, _) => const OtpVerificationScreen()),
      GoRoute(
          path: AppRoutes.emergencyAccessBefore,
          builder: (_, _) => const EmergencyAccessBeforeScreen()),
      GoRoute(
          path: AppRoutes.emergencyAccess,
          builder: (_, _) => const EmergencyAccessScreen()),

      GoRoute(
          path: AppRoutes.reporterDashboard,
          builder: (_, _) => const ReporterDashboardScreen()),
      GoRoute(path: AppRoutes.sosAlert, builder: (_, _) => const SosAlertScreen()),
      GoRoute(
        path: AppRoutes.caseTracking,
        builder: (_, state) =>
            CaseTrackingScreen(caseId: state.uri.queryParameters['caseId']),
      ),
      GoRoute(
        path: AppRoutes.chatWithResponder,
        builder: (_, state) => ChatWithResponderScreen(
          emergencyCase: state.extra as EmergencyCase?,
        ),
      ),
      GoRoute(path: AppRoutes.caseHistory, builder: (_, _) => const CaseHistoryScreen()),
      GoRoute(
        path: AppRoutes.serviceRating,
        builder: (_, state) => ServiceRatingScreen(
          emergencyCase: state.extra as EmergencyCase?,
        ),
      ),
      GoRoute(
          path: AppRoutes.reporterProfile,
          builder: (_, _) => const ReporterProfileScreen()),
      GoRoute(path: AppRoutes.firstAidList, builder: (_, _) => const FirstAidListScreen()),
      GoRoute(
        path: AppRoutes.firstAidDetail,
        builder: (_, state) =>
            FirstAidDetailScreen(guide: state.extra as FirstAidGuide),
      ),

      GoRoute(
          path: AppRoutes.responderDashboard,
          builder: (_, _) => const ResponderDashboardScreen()),
      GoRoute(
        path: AppRoutes.alertNotification,
        builder: (_, state) => AlertNotificationScreen(
          emergencyCase: state.extra as EmergencyCase,
        ),
      ),
      GoRoute(path: AppRoutes.receivingCase, builder: (_, _) => const ReceivingCaseScreen()),
      GoRoute(
        path: AppRoutes.caseDetails,
        builder: (_, state) =>
            CaseDetailsScreen(emergencyCase: state.extra as EmergencyCase?),
      ),
      GoRoute(path: AppRoutes.nearbyCases, builder: (_, _) => const NearbyCasesScreen()),
      GoRoute(
        path: AppRoutes.caseTrackDetails,
        builder: (_, state) =>
            CaseTrackDetailsScreen(emergencyCase: state.extra as EmergencyCase),
      ),
      GoRoute(
        path: AppRoutes.navigationToCase,
        builder: (_, state) => NavigationToCaseScreen(
          emergencyCase: state.extra as EmergencyCase?,
        ),
      ),
      GoRoute(
        path: AppRoutes.medicalProtocol,
        builder: (_, state) => MedicalProtocolScreen(
          emergencyCase: state.extra as EmergencyCase?,
        ),
      ),
      GoRoute(
        path: AppRoutes.handover,
        builder: (_, state) =>
            HandoverScreen(emergencyCase: state.extra as EmergencyCase?),
      ),
      GoRoute(
        path: AppRoutes.closeCase,
        builder: (_, state) =>
            CloseCaseScreen(emergencyCase: state.extra as EmergencyCase?),
      ),
      GoRoute(
        path: AppRoutes.rejectReason,
        builder: (_, state) =>
            RejectReasonScreen(emergencyCase: state.extra as EmergencyCase),
      ),
      GoRoute(
          path: AppRoutes.responderCommunication,
          builder: (_, _) => const ResponderCommunicationScreen()),
      GoRoute(
          path: AppRoutes.responderProfile,
          builder: (_, _) => const ResponderProfileScreen()),
      GoRoute(
          path: AppRoutes.alertStatistics,
          builder: (_, _) => const AlertStatisticsScreen()),

      GoRoute(
          path: AppRoutes.facilityDashboard,
          builder: (_, _) => const FacilityDashboardScreen()),
      GoRoute(
          path: AppRoutes.facilityProfile,
          builder: (_, _) => const FacilityProfileScreen()),
      GoRoute(
        path: AppRoutes.incomingCase,
        builder: (_, state) =>
            IncomingCaseScreen(emergencyCase: state.extra as EmergencyCase),
      ),
      GoRoute(
          path: AppRoutes.facilityResponderTracking,
          builder: (_, _) => const FacilityResponderTrackingScreen()),
      GoRoute(
          path: AppRoutes.facilityCommunication,
          builder: (_, _) => const FacilityCommunicationScreen()),
      GoRoute(
        path: AppRoutes.patientReception,
        builder: (_, state) =>
            PatientReceptionScreen(emergencyCase: state.extra as EmergencyCase?),
      ),
      GoRoute(
        path: AppRoutes.caseStatusUpdate,
        builder: (_, state) =>
            CaseStatusUpdateScreen(emergencyCase: state.extra as EmergencyCase),
      ),
      GoRoute(
          path: AppRoutes.facilityReports,
          builder: (_, _) => const FacilityReportsScreen()),
      GoRoute(
          path: AppRoutes.facilityFeedback,
          builder: (_, _) => const FacilityFeedbackScreen()),

      GoRoute(path: AppRoutes.adminConsole, builder: (_, _) => const AdminConsoleScreen()),
      GoRoute(path: AppRoutes.manageUsers, builder: (_, _) => const ManageUsersScreen()),
      GoRoute(
          path: AppRoutes.manageReporters,
          builder: (_, _) => const ManageReportersScreen()),
      GoRoute(
          path: AppRoutes.manageResponders,
          builder: (_, _) => const ManageRespondersScreen()),
      GoRoute(
        path: AppRoutes.responderDetails,
        builder: (_, state) =>
            ResponderDetailsScreen(responder: state.extra as ResponderModel),
      ),
      GoRoute(path: AppRoutes.addResponder, builder: (_, _) => const AddResponderScreen()),
      GoRoute(
        path: AppRoutes.editResponder,
        builder: (_, state) =>
            EditResponderScreen(responder: state.extra as ResponderModel),
      ),
      GoRoute(
          path: AppRoutes.manageFacilities,
          builder: (_, _) => const ManageFacilitiesScreen()),
      GoRoute(path: AppRoutes.addFacility, builder: (_, _) => const AddFacilityScreen()),
      GoRoute(
        path: AppRoutes.editFacility,
        builder: (_, state) =>
            EditFacilityScreen(facility: state.extra as FacilityModel),
      ),
      GoRoute(path: AppRoutes.manageAEDs, builder: (_, _) => const ManageAedsScreen()),
      GoRoute(
        path: AppRoutes.editAed,
        builder: (_, state) => EditAedScreen(aed: state.extra as Aed?),
      ),
      GoRoute(path: AppRoutes.manageCases, builder: (_, _) => const ManageCasesScreen()),
      GoRoute(
          path: AppRoutes.liveIncidentMap,
          builder: (_, _) => const LiveIncidentMapScreen()),
      GoRoute(path: AppRoutes.systemLog, builder: (_, _) => const SystemLogScreen()),
      GoRoute(path: AppRoutes.reports, builder: (_, _) => const ReportsScreen()),
      GoRoute(
          path: AppRoutes.emergencyBroadcast,
          builder: (_, _) => const EmergencyBroadcastScreen()),
      GoRoute(
          path: AppRoutes.manageFirstAid,
          builder: (_, _) => const ManageFirstAidScreen()),
      GoRoute(
        path: AppRoutes.editFirstAid,
        builder: (_, state) =>
            EditFirstAidScreen(guide: state.extra as FirstAidGuide),
      ),
      GoRoute(
          path: AppRoutes.dataManagement,
          builder: (_, _) => const DataManagementScreen()),
      GoRoute(
          path: AppRoutes.adminProfile,
          builder: (_, _) => const AdminProfileScreen()),

      GoRoute(path: AppRoutes.notifications, builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: AppRoutes.feedback, builder: (_, _) => const FeedbackScreen()),
      GoRoute(path: AppRoutes.moreMenu, builder: (_, _) => const MoreMenuScreen()),
      GoRoute(path: AppRoutes.about, builder: (_, _) => const AboutScreen()),
      GoRoute(path: AppRoutes.help, builder: (_, _) => const HelpScreen()),
    ],
  );
}

