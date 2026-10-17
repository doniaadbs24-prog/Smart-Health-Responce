import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/enums.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _resolveAuthAndNavigate();
  }

  Future<void> _resolveAuthAndNavigate() async {
    // Show splash for at least 2 seconds for branding.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    // If auth already resolved (user logged in or null), navigate immediately.
    if (auth.isAuthenticated) {
      _goToDashboard(auth.role);
      return;
    }

    // Wait a bit more for Firebase auth state to resolve (async stream).
    // Listen for up to 3 seconds; if still not authenticated, go to onboarding.
    bool resolved = false;
    void listener() {
      if (!mounted || resolved) return;
      if (auth.isAuthenticated) {
        resolved = true;
        _goToDashboard(auth.role);
      }
    }

    auth.addListener(listener);
    await Future.delayed(const Duration(seconds: 3));
    auth.removeListener(listener);

    if (!mounted || resolved) return;
    context.go(AppRoutes.onboarding);
  }

  void _goToDashboard(UserRole? role) {
    switch (role) {
      case UserRole.reporter:
        context.go(AppRoutes.reporterDashboard);
      case UserRole.responder:
        context.go(AppRoutes.responderDashboard);
      case UserRole.facility:
        context.go(AppRoutes.facilityDashboard);
      case UserRole.admin:
        context.go(AppRoutes.adminConsole);
      case null:
        context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 16),
                ],
              ),
              child: const Icon(Icons.favorite, color: AppColors.primary, size: 64),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Text(AppStrings.appShortName, style: AppTextStyles.displayLarge),
            const SizedBox(height: AppDimensions.paddingS),
            Text(AppStrings.appName, style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppDimensions.paddingHuge),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
