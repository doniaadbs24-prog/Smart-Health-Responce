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
import '../../utils/extensions.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/inputs/dropdown_field.dart';
import '../../widgets/inputs/password_field.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  UserRole _role = UserRole.reporter;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      fullName: _name.text.trim(),
      password: _password.text,
      role: _role,
    );
    if (!mounted) return;
    if (!ok) {
      context.showSnack(auth.error ?? AppStrings.somethingWentWrong, isError: true);
    }
    // On success, GoRouter's redirect routes to the role-specific dashboard.
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createAccount)),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            children: [
              Text('Create your account', style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppDimensions.paddingS),
              Text('Join Smart Health Response',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppDimensions.paddingXL),
              AppTextField(
                label: AppStrings.fullName,
                hint: 'John Doe',
                controller: _name,
                prefixIcon: Icons.person_outline,
                validator: Validators.required,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              AppTextField(
                label: AppStrings.email,
                hint: 'you@shr.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline,
                validator: Validators.email,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              AppTextField(
                label: AppStrings.phoneNumber,
                hint: '+966 50 123 4567',
                controller: _phone,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: Validators.phone,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              AppDropdownField<UserRole>(
                label: 'Role',
                value: _role,
                prefixIcon: Icons.account_circle_outlined,
                items: UserRole.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v ?? UserRole.reporter),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              PasswordField(controller: _password, validator: Validators.password),
              const SizedBox(height: AppDimensions.paddingL),
              PasswordField(
                label: AppStrings.confirmPassword,
                controller: _confirm,
                validator: (v) => Validators.confirmPassword(v, _password.text),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              PrimaryButton(label: AppStrings.register, onPressed: _submit, isLoading: loading),
              const SizedBox(height: AppDimensions.paddingL),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.alreadyHaveAccount, style: AppTextStyles.bodyMedium),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text(AppStrings.login),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
