# Smart Health Response — Flutter Implementation Plan

## Context

This is the implementation plan for **Smart Health Response (SHR)**, a Flutter mobile application built as a graduation project (Group 655, Jazan University, College of Engineering and Computer Sciences). The system bridges **Reporters** (witnesses/victims), **Responders** (trained CPR/first-aid volunteers), **Receiving Facilities** (hospitals/clinics), and **Admins** into a unified emergency-response ecosystem that reduces medical-response time during public-space emergencies.

**Source artifacts analyzed:**
- SRS: [Final_Report_GP_NewVersion- UPDATE.docx](../../../../media/mahmoud-gado/New%20Volume/mohamed%20AbdelKAreem/2025_2026_secend_term/22_SMART%20HEALTH%20RESPONSE%20/smart_health_response/Final_Report_GP_NewVersion-%20UPDATE.docx) — ~50 pages, 12 entities, 4 user roles, ~30 functional requirements, full workflows.
- Figma: `https://www.figma.com/design/lH7xHrnrU5fIx3D9mbElQv/Smart-health-app-GP` — **186 frames** across all 4 user roles, designed for iPhone 17 (440×956 / 402×874).
- Existing Flutter project: empty scaffold at [lib/main.dart](lib/main.dart). `pubspec.yaml` has no dependencies yet.

**User decisions (locked-in via clarifying questions):**
| Decision | Choice |
|---|---|
| State management | **Provider** |
| Localization | **English only** (no RTL — Arabic Figma component names are translated) |
| Map provider | **OpenStreetMap** via `flutter_map` (free, no API key) |
| Scope | **All 4 roles** in Step 1 (Reporter, Responder, Facility, Admin) |

**Scope of THIS plan: STEP 1 only — UI Build.** Complete Flutter UI (every screen, theme, widgets, navigation) using in-memory mock data. No Firebase. Outcome: a fully clickable, design-pixel-faithful app that can be demoed. Step 2 (Firebase wiring) will be planned and built as a separate task once Step 1 is approved.

**Code style guardrails (user preference):**
- Clean, minimal-comment code. No multi-paragraph docstrings, no narrating-the-obvious comments.
- Only add a single-line comment when the *why* is non-obvious (a hidden constraint or surprising choice).
- Well-named identifiers carry meaning; the code itself is the documentation.

---

## Design System (from Figma analysis)

The Figma uses a **calm, trust-conveying medical palette** dominated by deep teal/navy with a sage-green accent. Card-based layouts with rounded corners, soft shadows, and friendly geometric icons.

### Color tokens (`lib/core/configuration/colors.dart`)
| Token | Hex | Usage |
|---|---|---|
| `primary` | `#0B3142` | Headlines, primary buttons, brand "SHR", icons |
| `primaryDark` | `#062533` | Pressed states, depth |
| `primaryLight` | `#1A4756` | Hover, gradients |
| `secondary` | `#A8C5C0` | "Sign In" button, accent surfaces, sage cards |
| `secondaryDark` | `#7FA8A0` | Secondary pressed |
| `accent` | `#2BB7B0` | Stat numbers ("AED: 3"), interactive teal |
| `background` | `#F4F2EC` | App scaffold background (warm off-white) |
| `surface` | `#FFFFFF` | Cards, sheets |
| `surfaceAlt` | `#EEF1EF` | Sub-cards inside cards (Current Cases section) |
| `textPrimary` | `#0B3142` | Headings, body |
| `textSecondary` | `#5C6B72` | Subtitles, helper text |
| `textTertiary` | `#9AA5AA` | Placeholders, disabled |
| `border` | `#D9DEDB` | Card borders, dividers |
| `success` | `#2E9E5F` | Success dialogs, "Available" status |
| `warning` | `#E0A526` | Pending state, ETA warnings |
| `error` | `#D64545` | SOS button, error states, delete actions |
| `info` | `#3D7FB8` | Info banners |

