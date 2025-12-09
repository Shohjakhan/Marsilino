import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A generic rounded card wrapper with shadow.
/// Uses design tokens for consistent styling across the app.
class RoundedCard extends StatelessWidget {
  /// The child widget to display inside the card.
  final Widget child;

  /// Optional margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Padding inside the card. Defaults to EdgeInsets.all(16).
  final EdgeInsetsGeometry padding;

  /// Border radius of the card. Defaults to CARD_RADIUS (22).
  final double radius;

  const RoundedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.radius = kCardRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [kCardShadow],
      ),
      child: child,
    );
  }
}
