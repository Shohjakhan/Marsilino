import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/restaurant.dart';
import '../../theme/app_theme.dart';
import '../restaurant_page/restaurant_page.dart';

/// Data model for a restaurant displayed in cards.
class RestaurantCardData {
  /// Restaurant name.
  final String name;

  /// Short address.
  final String address;

  /// Working hours text.
  final String workingHours;

  /// Logo image URL or asset path.
  final String? logoUrl;

  /// Tags/hashtags (e.g., "family", "bar").
  final List<String> tags;

  /// Cashback text (e.g., "10% cashback"). Null if no cashback.
  final String? cashback;
  final double? latitude;
  final double? longitude;
  final double? averageRating;

  const RestaurantCardData({
    required this.name,
    required this.address,
    required this.workingHours,
    this.logoUrl,
    this.tags = const [],
    this.cashback,
    this.latitude,
    this.longitude,
    this.averageRating,
  });

  /// Convert to a Restaurant model for the landing page.
  Restaurant toRestaurant() {
    return Restaurant(
      id: '',
      name: name,
      logo: logoUrl,
      description:
          'A wonderful restaurant serving delicious food in a welcoming atmosphere. Visit us to experience great cuisine and excellent service.',
      locationText: address,
      workingHours: workingHours,
      galleryImages: [
        'https://picsum.photos/seed/${name.hashCode}/800/400',
        'https://picsum.photos/seed/${name.hashCode + 1}/800/400',
        'https://picsum.photos/seed/${name.hashCode + 2}/800/400',
      ],
      menuUrl: 'https://picsum.photos/seed/${name.hashCode}menu/600/800',
      latitude: latitude,
      longitude: longitude,
      averageRating: averageRating,
    );
  }
}

/// Restaurant card used on Home & Liked lists.
/// Displays logo, name, address, hours, tags, and optional cashback pill.
class RestaurantCard extends StatelessWidget {
  /// Restaurant data to display.
  final RestaurantCardData data;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Optional card height. If null, sizes to contents.
  final double? height;

  const RestaurantCard({
    super.key,
    required this.data,
    this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _navigateToRestaurant(context),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(kCardRadius),
          boxShadow: const [kCardShadow],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Circular logo
                  _buildLogo(),
                  const SizedBox(width: 14),
                  // Middle: Restaurant info
                  Expanded(child: _buildInfo()),
                  if (data.averageRating != null) ...[
                    const SizedBox(width: 12),
                    // Right: Rating
                    _buildRating(),
                  ],
                ],
              ),
            ),
            // Top-right: Cashback pill
            if (data.cashback != null) _buildCashbackPill(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 56,
      height: 56,
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
            ? _buildLogoImage()
            : const Icon(Icons.restaurant, size: 24, color: kTextSecondary),
      ),
    );
  }

  Widget _buildLogoImage() {
    if (data.logoUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: data.logoUrl!,
        fit: BoxFit.cover,
        width: 56,
        height: 56,
        placeholder: (_, __) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
          ),
        ),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.restaurant, size: 24, color: kTextSecondary),
      );
    }
    return Image.asset(
      data.logoUrl!,
      fit: BoxFit.cover,
      width: 56,
      height: 56,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.restaurant, size: 24, color: kTextSecondary),
    );
  }

  Widget _buildRating() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.star_rounded,
          size: 25,
          color: Color(0xFFFFB800), // Gold star
        ),
        const SizedBox(height: 2),
        Text(
          data.averageRating!.toStringAsFixed(1),
          style: kSubtitleStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Restaurant name
        Text(
          data.name,
          style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (data.address.isNotEmpty) ...[
          const SizedBox(height: 4),
          // Address
          Text(
            data.address,
            style: kBodyStyle.copyWith(color: kTextSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (data.workingHours.isNotEmpty) ...[
          const SizedBox(height: 6),
          // Working hours
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: kTextSecondary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                data.workingHours,
                style: kBodyStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
            ],
          ),
        ],
        if (data.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Tags
          _buildTags(),
        ],
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
            color: kSecondaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: kSecondaryLight,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCashbackPill() {
    return Positioned(
      top: -12,
      right: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kSecondaryLight, kSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kSecondary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          data.cashback!,
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

  void _navigateToRestaurant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RestaurantPage(initialRestaurant: data.toRestaurant()),
      ),
    );
  }
}
