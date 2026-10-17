import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/text_styles.dart';

class AppBottomNavItem {
  final IconData icon;
  final String label;
  final String route;
  const AppBottomNavItem({required this.icon, required this.label, required this.route});
}

class AppBottomNavBar extends StatelessWidget {
  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.viewPaddingOf(context).bottom + 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          final color = selected ? AppColors.primary : AppColors.textTertiary;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].icon, color: color, size: 26),
                    const SizedBox(height: 4),
                    Text(items[i].label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: color,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
