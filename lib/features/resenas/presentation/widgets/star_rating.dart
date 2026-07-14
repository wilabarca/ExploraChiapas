import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;

        if (interactive) {
          return GestureDetector(
            onTap: () => onRatingChanged?.call((i + 1).toDouble()),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              color: filled ? const Color(0xFFFFC107) : const Color(0xFFDDDDDD),
              size: size,
            ),
          );
        }

        return Icon(
          filled
              ? Icons.star
              : half
              ? Icons.star_half
              : Icons.star_border,
          color: (filled || half)
              ? const Color(0xFFFFC107)
              : const Color(0xFFDDDDDD),
          size: size,
        );
      }),
    );
  }
}
