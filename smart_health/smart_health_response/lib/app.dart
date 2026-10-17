import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'core/configuration/routes.dart';
import 'core/configuration/theme.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/enums.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/case_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/facility_provider.dart';
import 'providers/first_aid_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/reporter_provider.dart';
import 'providers/responder_provider.dart';
import 'providers/theme_provider.dart';
import 'services/service_locator.dart';

class SmartHealthApp extends StatelessWidget {
  const SmartHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReporterProvider()),
        ChangeNotifierProvider(create: (_) => ResponderProvider()),
        ChangeNotifierProvider(create: (_) => FacilityProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => CaseProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FirstAidProvider()),
      ],
      child: const _SmartHealthRoot(),
    );
  }
}

class _SmartHealthRoot extends StatefulWidget {
  const _SmartHealthRoot();

  @override
  State<_SmartHealthRoot> createState() => _SmartHealthRootState();
}

class _SmartHealthRootState extends State<_SmartHealthRoot> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _router = AppRouter.create(auth);
    sl.notifications.init(onTap: (payload) {
      switch (auth.role) {
        case UserRole.reporter:
          if (payload != null) {
            _router.go('${AppRoutes.caseTracking}?caseId=$payload');
          } else {
            _router.go(AppRoutes.reporterDashboard);
          }
          break;
        case UserRole.responder:
          _router.go(AppRoutes.responderDashboard);
          break;
        case UserRole.facility:
          _router.go(AppRoutes.facilityDashboard);
          break;
        case UserRole.admin:
          _router.go(AppRoutes.adminConsole);
          break;
        case null:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeProvider.mode,
        routerConfig: _router,
      ),
    );
  }
}
