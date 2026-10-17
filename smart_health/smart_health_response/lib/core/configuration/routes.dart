class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String howItWorks = '/how-it-works';
  static const String selectRole = '/select-role';

  static const String login = '/auth/login';
  static const String createAccount = '/auth/create-account';
  static const String forgotPassword = '/auth/forgot-password';
  static const String otpVerification = '/auth/otp';
  static const String emergencyAccessBefore = '/auth/emergency-access-before';
  static const String emergencyAccess = '/auth/emergency-access';

  static const String reporterShell = '/reporter';
  static const String reporterDashboard = '/reporter/dashboard';
  static const String sosAlert = '/reporter/sos';
  static const String caseTracking = '/reporter/tracking';
  static const String chatWithResponder = '/reporter/chat';
  static const String caseHistory = '/reporter/history';
  static const String serviceRating = '/reporter/rating';
  static const String reporterProfile = '/reporter/profile';
  static const String firstAidList = '/reporter/first-aid';
  static const String firstAidDetail = '/reporter/first-aid/detail';
  static const String firstAidVideo = '/reporter/first-aid/video';
  static const String cprGuide = '/reporter/first-aid/cpr';
  static const String chokingGuide = '/reporter/first-aid/choking';
  static const String bleedingGuide = '/reporter/first-aid/bleeding';
  static const String burnsGuide = '/reporter/first-aid/burns';
  static const String shockGuide = '/reporter/first-aid/shock';

  static const String responderShell = '/responder';
  static const String responderDashboard = '/responder/dashboard';
  static const String alertNotification = '/responder/alert';
  static const String receivingCase = '/responder/receiving';
  static const String caseDetails = '/responder/case-details';
  static const String nearbyCases = '/responder/nearby';
  static const String caseTrackDetails = '/responder/track-details';
  static const String navigationToCase = '/responder/navigate';
  static const String medicalProtocol = '/responder/protocol';
  static const String handover = '/responder/handover';
  static const String closeCase = '/responder/close-case';
  static const String rejectReason = '/responder/reject';
  static const String responderCommunication = '/responder/communication';
  static const String responderProfile = '/responder/profile';
  static const String alertStatistics = '/responder/statistics';

  static const String facilityShell = '/facility';
  static const String facilityDashboard = '/facility/dashboard';
  static const String facilityProfile = '/facility/profile';
  static const String incomingCase = '/facility/incoming';
  static const String facilityResponderTracking = '/facility/tracking';
  static const String facilityCommunication = '/facility/communication';
  static const String patientReception = '/facility/reception';
  static const String caseStatusUpdate = '/facility/case-status';
  static const String facilityReports = '/facility/reports';
  static const String facilityFeedback = '/facility/feedback';

  static const String adminShell = '/admin';
  static const String adminConsole = '/admin/console';
  static const String manageUsers = '/admin/users';
  static const String manageReporters = '/admin/reporters';
  static const String manageResponders = '/admin/responders';
  static const String responderDetails = '/admin/responder-details';
  static const String addResponder = '/admin/responders/add';
  static const String editResponder = '/admin/responders/edit';
  static const String manageFacilities = '/admin/facilities';
  static const String addFacility = '/admin/facilities/add';
  static const String editFacility = '/admin/facilities/edit';
  static const String manageAEDs = '/admin/aeds';
  static const String editAed = '/admin/aeds/edit';
  static const String manageCases = '/admin/cases';
  static const String liveIncidentMap = '/admin/live-map';
  static const String systemLog = '/admin/system-log';
  static const String reports = '/admin/reports';
  static const String emergencyBroadcast = '/admin/broadcast';
  static const String manageFirstAid = '/admin/first-aid';
  static const String editFirstAid = '/admin/first-aid/edit';
  static const String dataManagement = '/admin/data';
  static const String adminProfile = '/admin/profile';

  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String feedback = '/feedback';
  static const String moreMenu = '/more';
  static const String about = '/about';
  static const String help = '/help';
}
