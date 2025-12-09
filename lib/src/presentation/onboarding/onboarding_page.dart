import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../common/secondary_button.dart';
import '../sign_in/sign_in_page.dart';
import '../sign_up/sign_up_page.dart';
import '../main_shell.dart';
import 'widgets/onboarding_slide.dart';

/// Onboarding page with slides and navigation actions.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<Map<String, String>> _slides = [
    {
      'title': 'Discover Restaurants Near You',
      'description':
          'Find the best places around you with exclusive discounts.',
      'icon': 'map',
    },
    {
      'title': 'Real Discounts, Every Visit',
      'description': 'Use our app at partner restaurants and save instantly.',
      'icon': 'discount',
    },
    {
      'title': 'Simple and Fast',
      'description':
          'Show your discount code at checkout — no online payment needed.',
      'icon': 'flash',
    },
    {
      'title': 'Welcome to Restaurant App',
      'description': 'Create an account or sign in to continue.',
      'icon': 'person',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _navigateToSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return OnboardingSlide(
                        title: slide['title']!,
                        description: slide['description']!,
                        icon: _buildIcon(slide['icon']!),
                      );
                    },
                  ),
                ),
                // Bottom Area
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? kPrimary
                                  : kTextSecondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      // Actions
                      if (isLastPage) ...[
                        PrimaryButton(
                          label: 'Sign In',
                          onPressed: _navigateToSignIn,
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Sign Up',
                          onPressed: _navigateToSignUp,
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 16),
                          SecondaryButton(
                            label: 'Continue to Home (Dev)',
                            onPressed: _navigateToHome,
                          ),
                        ],
                      ] else ...[
                        PrimaryButton(
                          label: 'Next',
                          onPressed: _nextPage,
                          fullWidth:
                              false, // Pill shape requested but PrimaryButton is usually full width.
                          // Let's check PrimaryButton implementation. It has fullWidth property.
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
            // Back Arrow
            if (_currentPage > 0)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: kTextPrimary,
                  onPressed: _previousPage,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String iconType) {
    IconData icon;
    switch (iconType) {
      case 'map':
        icon = Icons.map_outlined;
        break;
      case 'discount':
        icon = Icons.percent_outlined;
        break;
      case 'flash':
        icon = Icons.flash_on_outlined;
        break;
      case 'person':
        icon = Icons.person_outline;
        break;
      default:
        icon = Icons.image;
    }

    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: kCardBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.15),
            blurRadius: 60,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 100, color: kPrimary),
    );
  }
}
