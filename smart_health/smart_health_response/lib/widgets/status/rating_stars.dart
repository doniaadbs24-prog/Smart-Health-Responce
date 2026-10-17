import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final void Function(double)? onChanged;
  final int max;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.onChanged,
    this.max = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i + 1 <= rating;
        final half = !filled && i + 0.5 <= rating;
        return GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!((i + 1).toDouble()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              filled
                  ? Icons.star_rounded
                  : (half ? Icons.star_half_rounded : Icons.star_outline_rounded),
              color: AppColors.warning,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
