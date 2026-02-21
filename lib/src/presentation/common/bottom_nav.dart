import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Bottom navigation bar item data.
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Custom floating bottom navigation bar with animated circle indicator
/// and a centered QR scan button.
class BottomNav extends StatelessWidget {
  /// Currently selected tab index.
  final int currentIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTap;

  /// Navigation items to display.
  final List<BottomNavItem> items;

  /// Callback when the center QR button is tapped.
  final VoidCallback? onQrTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onQrTap,
  });

  /// Default navigation items for the app.
  static const List<BottomNavItem> defaultItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: 'Map',
    ),
    BottomNavItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Likes',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Compute the "logical" index for the indicator,
    // skipping the center spacer slot.
    final indicatorIndex = currentIndex < 2 ? currentIndex : currentIndex + 1;
    final totalSlots = items.length + 1; // 4 items + 1 center spacer

    return SizedBox(
      height: 94, // 70 bar + 24 bottom margin
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The nav bar container
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: kTextPrimary.withValues(alpha: 0.08),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated circle indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _getIndicatorPosition(
                      context,
                      indicatorIndex,
                      totalSlots,
                    ),
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kCardBg,
                          border: Border.all(
                            color: kTextSecondary.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Navigation items row with center spacer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // First two items (Home, Map)
                      for (int i = 0; i < 2; i++) _buildNavItem(i),
                      // Center spacer for the QR button
                      const Expanded(child: SizedBox()),
                      // Last two items (Likes, Profile)
                      for (int i = 2; i < items.length; i++) _buildNavItem(i),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Center QR FAB — elevated above the bar
          Positioned(
            bottom: 24 + 70 / 2 - 28, // Center vertically on bar top edge
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onQrTap,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B1E3F),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B1E3F).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getIndicatorPosition(
    BuildContext context,
    int slotIndex,
    int totalSlots,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 48; // 24px margin each side
    final slotWidth = containerWidth / totalSlots;
    return (slotWidth * slotIndex) + (slotWidth / 2) - 28;
  }

  Widget _buildNavItem(int index) {
    final item = items[index];
    final isActive = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 70,
          child: Center(
            child: AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey('${item.label}_$isActive'),
                  color: isActive
                      ? kPrimary
                      : kTextSecondary.withValues(alpha: 0.6),
                  size: isActive ? 28 : 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
