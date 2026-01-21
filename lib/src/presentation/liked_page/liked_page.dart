import 'package:flutter/material.dart';
import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurants_repository.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../restaurant_page/restaurant_page.dart';

/// Liked restaurants page showing all favorited restaurants.
class LikedPage extends StatefulWidget {
  const LikedPage({super.key});

  @override
  State<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends State<LikedPage> {
  final _restaurantsRepository = RestaurantsRepository();

  List<Restaurant> _likedRestaurants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLikedRestaurants();
  }

  Future<void> _loadLikedRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _restaurantsRepository.getLikedRestaurants();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.success) {
        _likedRestaurants = result.restaurants;
      } else {
        _error = result.error;
      }
    });
  }

  Future<void> _removeLike(int index) async {
    final restaurant = _likedRestaurants[index];

    // Optimistic removal
    setState(() {
      _likedRestaurants.removeAt(index);
    });

    // Call API
    final result = await _restaurantsRepository.unlikeRestaurant(restaurant.id);

    if (!mounted) return;

    if (!result.success) {
      // Revert on error
      setState(() {
        _likedRestaurants.insert(index, restaurant);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to remove from favorites'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from favorites'),
          backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _navigateToRestaurant(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantPage(restaurantId: restaurant.id),
      ),
    );
  }

  void _goToHome() {
    // Navigate to home tab
    // In a real app, this would use a navigation controller
    // For now, just pop if we're not at root
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? SingleChildScrollView(child: _buildErrorState())
                  : _likedRestaurants.isEmpty
                  ? SingleChildScrollView(child: _buildEmptyState())
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.favorite, color: kPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Liked', style: kTitleStyle.copyWith(fontSize: 24)),
                    Text(
                      _isLoading
                          ? 'Loading...'
                          : '${_likedRestaurants.length} restaurants',
                      style: kBodyStyle.copyWith(
                        color: kTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: kTextSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Something went wrong',
            style: kSubtitleStyle.copyWith(color: kTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Retry',
            onPressed: _loadLikedRestaurants,
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: kCardBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_border,
              size: 48,
              color: kTextSecondary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No favorites yet',
            style: kSubtitleStyle.copyWith(
              color: kTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Tap the heart icon on any restaurant to save it here',
              style: kBodyStyle.copyWith(
                color: kTextSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Explore Restaurants',
            onPressed: _goToHome,
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadLikedRestaurants,
      color: kPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _likedRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _likedRestaurants[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _LikedRestaurantCard(
              restaurant: restaurant,
              onTap: () => _navigateToRestaurant(restaurant),
              onRemove: () => _removeLike(index),
            ),
          );
        },
      ),
    );
  }
}

/// Restaurant card with remove option.
class _LikedRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _LikedRestaurantCard({
    required this.restaurant,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [kCardShadow],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildLogo(),
              const SizedBox(width: 14),
              Expanded(child: _buildInfo()),
              _buildRemoveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: restaurant.logo != null
            ? Image.network(
                restaurant.logo!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: kPrimary.withValues(alpha: 0.1),
      child: const Icon(Icons.restaurant, color: kPrimary, size: 28),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurant.name,
          style: kSubtitleStyle.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (restaurant.locationText != null)
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: kTextSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  restaurant.locationText!,
                  style: kBodyStyle.copyWith(
                    color: kTextSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        const SizedBox(height: 6),
        if (restaurant.discountPercentage != null &&
            restaurant.discountPercentage! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${restaurant.discountPercentage!.round()}% OFF',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return IconButton(
      onPressed: onRemove,
      icon: const Icon(Icons.favorite, color: Colors.red),
      style: IconButton.styleFrom(
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      ),
    );
  }
}
