enum UserRole {
  reporter,
  responder,
  facility,
  admin,
}

enum CaseStatus {
  created,
  alertSent,
  responderAssigned,
  inProgress,
  handoverStarted,
  receivedAtFacility,
  inTreatment,
  closed,
  cancelled,
}

enum IncidentType {
  trafficAccident,
  cardiacArrest,
  breathingDifficulty,
  severeBleed,
  burns,
  choking,
  other,
}

enum AlertStatus {
  pending,
  accepted,
  rejected,
  expired,
}

enum AlertType {
  pushNotification,
  sms,
  inApp,
}

enum CaseOutcome {
  patientStable,
  transferredToHospital,
  patientDeceased,
  caseCancelled,
  other,
}

enum CertificationType {
  cpr,
  firstAid,
  advanced,
}

enum QualificationLevel {
  basic,
  intermediate,
  advanced,
}

enum BloodType {
  aPos,
  aNeg,
  bPos,
  bNeg,
  oPos,
  oNeg,
  abPos,
  abNeg,
}

enum Gender {
  male,
  female,
  other,
}

enum AttachmentType {
  photo,
  voice,
  video,
  document,
}

enum FacilityType {
  hospital,
  clinic,
  medicalCenter,
}

enum MessageType {
  chat,
  voiceCall,
  systemMessage,
}

enum SenderType {
  reporter,
  responder,
  facility,
  admin,
  system,
}

enum FirstAidType {
  cpr,
  choking,
  bleeding,
  burns,
  shock,
  other,
}

enum AuditActionType {
  login,
  logout,
  dataModification,
  dataAccess,
  alertCreation,
  approvalAction,
  systemAction,
}

enum AuditStatus {
  success,
  failure,
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.reporter:
        return 'Reporter';
      case UserRole.responder:
        return 'Responder';
      case UserRole.facility:
        return 'Receiving Facility';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}

extension CaseStatusX on CaseStatus {
  String get label {
    switch (this) {
      case CaseStatus.created:
        return 'Created';
      case CaseStatus.alertSent:
        return 'Alert Sent';
      case CaseStatus.responderAssigned:
        return 'Responder Assigned';
      case CaseStatus.inProgress:
        return 'In Progress';
      case CaseStatus.handoverStarted:
        return 'Handover Started';
      case CaseStatus.receivedAtFacility:
        return 'Received at Facility';
      case CaseStatus.inTreatment:
        return 'In Treatment';
      case CaseStatus.closed:
        return 'Closed';
      case CaseStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension IncidentTypeX on IncidentType {
  String get label {
    switch (this) {
      case IncidentType.trafficAccident:
        return 'Traffic Accident';
      case IncidentType.cardiacArrest:
        return 'Cardiac Arrest';
      case IncidentType.breathingDifficulty:
        return 'Breathing Difficulty';
      case IncidentType.severeBleed:
        return 'Severe Bleeding';
      case IncidentType.burns:
        return 'Burns';
      case IncidentType.choking:
        return 'Choking';
      case IncidentType.other:
        return 'Other';
    }
  }
}

extension BloodTypeX on BloodType {
  String get label {
    switch (this) {
      case BloodType.aPos:
        return 'A+';
      case BloodType.aNeg:
        return 'A-';
      case BloodType.bPos:
        return 'B+';
      case BloodType.bNeg:
        return 'B-';
      case BloodType.oPos:
        return 'O+';
      case BloodType.oNeg:
        return 'O-';
      case BloodType.abPos:
        return 'AB+';
      case BloodType.abNeg:
        return 'AB-';
    }
  }
}

extension FirstAidTypeX on FirstAidType {
  String get label {
    switch (this) {
      case FirstAidType.cpr:
        return 'CPR';
      case FirstAidType.choking:
        return 'Choking';
      case FirstAidType.bleeding:
        return 'Bleeding';
      case FirstAidType.burns:
        return 'Burns';
      case FirstAidType.shock:
        return 'Shock';
      case FirstAidType.other:
        return 'Other';
    }
  }
}

T enumFromString<T>(List<T> values, String? raw, T fallback) {
  if (raw == null) return fallback;
  for (final v in values) {
    if (v.toString().split('.').last == raw) return v;
  }
  return fallback;
}

String enumToString<T>(T value) => value.toString().split('.').last;
