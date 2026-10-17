import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import 'app_text_field.dart';

class PasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    this.label = 'Password',
    this.hint = '••••••••',
    this.controller,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscure,
      prefixIcon: Icons.lock_outline,
      suffix: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textTertiary,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
