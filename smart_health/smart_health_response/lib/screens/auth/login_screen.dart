import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../utils/extensions.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: '');
  final _password = TextEditingController(text: '');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (!ok) {
      context.showSnack(auth.error ?? AppStrings.somethingWentWrong, isError: true);
    }
    // On success, GoRouter's refreshListenable + redirect routes to the role dashboard.
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.login)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                Text('Welcome back', style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppDimensions.paddingS),
                Text('Sign in to continue',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppDimensions.paddingXL),
                AppTextField(
                  label: AppStrings.email,
                  hint: 'you@shr.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                PasswordField(controller: _password, validator: Validators.password),
                const SizedBox(height: AppDimensions.paddingS),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                PrimaryButton(label: AppStrings.login, onPressed: _submit, isLoading: loading),
                const SizedBox(height: AppDimensions.paddingXL),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.dontHaveAccount, style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.createAccount),
                      child: const Text(AppStrings.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
