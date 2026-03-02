import 'package:flutter/material.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurants_repository.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../common/restaurant_card.dart';
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

  Future<void> _removeLike(int index, AppLocalizations l10n) async {
    final restaurant = _likedRestaurants[index];

    // Optimistic removal
    setState(() {
      _likedRestaurants.removeAt(index);
    });

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
          backgroundColor: kError,
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
          content: Text(l10n.removedFromFavorites),
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
        builder: (context) => RestaurantPage(
          restaurantId: restaurant.id,
          initialRestaurant: restaurant,
        ),
      ),
    );
  }

  void _goToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  RestaurantCardData _toCardData(Restaurant r) {
    return RestaurantCardData(
      name: r.name,
      address: r.locationText ?? '',
      workingHours: r.workingHours ?? '',
      logoUrl: r.logo,
      tags: r.tagsList,
      cashback: r.cashbackText,
      latitude: r.latitude,
      longitude: r.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? SingleChildScrollView(child: _buildErrorState(l10n))
                  : _likedRestaurants.isEmpty
                  ? SingleChildScrollView(child: _buildEmptyState(l10n))
                  : _buildList(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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
                    Text(l10n.liked, style: kTitleStyle.copyWith(fontSize: 24)),
                    Text(
                      _isLoading
                          ? l10n.loading
                          : l10n.restaurantsCount(_likedRestaurants.length),
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

  Widget _buildErrorState(AppLocalizations l10n) {
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
            label: l10n.tryAgain,
            onPressed: _loadLikedRestaurants,
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
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
            l10n.noFavoritesYet,
            style: kSubtitleStyle.copyWith(
              color: kTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.noFavoritesSub,
              style: kBodyStyle.copyWith(
                color: kTextSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: l10n.exploreRestaurants,
            onPressed: _goToHome,
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Same rich card as home page
                RestaurantCard(
                  data: _toCardData(restaurant),
                  onTap: () => _navigateToRestaurant(restaurant),
                ),
                // Unlike button overlay (top-left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => _removeLike(index, l10n),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kError.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kError.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: kError,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
