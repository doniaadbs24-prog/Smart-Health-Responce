import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/buttons/primary_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _code = '';

  Future<void> _verify() async {
    final ok = await context.read<AuthProvider>().verifyOtp(_code);
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.selectRole);
    } else {
      context.showSnack('Invalid code', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Verify your phone', style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppDimensions.paddingS),
              Text('We sent a 6-digit code to your phone.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppDimensions.paddingXL),
              PinCodeTextField(
                appContext: context,
                length: 6,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  fieldHeight: 56,
                  fieldWidth: 44,
                  inactiveColor: AppColors.border,
                  activeColor: AppColors.primary,
                  selectedColor: AppColors.accent,
                  inactiveFillColor: AppColors.surface,
                  activeFillColor: AppColors.surface,
                  selectedFillColor: AppColors.surface,
                ),
                enableActiveFill: true,
                keyboardType: TextInputType.number,
                onChanged: (v) => _code = v,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              PrimaryButton(label: 'Verify', onPressed: _verify),
              const SizedBox(height: AppDimensions.paddingL),
              Center(
                child: TextButton(
                  onPressed: () => context.showSnack('Code resent'),
                  child: const Text('Resend code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