### Typography (`lib/core/configuration/text_styles.dart`)
- **Font family:** Poppins (Google Fonts, via `google_fonts` package — matches Figma's clean geometric sans).
- Scale: `displayLarge 32/700` · `headlineMedium 22/700` · `titleLarge 18/600` · `bodyLarge 16/400` · `bodyMedium 14/400` · `labelLarge 14/600` · `caption 12/400`.

### Component patterns
- **Cards:** 16 px radius, 12 px padding, soft shadow (`0 2 8 rgba(11,49,66,0.08)`).
- **Buttons:** 12 px radius, 48 px height. Primary = filled teal, Secondary = sage filled, Tertiary = outlined teal.
- **Inputs:** 12 px radius, 1 px border, 48 px height, label above field.
- **Bottom nav:** 4 tabs (Facility / Tracking / Cases / Home), icon + label, active = teal, inactive = gray.
- **Status chips:** pill-shaped, "the offer", "Under treatment", "Available".

---

## Project Structure

Exactly the structure requested by the user, populated for SHR:

```
lib/
├── main.dart                              # Entry, runs runApp(SmartHealthApp())
├── app.dart                               # MaterialApp, MultiProvider, theme, routes
│
├── core/
│   ├── configuration/
│   │   ├── app_config.dart                # Env, OSM tile URL, distance limits, alert TTLs
│   │   ├── colors.dart                    # AppColors palette (table above)
│   │   ├── text_styles.dart               # AppTextStyles (Poppins scale)
│   │   ├── dimensions.dart                # AppDimensions (radii, paddings, icon sizes)
│   │   ├── theme.dart                     # AppTheme.light / .dark
│   │   ├── routes.dart                    # AppRoutes (named) + onGenerateRoute
│   │   └── firebase_options.dart          # STEP 2 — flutterfire configure output
│   ├── constants/
│   │   ├── app_strings.dart               # English UI strings
│   │   ├── app_assets.dart                # Asset path constants
│   │   ├── enums.dart                     # UserRole, CaseStatus, IncidentType, AlertStatus, CaseOutcome, CertificationType, BloodType
│   │   └── firestore_collections.dart     # Collection name constants (STEP 2)
│   └── errors/
│       ├── failure.dart                   # Failure base + AuthFailure, NetworkFailure, etc.
│       └── exceptions.dart                # Custom exceptions thrown by services
│
├── models/                                # All implement: const ctor, fromJson, toJson, copyWith, toString, ==/hashCode
│   ├── user_model.dart                    # Base User
│   ├── reporter_model.dart                # extends/composes User
│   ├── responder_model.dart
│   ├── facility_model.dart
│   ├── medical_profile_model.dart
│   ├── emergency_contact_model.dart
│   ├── certification_model.dart
│   ├── emergency_case_model.dart
│   ├── alert_history_model.dart
│   ├── communication_model.dart           # Chat message
│   ├── handover_record_model.dart
│   ├── vital_signs_model.dart
│   ├── case_closure_report_model.dart
│   ├── aed_model.dart
│   ├── rating_feedback_model.dart
│   ├── first_aid_guide_model.dart
│   ├── first_aid_step_model.dart
│   ├── attachment_model.dart
│   ├── audit_log_model.dart
│   └── system_config_model.dart
│
├── services/
│   ├── service_locator.dart               # Simple GetIt-like factory or static instances
│   ├── auth_service.dart                  # MOCK in Step 1, Firebase Auth in Step 2
│   ├── firestore_service.dart             # MOCK Step 1, real Firestore Step 2
│   ├── storage_service.dart               # MOCK Step 1, Cloud Storage Step 2
│   ├── notification_service.dart          # MOCK Step 1, FCM Step 2
│   ├── location_service.dart              # geolocator (real in both steps)
│   ├── maps_service.dart                  # OSM tile URL builder, Nominatim geocoding
│   ├── case_service.dart                  # Case lifecycle business logic
│   ├── responder_assignment_service.dart  # Haversine matching, qualification filter
│   ├── chat_service.dart                  # Realtime messages
│   ├── audit_service.dart                 # Audit logs
│   └── mock_data_service.dart             # Generates fake users/cases for STEP 1
│
├── providers/                             # Provider-based state (ChangeNotifier)
│   ├── auth_provider.dart                 # currentUser, signIn/signUp/signOut
│   ├── theme_provider.dart                # light/dark toggle
│   ├── reporter_provider.dart             # SOS submission, my cases, ratings
│   ├── responder_provider.dart            # availability toggle, alerts, my cases
│   ├── facility_provider.dart             # incoming cases, in-treatment list
│   ├── admin_provider.dart                # users, facilities, broadcasts
│   ├── case_provider.dart                 # active case detail, status, location stream
│   ├── chat_provider.dart                 # message stream per case
│   ├── notification_provider.dart         # in-app notification feed
│   └── first_aid_provider.dart            # offline guides
│
├── screens/                               # Mirrors Figma frame organization
│   ├── shared/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart         # Figma "1st page"
│   │   ├── select_role_screen.dart
│   │   └── how_it_works_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── create_account_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── otp_verification_screen.dart
│   │   ├── emergency_access_before_screen.dart
│   │   └── emergency_access_screen.dart
│   ├── reporter/
│   │   ├── reporter_dashboard_screen.dart # SOS button center stage
│   │   ├── sos_alert_screen.dart          # Submit alert form
│   │   ├── case_tracking_screen.dart      # Live responder map
│   │   ├── chat_with_responder_screen.dart
│   │   ├── case_history_screen.dart
│   │   ├── service_rating_screen.dart
│   │   ├── reporter_profile_screen.dart
│   │   └── first_aid/
│   │       ├── first_aid_list_screen.dart
│   │       ├── first_aid_detail_screen.dart
│   │       ├── first_aid_video_screen.dart
│   │       ├── cpr_guide_screen.dart
│   │       ├── choking_guide_screen.dart
│   │       ├── bleeding_guide_screen.dart
│   │       ├── burns_guide_screen.dart
│   │       └── shock_guide_screen.dart
│   ├── responder/
│   │   ├── responder_dashboard_screen.dart  # Figma "responder page file"
│   │   ├── alert_notification_screen.dart   # accept on responder
│   │   ├── receiving_case_screen.dart       # Figma "Receiving the Case"
│   │   ├── case_details_screen.dart
│   │   ├── nearby_cases_screen.dart
│   │   ├── case_track_details_screen.dart   # Figma "details case track"
│   │   ├── navigation_to_case_screen.dart
│   │   ├── medical_protocol_screen.dart
│   │   ├── handover_screen.dart             # Figma "HandOver-Reporter"
│   │   ├── close_case_screen.dart
│   │   ├── reject_reason_screen.dart
│   │   ├── responder_communication_screen.dart  # Figma "in-app-communication"
│   │   ├── responder_profile_screen.dart
│   │   └── alert_statistics_screen.dart
│   ├── facility/
│   │   ├── facility_dashboard_screen.dart   # Upcoming + Current Cases (matches Figma 02)
│   │   ├── facility_profile_screen.dart
│   │   ├── incoming_case_screen.dart
│   │   ├── facility_responder_tracking_screen.dart
│   │   ├── facility_communication_screen.dart
│   │   ├── patient_reception_screen.dart
│   │   ├── case_status_update_screen.dart
│   │   ├── facility_reports_screen.dart
│   │   └── facility_feedback_screen.dart
│   ├── admin/
│   │   ├── admin_console_screen.dart        # Figma "admin console"
│   │   ├── manage_users_screen.dart
│   │   ├── manage_reporters_screen.dart
│   │   ├── manage_responders_screen.dart
│   │   ├── responder_details_screen.dart    # Figma "Details of responder"
│   │   ├── add_responder_screen.dart
│   │   ├── edit_responder_screen.dart
│   │   ├── manage_facilities_screen.dart
│   │   ├── add_facility_screen.dart
│   │   ├── edit_facility_screen.dart
│   │   ├── manage_aeds_screen.dart
│   │   ├── edit_aed_screen.dart
│   │   ├── manage_cases_screen.dart
│   │   ├── live_incident_map_screen.dart
│   │   ├── system_log_screen.dart
│   │   ├── reports_screen.dart
│   │   ├── emergency_broadcast_screen.dart  # Figma "mass" + "cancel mass"
│   │   ├── manage_first_aid_screen.dart
│   │   ├── edit_first_aid_screen.dart
│   │   └── data_management_screen.dart
│   └── common/
│       ├── notifications_screen.dart
│       ├── settings_screen.dart
│       ├── feedback_screen.dart
│       ├── more_menu_screen.dart            # Figma "more"
│       ├── about_screen.dart
│       └── help_screen.dart
│
├── widgets/                               # Reusable design-system components
│   ├── buttons/
│   │   ├── primary_button.dart            # Filled teal
│   │   ├── secondary_button.dart          # Filled sage
│   │   ├── outlined_button_widget.dart
│   │   ├── icon_button_widget.dart
│   │   ├── sos_button.dart                # Big red pulsing emergency
│   │   └── fab_widget.dart
│   ├── cards/
│   │   ├── feature_card.dart              # "Quick Alert" / "Instant Response" rows
│   │   ├── case_card.dart                 # Generic case card
│   │   ├── upcoming_case_card.dart        # Patient name + ETA + Show Cases (Figma 02)
│   │   ├── current_case_card.dart         # "the offer" + name + status
│   │   ├── responder_card.dart            # كارد مستجيب
│   │   ├── facility_card.dart             # كارد مستشفى
│   │   ├── reporter_card.dart             # كرت المبلغين
│   │   ├── aed_card.dart
│   │   ├── stat_tile.dart                 # AED 3 / Beds 8 / Available
│   │   └── notification_card.dart
│   ├── inputs/
│   │   ├── app_text_field.dart
│   │   ├── password_field.dart
│   │   ├── phone_field.dart
│   │   ├── search_field.dart
│   │   ├── dropdown_field.dart
│   │   ├── date_picker_field.dart
│   │   ├── otp_field.dart
│   │   └── file_upload_field.dart
│   ├── layout/
│   │   ├── app_scaffold.dart
│   │   ├── app_bar_widget.dart
│   │   ├── bottom_nav_bar.dart            # 4-tab nav
│   │   ├── drawer_widget.dart
│   │   ├── section_header.dart
│   │   └── empty_state.dart
│   ├── dialogs/
│   │   ├── confirm_dialog.dart
│   │   ├── success_dialog.dart            # Figma "success message"
│   │   ├── error_dialog.dart
│   │   ├── delete_confirm_dialog.dart     # Figma "confirm delete popup"
│   │   ├── reject_confirm_dialog.dart     # Figma "confirm reject responder popup"
│   │   └── loading_dialog.dart
│   ├── status/
│   │   ├── status_chip.dart               # Case status pill
│   │   ├── rating_stars.dart              # 5-star selector + display
│   │   ├── eta_widget.dart
│   │   ├── progress_indicator.dart
│   │   └── badge_widget.dart
│   ├── map/
│   │   ├── osm_map_widget.dart            # flutter_map wrapper
│   │   ├── case_marker.dart
│   │   ├── responder_marker.dart
│   │   ├── facility_marker.dart
│   │   ├── route_polyline.dart
│   │   └── location_picker.dart           # Pick incident location
│   ├── chat/
│   │   ├── chat_bubble.dart
│   │   ├── chat_input.dart
│   │   └── message_list.dart
│   └── media/
│       ├── image_picker_widget.dart
│       ├── voice_recorder_widget.dart
│       ├── video_player_widget.dart
│       └── attachment_thumbnail.dart
│
└── utils/
    ├── validators.dart                    # email/phone/password/file validators
    ├── formatters.dart                    # date/duration/distance/phone formatters
    ├── extensions.dart                    # BuildContext.theme/colors, DateTime, String
    ├── distance_calculator.dart           # Haversine formula
    ├── permission_handler.dart            # location/camera/mic/notification
    ├── file_helpers.dart
    ├── logger.dart
    └── helpers.dart
```

**Asset folders** (added to `pubspec.yaml`):
```
assets/
├── images/        # logo, illustrations, first-aid stills
├── icons/         # custom svg icons
├── fonts/         # (only if not using google_fonts)
└── data/          # offline first_aid_guides.json (CPR, choking, bleeding, burns, shock)
```

---

## Models — Implementation Standard

Every file in `lib/models/` follows the same shape. Example for `EmergencyCase`:

```dart
class EmergencyCase {
  final String caseId;
  final String reporterId;
  final String? responderId;
  final String? facilityId;
  final GeoPoint incidentLocation;          // {lat, lng}
  final IncidentType incidentType;          // enum
  final CaseStatus caseStatus;              // enum
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final String description;
  final List<Attachment> attachments;
  final bool emergencyContactNotified;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const EmergencyCase({ /* all fields */ });

  factory EmergencyCase.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
  EmergencyCase copyWith({ /* every field nullable */ }) { ... }
  @override String toString() => 'EmergencyCase(caseId: $caseId, ...)';
  @override bool operator ==(Object other) { ... }
  @override int get hashCode => Object.hash(...);
}
```

**Entities to model** (full field lists are in the SRS analysis at `/tmp/srs_analysis.md`):
1. `User` (base) — userId, email, phoneNumber, fullName, dateOfBirth, gender, profilePhoto, userType, isActive, createdAt, updatedAt, lastLoginAt
2. `Reporter` — emergencyContacts[], medicalProfile, address, emergencyAlertsSent, averageRating
3. `Responder` — certifications[], isApproved, qualificationLevel, currentLocation, isAvailable, averageRating, totalCasesResponded, responseTime, specializations[]
4. `Facility` — facilityName, facilityType, address, location, contactNumber, emergencyContactNumber, capacity, currentPatientCount, specialties[], equipmentList[]
5. `MedicalProfile` — bloodType, allergies[], medications[], chronicDiseases[], emergencyNotes
6. `EmergencyContact` — contactName, phoneNumber, relationship
7. `Certification` — certificationType, issueDate, expiryDate, certificateDocument, isVerified
8. `EmergencyCase` — (above)
9. `AlertHistory` — alertId, caseId, responderId, alertSentAt, acceptanceStatus, distance, rejectionReason, alertType
10. `CommunicationRecord` — communicationId, caseId, senderId, senderType, recipientId, messageType, messageContent, attachments[], sentAt, readAt, priority
11. `HandoverRecord` — handoverId, caseId, responderId, facilityId, handoverTime, patientCondition, vitalSigns, treatmentsProvided[], treatmentNotes, receivingStaffName, patientId
12. `VitalSigns` — heartRate, bloodPressure, respiratoryRate, temperature, oxygenSaturation
13. `CaseClosureReport` — reportId, caseId, responderId, closedAt, caseOutcome, finalNotes, caseDuration, distanceTraveled, responderRating, reporterFeedback
14. `Aed` — aedId, location, facilityId, address, isActive, lastServiceDate, nextServiceDate, accessInstructions
15. `RatingFeedback` — ratingId, caseId, responderId, raterId, ratingScore, feedbackText, categories[], ratedAt
16. `FirstAidGuide` — guideId, guidanceType, title, description, steps[], prerequisites[], warnings[], emergencyHotline
17. `FirstAidStep` — stepNumber, stepTitle, stepDescription, stepImage, stepVideo, stepAudio, duration
18. `Attachment` — attachmentId, attachmentType, attachmentURL, uploadedAt
19. `AuditLog` — logId, userId, actionType, resourceType, resourceID, changeDetails, timestamp, ipAddress, userAgent, status
20. `SystemConfig` — configId, configKey, configValue, dataType, isActive

`GeoPoint` is a simple `{ double latitude; double longitude; }` value class in `core/configuration/`. Step 2 will swap to `cloud_firestore.GeoPoint`.

**Enums** (in `core/constants/enums.dart`):
- `UserRole { reporter, responder, facility, admin }`
- `CaseStatus { created, alertSent, responderAssigned, inProgress, handoverStarted, receivedAtFacility, inTreatment, closed, cancelled }`
- `IncidentType { trafficAccident, cardiacArrest, breathingDifficulty, severeBleed, burns, choking, other }`
- `AlertStatus { pending, accepted, rejected, expired }`
- `CaseOutcome { patientStable, transferredToHospital, patientDeceased, caseCancelled, other }`
- `CertificationType { cpr, firstAid, advanced }`
- `QualificationLevel { basic, intermediate, advanced }`
- `BloodType { aPos, aNeg, bPos, bNeg, oPos, oNeg, abPos, abNeg }`

---

## Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter: { sdk: flutter }
  cupertino_icons: ^1.0.8

  # State management
  provider: ^6.1.2

  # Theme & fonts
  google_fonts: ^6.2.1

  # Routing helpers
  go_router: ^14.2.0          # cleaner than onGenerateRoute for this scale

  # Map (OpenStreetMap)
  flutter_map: ^7.0.2
  latlong2: ^0.9.1

  # Location
  geolocator: ^13.0.1
  geocoding: ^3.0.0           # reverse-geocode via Nominatim wrapper

  # Permissions
  permission_handler: ^11.3.1

  # Media
  image_picker: ^1.1.2
  video_player: ^2.9.1
  cached_network_image: ^3.3.1
  file_picker: ^8.0.6
  record: ^5.1.2              # voice notes

  # Utils
  intl: ^0.19.0
  url_launcher: ^6.3.0
  shared_preferences: ^2.3.0
  uuid: ^4.4.0
  equatable: ^2.0.5
  flutter_svg: ^2.0.10+1
  shimmer: ^3.0.0             # loading skeletons
  flutter_rating_bar: ^4.0.1
  pin_code_fields: ^8.0.1     # OTP UI
  flutter_local_notifications: ^17.2.2  # Step-1 in-app simulation

dev_dependencies:
  flutter_test: { sdk: flutter }
  flutter_lints: ^6.0.0
```

Firebase packages are intentionally **omitted** — they will be added in Step 2 (separate plan).

---

## STEP 1 — UI Build (no backend)

### Goal
A fully clickable English-language Flutter app with every screen pixel-faithful to Figma, navigating end-to-end on mock data. Demo-ready.

### Order of work
1. **Skeleton & theme** — `pubspec.yaml`, asset folders, `colors.dart`, `text_styles.dart`, `dimensions.dart`, `theme.dart`, `app.dart`, `main.dart`, `routes.dart`. `flutter run` shows splash with the SHR logo on the warm off-white background.
2. **Core constants & enums** — `enums.dart`, `app_strings.dart`, `app_assets.dart`, `firestore_collections.dart`, `failure.dart`.
3. **Models** — all 20 entities, each with constructor / fromJson / toJson / copyWith / toString / equality.
4. **Mock service layer** — `mock_data_service.dart` generates seed data (3 reporters, 5 responders, 2 facilities, 8 active cases, AEDs across Jazan, first-aid guides). All other services (`auth_service`, `firestore_service`, `storage_service`, `notification_service`, `case_service`, `chat_service`) return mock data with `Future.delayed` to simulate latency.
5. **Reusable widgets** — buttons → cards → inputs → layout → dialogs → status → map → chat → media. Build each in isolation against the design tokens before assembling screens.
6. **Providers** — register every provider in `app.dart` via `MultiProvider`. Each `ChangeNotifier` exposes `isLoading`, `error`, and the data it owns.
7. **Screens** — build in role order:
   - **Shared/Auth** (10 screens): splash → onboarding → select role → login → create account → forgot password → OTP → emergency access (before/main).
   - **Reporter** (15 screens): dashboard (SOS) → SOS alert → case tracking → chat → first-aid hub + 5 detailed guides + video player → service rating → profile → case history.
   - **Responder** (14 screens): dashboard → alert notification → accept → receiving case → case details → nearby cases → case track details → navigation map → medical protocol → handover → close case → reject reason → communication → profile → statistics.
   - **Facility** (9 screens): dashboard (matches Figma `02_dashboard.png`) → facility profile → incoming case → responder tracking → communication → patient reception → case status → reports → feedback.
   - **Admin** (20 screens): console → manage users / reporters / responders / facilities / AEDs / cases / first-aid → add/edit variants → live incident map → system log → reports → emergency broadcast → data management.
   - **Common** (6 screens): notifications, settings, feedback, more menu, about, help.
8. **Navigation wiring** — `go_router` with role-based shells:
   - `/splash` → `/onboarding` → `/select-role` → `/auth/*` → role shell.
   - Each role shell (`/reporter`, `/responder`, `/facility`, `/admin`) hosts a 4-tab `BottomNavBar`.
9. **First-aid offline content** — `assets/data/first_aid_guides.json` with all 5 guides (CPR, Choking, Bleeding, Burns, Shock). Loaded via `rootBundle.loadString` and parsed into `FirstAidGuide` models.
10. **End-to-end smoke test** — manually click through every primary flow.

### Critical Step-1 design fidelity points
- The `onboarding_screen` MUST match Figma `01_onboarding.png`: SHR logo card on top, tagline, three buttons (Create Account / Sign In / Emergency Access), "How It Works?" section with 3 feature cards (Quick Alert, Instant Response, Medical Facilities), "Need help? View First Aid Guide" + contact rows at the bottom.
- The `facility_dashboard_screen` MUST match Figma `02_dashboard.png`: "Upcoming Cases" with Patient Name card and "Show Cases" button, "Current Cases" with two stacked offer rows, "Facility Cases" 3-tile stat row (AED / Number of beds / Availability Cases), 4-tab bottom nav.
- Use the **exact color tokens** from the table above. Do not hardcode hex values inside widgets — always reference `AppColors`.

---

## Critical Files To Be Created

| File | Purpose |
|---|---|
| [lib/main.dart](lib/main.dart) | Bootstrap |
| `lib/app.dart` | `MaterialApp.router` + `MultiProvider` |
| `lib/core/configuration/colors.dart` | Color palette |
| `lib/core/configuration/text_styles.dart` | Poppins typography |
| `lib/core/configuration/theme.dart` | `ThemeData` from tokens |
| `lib/core/configuration/routes.dart` | `go_router` config with role shells |
| `lib/core/constants/enums.dart` | All enums |
| `lib/models/*` | 20 model files |
| `lib/services/auth_service.dart` | Mock auth (Step 1) |
| `lib/services/firestore_service.dart` | Mock data store (Step 1) |
| `lib/services/location_service.dart` | Geolocator |
| `lib/services/maps_service.dart` | OSM tile + Nominatim |
| `lib/widgets/buttons/*` | Primary/Secondary/SOS |
| `lib/widgets/cards/*` | Feature/Case/Responder/Facility/Stat tiles |
| `lib/widgets/map/osm_map_widget.dart` | `flutter_map` wrapper |
| `lib/screens/shared/onboarding_screen.dart` | Pixel-faithful to Figma |
| `lib/screens/facility/facility_dashboard_screen.dart` | Pixel-faithful to Figma |
| Each role's screen folder (above) | ~64 screens total |
| `pubspec.yaml` | Add deps + asset declarations |
| `assets/data/first_aid_guides.json` | Offline first-aid content |

---

## Verification (Step 1)

- `flutter pub get` + `flutter analyze` → no errors, no warnings beyond style.
- `flutter run` on Android emulator (Pixel 6, API 34) and iOS simulator (iPhone 15).
- **Click-through script:** open app → onboarding → "Create Account" → fill form → select role (test all 4) → land on role dashboard → for each role, open every primary screen and confirm layout matches Figma.
- **Map check:** open `case_tracking_screen` → OSM tiles render → marker placed at hard-coded Jazan coordinate (16.8892° N, 42.5611° E).
- **Mock SOS flow:** Reporter dashboard → tap SOS → confirm dialog → submit → see "Case created" success → navigate to tracking screen with mock responder moving on the map (driven by a `Timer.periodic` that nudges `responder.currentLocation`).
- **Manual screenshot diff:** capture `onboarding_screen` and `facility_dashboard_screen`, place next to Figma exports — visual deltas should be limited to font hinting and platform widgets.

---

## Out of scope (this plan)
- **Firebase integration (Step 2)** — separate plan once Step 1 is approved.
- AI/ML features (smart assignment, anomaly detection) — SRS future work.
- IoT integration (wearables, AED smart-link) — not built.
- Saudi Ministry of Health / Red Crescent integrations — left as TODO hooks in the relevant services.
