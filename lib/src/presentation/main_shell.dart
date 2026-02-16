import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import 'common/bottom_nav.dart';
import 'home/home_page.dart';
import 'liked_page/liked_page.dart';
import 'map_page/map_page.dart';
import 'profile_page/profile_page.dart';
import 'common/navigation_notifications.dart';

/// Main app shell with bottom tab navigation.
/// Contains 4 tabs: Home, Map, Likes, Profile.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  /// Pages for each tab.
  Widget _mapPage = const MapPage();

  List<Widget> get _pages => [
    const HomePage(),
    _mapPage,
    const LikedPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navItems = [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: l10n.home,
      ),
      BottomNavItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
        label: l10n.map,
      ),
      BottomNavItem(
        icon: Icons.favorite_outline,
        activeIcon: Icons.favorite,
        label: l10n.saved,
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: l10n.profile,
      ),
    ];

    return NotificationListener<NavigateToMapNotification>(
      onNotification: (notification) {
        setState(() {
          _currentIndex = 1; // Map tab
          _mapPage = MapPage(
            initialLat: notification.latitude,
            initialLng: notification.longitude,
            restaurantId: notification.restaurantId,
            key: UniqueKey(), // Force rebuild to trigger jump
          );
        });
        return true;
      },
      child: Scaffold(
        backgroundColor: kBackground,
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: navItems,
        ),
      ),
    );
  }
}
