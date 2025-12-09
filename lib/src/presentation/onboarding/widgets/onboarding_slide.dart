import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final Widget? icon;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for illustration if icon is not provided
          icon ??
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: kCardBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.image,
                  size: 80,
                  color: kPrimary.withValues(alpha: 0.3),
                ),
              ),
          const SizedBox(height: 60),
          Text(
            title,
            style: kTitleStyle.copyWith(fontSize: 26), // Slightly larger
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: kBodyStyle.copyWith(color: kTextSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
