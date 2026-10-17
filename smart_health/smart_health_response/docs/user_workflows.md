# User Workflows — Smart Health Response

End-to-end journey for each user role, from first launch through registration / login to every functional requirement they can reach. Each step lists the **screen file** (clickable in IDE) and the **functional requirement** it satisfies (codes match the SRS — see [Final_Report_GP_NewVersion- UPDATE.docx](../Final_Report_GP_NewVersion-%20UPDATE.docx)).

The system has **four roles**:

1. [Reporter](#1-reporter--witnessvictim) — witnesses or victims who trigger emergency alerts.
2. [Responder](#2-responder--cprfirst-aid-volunteer) — trained CPR/first-aid volunteers who answer alerts.
3. [Receiving Facility](#3-receiving-facility--hospital--clinic) — hospitals/clinics that receive the patient.
4. [Admin](#4-admin--system-administrator) — manages users, facilities, AEDs, and system content.

A common entry path is shared by every role:

```
SplashScreen → OnboardingScreen → CreateAccount / Login / EmergencyAccess → SelectRoleScreen → role dashboard
```

---

## Common entry flow (all roles)

| # | Step | Screen | Notes |
|---|---|---|---|
| 0 | App launches | [splash_screen.dart](../lib/screens/shared/splash_screen.dart) | 2-second branded splash with the SHR logo, then auto-routes to onboarding. |
| 1 | Onboarding | [onboarding_screen.dart](../lib/screens/shared/onboarding_screen.dart) | Three calls-to-action: **Create Account**, **Sign In**, **Emergency Access**. Below, three "How It Works?" feature cards (Quick Alert, Instant Response, Medical Facilities). |
| 2a | New user → registers | [create_account_screen.dart](../lib/screens/auth/create_account_screen.dart) | Captures Full Name, Email, Phone, Role (Reporter/Responder/Facility/Admin), Password, Confirm Password. |
| 2b | Returning user → signs in | [login_screen.dart](../lib/screens/auth/login_screen.dart) | Email + password. "Forgot Password?" link. |
| 2c | Emergency override | [emergency_access_before_screen.dart](../lib/screens/auth/emergency_access_before_screen.dart) → [emergency_access_screen.dart](../lib/screens/auth/emergency_access_screen.dart) | Skip account creation, send SOS as guest. Limited functionality — used when a witness has no time to register. |
| 3 | OTP verification | [otp_verification_screen.dart](../lib/screens/auth/otp_verification_screen.dart) | After registration, 6-digit SMS code. Step 2 will use Firebase Phone Auth. |
| 4 | Forgot password | [forgot_password_screen.dart](../lib/screens/auth/forgot_password_screen.dart) | Enter email → reset link sent. |
| 5 | Role picker | [select_role_screen.dart](../lib/screens/shared/select_role_screen.dart) | Visual chooser; each option launches that role's dashboard. *Step 2 will hide non-applicable roles based on the user's actual `userType` field.* |

---

## 1. Reporter — witness / victim

A Reporter is a layperson who witnesses an emergency or is the victim themselves. They use the app to summon a trained responder fast and to follow first-aid guidance while help is on the way.

**Maps to SRS module:** FR-Reporter-1 .. FR-Reporter-12.

### 1.1 Registration & first launch

| FR | Step | Screen / file |
|---|---|---|
| FR-Reporter-1 | Open app, tap **Create Account** | [onboarding_screen.dart](../lib/screens/shared/onboarding_screen.dart) |
| FR-Reporter-1 | Fill Name, Email, Phone, Password, select role = *Reporter* | [create_account_screen.dart](../lib/screens/auth/create_account_screen.dart) |
| FR-Reporter-2 | Receive SMS code, enter on OTP screen | [otp_verification_screen.dart](../lib/screens/auth/otp_verification_screen.dart) |
| FR-Reporter-1 | Profile preloaded with empty medical info; user is encouraged to fill it later | (Step 2 writes to `reporters/{uid}` document) |
| FR-Reporter-1 | Permissions prompted: **Location** (always-allow), **Notifications** | [utils/permission_handler.dart](../lib/utils/permission_handler.dart) |

### 1.2 Login (returning user)

| FR | Step | Screen / file |
|---|---|---|
| FR-Reporter-2 | Tap **Sign In** | [onboarding_screen.dart](../lib/screens/shared/onboarding_screen.dart) |
| FR-Reporter-2 | Enter email + password | [login_screen.dart](../lib/screens/auth/login_screen.dart) |
| FR-Reporter-2 | Forgot password? → reset email | [forgot_password_screen.dart](../lib/screens/auth/forgot_password_screen.dart) |

### 1.3 Reporter dashboard

[reporter_dashboard_screen.dart](../lib/screens/reporter/reporter_dashboard_screen.dart) — large pulsing red **SOS** button at center plus quick-access cards for First Aid, Case History, Profile.

### 1.4 Submit emergency (the core flow)

| FR | Step | Screen / action |
|---|---|---|
| FR-Reporter-3 | Tap the SOS button | dashboard → routes to [sos_alert_screen.dart](../lib/screens/reporter/sos_alert_screen.dart) |
| FR-Reporter-3 | GPS auto-captured; map shows the incident point — tap to adjust | [osm_map_widget.dart](../lib/widgets/map/osm_map_widget.dart) inside the SOS screen |
| FR-Reporter-3 | Pick **Emergency Type**: Cardiac Arrest, Traffic Accident, Bleeding, Choking, Burns, Breathing Difficulty, Other | dropdown |
| FR-Reporter-5 | Optional: attach photo / record voice note | "Add Photo" / "Record Voice" buttons |
| FR-Reporter-3 | Add description text | text area |
| FR-Reporter-3 | Tap **Send Alert** → case created, status = `alertSent` | provider call: `ReporterProvider.submitSos(...)` |
| FR-Reporter-7 | Saved emergency contact auto-notified (Step 2: Cloud Functions push) | (Step 2) |

### 1.5 Voice-activated SOS (FR-Reporter-4)

A long-press on the SOS button (or "Hey SHR, emergency!" voice command — Step 2) skips the form and sends a default-type alert with current location only. Provided as a hands-free option for users in distress.

### 1.6 Wait for help — case tracking

| FR | Step | Screen |
|---|---|---|
| FR-Reporter-9 | After submit, app navigates to live tracking | [case_tracking_screen.dart](../lib/screens/reporter/case_tracking_screen.dart) |
| FR-Reporter-9 | Live map showing the assigned responder's location, ETA, distance | OSM widget + responder marker |
| FR-Reporter-11 | Status indicator updates: Alert Sent → Responder Assigned → In Progress → Closed | [status_chip.dart](../lib/widgets/status/status_chip.dart) |
| FR-Reporter-10 | Tap "Chat" → message the responder | [chat_with_responder_screen.dart](../lib/screens/reporter/chat_with_responder_screen.dart) |
| FR-Reporter-10 | Tap "Call" → `url_launcher` dials responder's phone | dashboard button |

### 1.7 Offline first-aid guidance

| FR | Step | Screen |
|---|---|---|
| FR-Reporter-8 | Open hub from dashboard or "Need help? View First Aid Guide" link on onboarding | [first_aid_list_screen.dart](../lib/screens/reporter/first_aid/first_aid_list_screen.dart) |
| FR-Reporter-8 | Pick a guide — CPR / Choking / Bleeding / Burns / Shock | [first_aid_detail_screen.dart](../lib/screens/reporter/first_aid/first_aid_detail_screen.dart) |
| FR-Reporter-8 | Step-by-step instructions, warnings, emergency hotline | content from [assets/data/first_aid_guides.json](../assets/data/first_aid_guides.json) |

The guides are bundled into the app — work offline by design.

### 1.8 After the case

| FR | Step | Screen |
|---|---|---|
| FR-Reporter-11 | Push notification: "Case closed" | [notifications_screen.dart](../lib/screens/common/notifications_screen.dart) |
| FR-Reporter-12 | Rate the responder 1–5 stars + written feedback | [service_rating_screen.dart](../lib/screens/reporter/service_rating_screen.dart) |
| — | Browse past cases | [case_history_screen.dart](../lib/screens/reporter/case_history_screen.dart) |

### 1.9 Profile management

| Step | Screen |
|---|---|
| Add/edit emergency contacts (name, phone, relationship) | [reporter_profile_screen.dart](../lib/screens/reporter/reporter_profile_screen.dart) |
| Set medical profile: blood type, allergies, medications, chronic diseases, emergency notes | same screen |
| Notification preferences | [settings_screen.dart](../lib/screens/common/settings_screen.dart) |
| Privacy / data deletion | settings → linked from settings |

---

## 2. Responder — CPR/first-aid volunteer

A Responder is a trained volunteer or professional who agrees to receive emergency alerts from nearby Reporters and respond to them.

**Maps to SRS module:** FR-Responder-1 .. FR-Responder-10.

### 2.1 Registration with certification upload

| FR | Step | Screen |
|---|---|---|
| FR-Responder-1 | Tap Create Account, fill personal info, role = *Responder* | [create_account_screen.dart](../lib/screens/auth/create_account_screen.dart) |
| FR-Responder-1 | Receive OTP code | [otp_verification_screen.dart](../lib/screens/auth/otp_verification_screen.dart) |
| FR-Responder-1 | Upload CPR certificate (PDF) | (in Step 2 flow) [add_responder_screen.dart](../lib/screens/admin/add_responder_screen.dart) — also accessible from a "Become a responder" CTA in profile |
| FR-Responder-1 | Upload First-Aid certificate (PDF) | same screen |
| FR-Responder-1 | Specify qualification level (Basic / Intermediate / Advanced) and specializations | same screen |
| FR-Responder-1 | Account status = *Pending Approval* — admin must verify | (Step 2: writes `responders/{uid}.isApproved = false`) |
| — | Wait for admin approval — push notification sent on approval | (Step 2 Cloud Function) |

### 2.2 Login (returning Responder)

Identical to the Reporter login flow ([login_screen.dart](../lib/screens/auth/login_screen.dart)) — email/password.

### 2.3 Responder dashboard

[responder_dashboard_screen.dart](../lib/screens/responder/responder_dashboard_screen.dart) — at top: Available/Off-duty toggle. Below: stat tiles (Active cases, Alerts, Rating). Then sections: Nearby Alerts and My Active Cases.

### 2.4 Receive an emergency alert

| FR | Step | Screen / event |
|---|---|---|
| FR-Responder-3 | FCM push arrives within seconds of a nearby Reporter's SOS | (Step 2 — `onCaseCreated` Cloud Function fans out alerts) |
| FR-Responder-3 | Tap notification → opens the alert detail | [alert_notification_screen.dart](../lib/screens/responder/alert_notification_screen.dart) |
| FR-Responder-3 | See the incident on a map with marker, type, distance, reporter info, description | OSM widget + map markers |
| FR-Responder-4 | Choose **Accept** or **Reject** | accept button → `ResponderProvider.acceptAlert(caseId)` |
| FR-Responder-4 | If reject, optionally provide reason | [reject_reason_screen.dart](../lib/screens/responder/reject_reason_screen.dart) |
| FR-Responder-5 | System auto-assigns based on distance + qualifications + availability | (Step 2 Cloud Function logic) |

### 2.5 Navigate to the incident

| FR | Step | Screen |
|---|---|---|
| FR-Responder-6 | After accept, app opens turn-by-turn navigation | [navigation_to_case_screen.dart](../lib/screens/responder/navigation_to_case_screen.dart) |
| FR-Responder-6 | Live ETA + distance, route polyline to the incident | OSM + Polyline layer |
| FR-Responder-6 | Responder's location is broadcast back to the Reporter, Facility, and Admin every 5 s | (Step 2: location stream writes `responders/{uid}.currentLocation` continuously) |

### 2.6 At the scene — apply first aid

| FR | Step | Screen |
|---|---|---|
| FR-Responder-7 | Tap "I have arrived" on the navigation screen | navigates to [medical_protocol_screen.dart](../lib/screens/responder/medical_protocol_screen.dart) |
| FR-Responder-7 | Step-by-step protocol for the incident type (CPR steps for cardiac arrest, abdominal thrusts for choking, etc.) | full screen with numbered steps |
| FR-Responder-8 | Open in-app chat to coordinate with Reporter and / or receiving Facility | [responder_communication_screen.dart](../lib/screens/responder/responder_communication_screen.dart) |
| FR-Responder-9 | Begin handover form when ambulance / facility arrives | [handover_screen.dart](../lib/screens/responder/handover_screen.dart) |

### 2.7 Patient handover

| FR | Step | Screen |
|---|---|---|
| FR-Responder-9 | Fill: patient condition, vital signs (HR, BP, RR, temp, SpO₂), treatments provided, notes, receiving staff name | [handover_screen.dart](../lib/screens/responder/handover_screen.dart) |
| FR-Responder-9 | Submit handover; case status flips to `handoverStarted` then `receivedAtFacility` after Facility confirms | provider call |

### 2.8 Close the case

| FR | Step | Screen |
|---|---|---|
| FR-Responder-10 | Choose outcome: Patient Stable, Transferred to Hospital, Patient Deceased, Cancelled, Other | [close_case_screen.dart](../lib/screens/responder/close_case_screen.dart) |
| FR-Responder-10 | Enter final notes | same screen |
| FR-Responder-10 | Submit; case status = `closed`. Responder stats recomputed | (Step 2 `onCaseClosed` Cloud Function) |

### 2.9 Performance & profile

| Step | Screen |
|---|---|
| View case statistics: alerts received, accepted, average response time, rating | [alert_statistics_screen.dart](../lib/screens/responder/alert_statistics_screen.dart) |
| View own profile, certifications, expirations | [responder_profile_screen.dart](../lib/screens/responder/responder_profile_screen.dart) |
| List of nearby pending cases (for proactive responders) | [nearby_cases_screen.dart](../lib/screens/responder/nearby_cases_screen.dart) |
| List of all active cases assigned to me | [responder_dashboard_screen.dart](../lib/screens/responder/responder_dashboard_screen.dart) "My Active Cases" section |

---

## 3. Receiving Facility — hospital / clinic

A Receiving Facility (hospital, clinic, medical center) is alerted when a Responder is bringing in a patient. Staff prepare the ER, communicate with the responder en route, confirm reception, and update the case status through treatment to closure.

**Maps to SRS module:** FR-Facility-1 .. FR-Facility-9.

### 3.1 Registration / onboarding

Facilities are normally **created by an Admin** via [add_facility_screen.dart](../lib/screens/admin/add_facility_screen.dart) — they don't self-register. The admin sets the facility's hours, capacity, specialties, equipment, and emergency phone number. A Facility staff user account (role = `facility`) is then linked to that facility's document.

| FR | Step | Screen |
|---|---|---|
| FR-Facility-1 | Admin creates the facility record | [add_facility_screen.dart](../lib/screens/admin/add_facility_screen.dart) |
| FR-Facility-1 | Admin adds a Facility-role user account in [manage_users_screen.dart](../lib/screens/admin/manage_users_screen.dart) | (Step 2: invite-by-email link) |
| FR-Facility-1 | Facility staff sign in for the first time | [login_screen.dart](../lib/screens/auth/login_screen.dart) |

### 3.2 Login (recurring)

Same email/password flow as other roles — [login_screen.dart](../lib/screens/auth/login_screen.dart).

### 3.3 Facility dashboard

[facility_dashboard_screen.dart](../lib/screens/facility/facility_dashboard_screen.dart) — pixel-faithful to the Figma "facility dashboard" frame: **Upcoming Cases** card with patient name + ETA + Show Cases button, **Current Cases** list ("the offer" rows), **Facility Cases** stat tiles (AED count, available beds, availability flag).

### 3.4 Receive incoming-case alert

| FR | Step | Screen |
|---|---|---|
| FR-Facility-2 | FCM push arrives when a Responder selects this facility for handover | (Step 2: topic `facility_{facilityId}`) |
| FR-Facility-2 | Tap notification → opens incoming case detail | [incoming_case_screen.dart](../lib/screens/facility/incoming_case_screen.dart) |
| FR-Facility-2 | See patient info, condition, responder details, ETA | screen contents |
| FR-Facility-3 | Watch responder location move on the map until arrival | [facility_responder_tracking_screen.dart](../lib/screens/facility/facility_responder_tracking_screen.dart) |

### 3.5 Coordinate with the responder

| FR | Step | Screen |
|---|---|---|
| FR-Facility-4 | Send quick coordination messages ("Use Gate 2", "ER ready", "Need extra unit") | [facility_communication_screen.dart](../lib/screens/facility/facility_communication_screen.dart) |
| FR-Facility-4 | Voice call (in production via deep-link to `tel:`) | (button on tracking screen) |

### 3.6 Patient reception

| FR | Step | Screen |
|---|---|---|
| FR-Facility-5 | When responder arrives, tap "Confirm Reception" | [patient_reception_screen.dart](../lib/screens/facility/patient_reception_screen.dart) |
| FR-Facility-5 | Verify patient identity, sign handover, fill receiving staff name | screen form |
| FR-Facility-6 | Read responder's handover record (pre-filled vitals + treatments) | shown read-only on the reception screen |
| FR-Facility-7 | Update case status: Received → In Treatment → Closed | [case_status_update_screen.dart](../lib/screens/facility/case_status_update_screen.dart) |

### 3.7 Internal reporting

| FR | Step | Screen |
|---|---|---|
| FR-Facility-8 | Filter by date range / case type → see counts, durations, outcomes | [facility_reports_screen.dart](../lib/screens/facility/facility_reports_screen.dart) |
| FR-Facility-8 | Export to PDF / Excel | (button on reports screen — Step 2 generates and shares) |

### 3.8 Quality feedback

| FR | Step | Screen |
|---|---|---|
| FR-Facility-9 | After a case closes, rate the responder and add outcome notes | [facility_feedback_screen.dart](../lib/screens/facility/facility_feedback_screen.dart) |
| FR-Facility-9 | Feedback contributes to responder's `averageRating` | (Step 2 Cloud Function) |

### 3.9 Facility profile

| Step | Screen |
|---|---|
| View own facility info (read-only for facility staff; editable for admin) | [facility_profile_screen.dart](../lib/screens/facility/facility_profile_screen.dart) |
| Update bed availability count daily | (admin or staff via profile screen) |

---

## 4. Admin — system administrator

The Admin oversees the platform: approves responder certifications, manages facilities and AEDs, monitors live incidents, broadcasts emergencies, and curates first-aid content.

**Maps to SRS module:** FR-Admin-1 .. FR-Admin-10.

### 4.1 Registration

Admins are seeded by the system owner — there is no public Admin sign-up. The first Admin is created manually in Firestore (or via the Firebase Console). Subsequent admins are added by an existing admin via [manage_users_screen.dart](../lib/screens/admin/manage_users_screen.dart).

### 4.2 Login

Identical email/password flow — [login_screen.dart](../lib/screens/auth/login_screen.dart). On successful login the role-picker recognizes role=`admin` and routes to the admin console.

### 4.3 Admin console (home)

[admin_console_screen.dart](../lib/screens/admin/admin_console_screen.dart) — system overview: total users, responders, facilities, active cases, plus quick-access tiles for every admin function.

### 4.4 User management (FR-Admin-2)

| Step | Screen |
|---|---|
| Search/filter all users | [manage_users_screen.dart](../lib/screens/admin/manage_users_screen.dart) |
| Activate / deactivate accounts | toggle on user row |
| List all reporters | [manage_reporters_screen.dart](../lib/screens/admin/manage_reporters_screen.dart) |
| List all responders | [manage_responders_screen.dart](../lib/screens/admin/manage_responders_screen.dart) |

### 4.5 Responder approval (FR-Admin-3)

| Step | Screen |
|---|---|
| Open responder detail with all certificates | [responder_details_screen.dart](../lib/screens/admin/responder_details_screen.dart) |
| Approve → flips `isApproved = true` and sends FCM | approve button |
| Reject → deletes responder profile | reject button (confirmation dialog) |
| Add a responder manually (e.g., bulk import a known volunteer) | [add_responder_screen.dart](../lib/screens/admin/add_responder_screen.dart) |
| Edit responder qualifications / specializations | [edit_responder_screen.dart](../lib/screens/admin/edit_responder_screen.dart) |

### 4.6 Facility management (FR-Admin-4)

| Step | Screen |
|---|---|
| List all hospitals / clinics | [manage_facilities_screen.dart](../lib/screens/admin/manage_facilities_screen.dart) |
| Add a new facility | [add_facility_screen.dart](../lib/screens/admin/add_facility_screen.dart) |
| Edit facility details / capacity / contact info | [edit_facility_screen.dart](../lib/screens/admin/edit_facility_screen.dart) |
| Delete facility (with confirmation) | edit screen "Delete" button |

### 4.7 AED inventory (FR-Admin-4)

| Step | Screen |
|---|---|
| List all AEDs across the region | [manage_aeds_screen.dart](../lib/screens/admin/manage_aeds_screen.dart) |
| Add or edit an AED's location, access notes, service dates | [edit_aed_screen.dart](../lib/screens/admin/edit_aed_screen.dart) |

### 4.8 Live incident monitoring (FR-Admin-5)

| Step | Screen |
|---|---|
| Open the live map | [live_incident_map_screen.dart](../lib/screens/admin/live_incident_map_screen.dart) |
| See incident markers, responder dots, facility pins, AED pins all in real time | OSM widget + dynamic marker layer |
| Drill into a specific case | tap marker → [manage_cases_screen.dart](../lib/screens/admin/manage_cases_screen.dart) |

### 4.9 Case management (FR-Admin-2 / FR-Admin-9)

| Step | Screen |
|---|---|
| Browse all cases (active + historical) | [manage_cases_screen.dart](../lib/screens/admin/manage_cases_screen.dart) |
| Filter by status / responder / facility / type | (filters on screen) |
| Open a case for full audit trail | tap row |

### 4.10 System audit log (FR-Admin-8)

| Step | Screen |
|---|---|
| View every sensitive action — logins, data writes, approvals, alerts | [system_log_screen.dart](../lib/screens/admin/system_log_screen.dart) |
| Filter by user / action type / date range | (filters on screen) |

### 4.11 Reports & analytics (FR-Admin-9)

| Step | Screen |
|---|---|
| Generate platform-wide reports — totals, response times, rating distributions | [reports_screen.dart](../lib/screens/admin/reports_screen.dart) |
| Export PDF or Excel | (button on screen — Step 2 generates and shares) |

### 4.12 Emergency broadcast (FR-Admin-10)

| Step | Screen |
|---|---|
| Compose a critical message | [emergency_broadcast_screen.dart](../lib/screens/admin/emergency_broadcast_screen.dart) |
| Pick audience: All Responders / All Facilities / All Reporters / Everyone | dropdown |
| Confirm and send → FCM topic push | confirmation dialog |

### 4.13 First-aid content management

| Step | Screen |
|---|---|
| List all first-aid guides | [manage_first_aid_screen.dart](../lib/screens/admin/manage_first_aid_screen.dart) |
| Edit a guide's title, description, steps | [edit_first_aid_screen.dart](../lib/screens/admin/edit_first_aid_screen.dart) |
| Updates are pushed to all users (Step 2: Firestore listeners auto-refresh the bundled content) | — |

### 4.14 Data management (FR-Admin-7)

| Step | Screen |
|---|---|
| Trigger a backup, restore, or archive of old cases | [data_management_screen.dart](../lib/screens/admin/data_management_screen.dart) |
| Process a GDPR deletion request | "GDPR Deletion Request" tile |
| Configure retention policies | (Step 2: writes to `system_config`) |

---

## Cross-role features

These appear in the **More menu** ([more_menu_screen.dart](../lib/screens/common/more_menu_screen.dart)) for every signed-in user regardless of role:

| Feature | Screen |
|---|---|
| Notifications inbox (filtered by user) | [notifications_screen.dart](../lib/screens/common/notifications_screen.dart) |
| Settings (password, language, theme) | [settings_screen.dart](../lib/screens/common/settings_screen.dart) |
| Send feedback to the SHR team | [feedback_screen.dart](../lib/screens/common/feedback_screen.dart) |
| About the app | [about_screen.dart](../lib/screens/common/about_screen.dart) |
| Help & FAQ | [help_screen.dart](../lib/screens/common/help_screen.dart) |
| Sign out | settings → "Sign Out" button |

---

## Sequence summary — happy-path emergency

A single end-to-end flow weaving all four roles together:

```
Reporter                       Responder                   Facility                   Admin

[1] open app → SOS
[2] tap SOS button
[3] form: type=Cardiac Arrest, GPS auto
[4] Send → Firestore case created  →  [5] FCM push to all
                                          approved nearby responders
                                       [6] tap notification
                                       [7] read alert detail
                                       [8] Accept            →  case.responderId set
                                       [9] navigate to scene
[10] tracking screen: see responder
     marker move on map
[11] receive "Help is on the way" push
                                      [12] arrive at scene
                                      [13] medical protocol
                                      [14] handover form     →  [15] FCM to facility
                                                                 [16] open incoming case
                                                                 [17] track responder
                                                                 [18] confirm reception
                                                                 [19] handover signed off
                                      [20] close case
                                                                 [21] update status =
                                                                      In Treatment → Closed
[22] receive "Case closed" push
[23] rate responder
                                                                                            [24] live map shows
                                                                                                 closed case in audit log
                                                                                            [25] reports updated
```

Every arrow corresponds to a Firestore document write that is observed by a streaming listener in the relevant provider — that is what makes the multi-device live experience possible.
