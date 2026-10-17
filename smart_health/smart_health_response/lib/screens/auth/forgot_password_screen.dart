import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../widgets/inputs/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().sendPasswordReset(_email.text.trim());
    if (!mounted) return;
    if (ok) {
      await SuccessDialog.show(context,
          title: 'Email Sent', message: 'Check your inbox for reset instructions.');
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.forgotPassword)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Forgot your password?', style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppDimensions.paddingS),
                Text("Enter your email and we'll send you a reset link.",
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppDimensions.paddingXL),
                AppTextField(
                  label: AppStrings.email,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                PrimaryButton(label: 'Send Reset Link', onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
