import 'package:flutter/material.dart';
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

  /// Discount text (e.g., "10% off"). Null if no discount.
  final String? discount;

  const RestaurantCardData({
    required this.name,
    required this.address,
    required this.workingHours,
    this.logoUrl,
    this.tags = const [],
    this.discount,
  });

  /// Convert to full RestaurantData for the landing page.
  RestaurantData toRestaurantData() {
    return RestaurantData(
      name: name,
      description:
          'A wonderful restaurant serving delicious food in a welcoming atmosphere. Visit us to experience great cuisine and excellent service.',
      address: address,
      workingHours: workingHours,
      phone: '+998 90 123 45 67',
      rating: 4.5,
      tags: tags,
      galleryImages: [
        'https://picsum.photos/seed/${name.hashCode}/800/400',
        'https://picsum.photos/seed/${name.hashCode + 1}/800/400',
        'https://picsum.photos/seed/${name.hashCode + 2}/800/400',
      ],
      logoUrl: logoUrl,
      menuImageUrl: 'https://picsum.photos/seed/${name.hashCode}menu/600/800',
      discount: discount,
    );
  }
}

/// Restaurant card used on Home & Liked lists.
/// Displays logo, name, address, hours, tags, and optional discount pill.
class RestaurantCard extends StatelessWidget {
  /// Restaurant data to display.
  final RestaurantCardData data;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Card height (default 140).
  final double height;

  const RestaurantCard({
    super.key,
    required this.data,
    this.onTap,
    this.height = 140,
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
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left: Circular logo
                  _buildLogo(),
                  const SizedBox(width: 16),
                  // Middle: Restaurant info
                  Expanded(child: _buildInfo()),
                ],
              ),
            ),
            // Top-right: Discount pill
            if (data.discount != null) _buildDiscountPill(),
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
            ? _buildLogoImage()
            : const Icon(Icons.restaurant, size: 28, color: kTextSecondary),
      ),
    );
  }

  Widget _buildLogoImage() {
    if (data.logoUrl!.startsWith('http')) {
      return Image.network(
        data.logoUrl!,
        fit: BoxFit.cover,
        width: 64,
        height: 64,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.restaurant, size: 28, color: kTextSecondary),
      );
    }
    return Image.asset(
      data.logoUrl!,
      fit: BoxFit.cover,
      width: 64,
      height: 64,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.restaurant, size: 28, color: kTextSecondary),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Restaurant name
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

  Widget _buildDiscountPill() {
    return Positioned(
      top: 12,
      right: 12,
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

  void _navigateToRestaurant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RestaurantPage(initialData: data.toRestaurantData()),
      ),
    );
  }
}
