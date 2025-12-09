import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../common/restaurant_card.dart';
import '../restaurant_page/restaurant_page.dart';

/// Model for a liked restaurant with visits count.
class LikedRestaurant {
  final RestaurantCardData data;
  final int visits;

  const LikedRestaurant({required this.data, this.visits = 1});

  LikedRestaurant copyWith({int? visits}) {
    return LikedRestaurant(data: data, visits: visits ?? this.visits);
  }
}

/// Liked restaurants page showing all favorited restaurants.
class LikedPage extends StatefulWidget {
  const LikedPage({super.key});

  @override
  State<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends State<LikedPage> {
  /// Sample liked restaurants for demo.
  /// In production, this would come from a state management solution.
  static final List<LikedRestaurant> _sampleLikedRestaurants = [
    const LikedRestaurant(
      data: RestaurantCardData(
        name: 'The Italian Kitchen',
        address: '123 Main St, Downtown',
        workingHours: '10:00 AM - 10:00 PM',
        logoUrl: 'https://picsum.photos/seed/like1/200',
        tags: ['family', 'italian', 'pasta'],
        discount: '10% off',
      ),
      visits: 5,
    ),
    const LikedRestaurant(
      data: RestaurantCardData(
        name: 'Sushi Master',
        address: '456 Oak Avenue',
        workingHours: '11:00 AM - 11:00 PM',
        logoUrl: 'https://picsum.photos/seed/like2/200',
        tags: ['japanese', 'sushi'],
      ),
      visits: 3,
    ),
    const LikedRestaurant(
      data: RestaurantCardData(
        name: 'Seoul Kitchen',
        address: '432 K-Town Street',
        workingHours: '11:00 AM - 10:00 PM',
        logoUrl: 'https://picsum.photos/seed/like3/200',
        tags: ['korean', 'bbq', 'family'],
        discount: '15% off',
      ),
      visits: 8,
    ),
  ];

  List<LikedRestaurant> _likedRestaurants = [];
  bool _showEmpty = false; // Toggle for demo

  @override
  void initState() {
    super.initState();
    _likedRestaurants = List.from(_sampleLikedRestaurants);
  }

  void _removeLike(int index) {
    setState(() {
      _likedRestaurants.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from favorites'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _likedRestaurants = List.from(_sampleLikedRestaurants);
            });
          },
        ),
      ),
    );
  }

  void _navigateToRestaurant(RestaurantCardData data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RestaurantPage(initialData: data.toRestaurantData()),
      ),
    );
  }

  void _goToHome() {
    // Navigate to home tab - in real app would use tab controller
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Home tab'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _likedRestaurants.isEmpty || _showEmpty;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(child: isEmpty ? _buildEmptyState() : _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Favorites', style: kTitleStyle.copyWith(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                _likedRestaurants.isEmpty
                    ? 'No favorites yet'
                    : '${_likedRestaurants.length} saved restaurants',
                style: kBodyStyle.copyWith(color: kTextSecondary),
              ),
            ],
          ),
          // Demo toggle for empty state
          GestureDetector(
            onTap: () => setState(() => _showEmpty = !_showEmpty),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [kCardShadow],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showEmpty ? Icons.visibility_off : Icons.visibility,
                    size: 16,
                    color: kTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showEmpty ? 'Show list' : 'Demo empty',
                    style: kBodyStyle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Empty icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 56,
                color: kPrimary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "You haven't liked any\nrestaurants yet",
              style: kTitleStyle.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Explore restaurants and tap the heart icon to save your favorites here.',
              style: kBodyStyle.copyWith(color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Explore Restaurants',
              onPressed: _goToHome,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _likedRestaurants.length,
      itemBuilder: (context, index) {
        final likedRestaurant = _likedRestaurants[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _LikedRestaurantCard(
            data: likedRestaurant.data,
            visits: likedRestaurant.visits,
            onTap: () => _navigateToRestaurant(likedRestaurant.data),
            onRemove: () => _removeLike(index),
          ),
        );
      },
    );
  }
}

/// Restaurant card with visits badge and remove option.
class _LikedRestaurantCard extends StatelessWidget {
  final RestaurantCardData data;
  final int visits;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _LikedRestaurantCard({
    required this.data,
    required this.visits,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(kCardRadius),
          boxShadow: const [kCardShadow],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Logo
                  _buildLogo(),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(child: _buildInfo()),
                ],
              ),
            ),
            // Discount pill (top-right)
            if (data.discount != null) _buildDiscountPill(),
            // Visits badge (bottom-right)
            _buildVisitsBadge(),
            // Remove button (top-left corner on long press area)
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kBackground,
        border: Border.all(
          color: kTextSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: data.logoUrl != null
            ? Image.network(
                data.logoUrl!,
                fit: BoxFit.cover,
                width: 64,
                height: 64,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.restaurant,
                  size: 28,
                  color: kTextSecondary,
                ),
              )
            : const Icon(Icons.restaurant, size: 28, color: kTextSecondary),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Name
        Text(
          data.name,
          style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Address
        Text(
          data.address,
          style: kBodyStyle.copyWith(color: kTextSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // Working hours
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 12,
              color: kTextSecondary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              data.workingHours,
              style: kBodyStyle.copyWith(
                fontSize: 12,
                color: kTextSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        if (data.tags.isNotEmpty) ...[const SizedBox(height: 8), _buildTags()],
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: data.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: kPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDiscountPill() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPrimary, kPrimaryBold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          data.discount!,
          style: const TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildVisitsBadge() {
    return Positioned(
      bottom: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: kTextSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kTextSecondary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_outlined, size: 12, color: kTextSecondary),
            const SizedBox(width: 4),
            Text(
              'Visits: $visits',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
