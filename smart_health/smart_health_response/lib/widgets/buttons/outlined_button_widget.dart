import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';

class OutlinedAppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final Color? color;

  const OutlinedAppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final btn = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: c,
        minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
        side: BorderSide(color: c, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconS, color: c),
            const SizedBox(width: AppDimensions.paddingS),
          ],
          Text(label, style: AppTextStyles.button.copyWith(color: c)),
        ],
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
