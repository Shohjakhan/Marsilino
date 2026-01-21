import 'package:flutter/material.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../data/models/restaurant.dart' as api;
import '../../data/repositories/restaurants_repository.dart';
import '../../theme/app_theme.dart';
import '../common/gallery_carousel.dart';
import '../common/primary_button.dart';
import '../common/rounded_card.dart';
import 'redeem_page.dart';

/// Restaurant data model for the landing page.
class RestaurantData {
  final String name;
  final String description;
  final String address;
  final String workingHours;
  final String phone;
  final double rating;
  final List<String> tags;
  final List<String> galleryImages;
  final String? logoUrl;
  final String? menuImageUrl;
  final String? discount;
  final String? instagram;
  final String? telegram;

  // Availability
  final bool? bookingAvailable;
  final int? maxPeople;
  final List<String>? availableTimes;

  const RestaurantData({
    required this.name,
    required this.description,
    required this.address,
    required this.workingHours,
    required this.phone,
    required this.rating,
    this.tags = const [],
    this.galleryImages = const [],
    this.logoUrl,
    this.menuImageUrl,
    this.discount,
    this.instagram,
    this.telegram,
    this.bookingAvailable,
    this.maxPeople,
    this.availableTimes,
  });

  /// Extract discount percentage from discount string (e.g., "10% off" -> 10).
  int get discountPercent {
    if (discount == null) return 0;
    final match = RegExp(r'(\d+)').firstMatch(discount!);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// Create from API model.
  factory RestaurantData.fromApiModel(api.Restaurant r) {
    return RestaurantData(
      name: r.name,
      description: r.description ?? '',
      address: r.locationText ?? '',
      workingHours: r.workingHours ?? '',
      phone: r.phone ?? '',
      rating: 4.5, // API doesn't provide rating yet
      tags: r.tagsList,
      galleryImages: r.galleryImages,
      logoUrl: r.logo,
      discount: r.discountText,
      instagram: r.instagram,
      telegram: r.telegram,
      bookingAvailable: r.bookingAvailable,
      maxPeople: r.maxPeople,
      availableTimes: r.availableTimes,
    );
  }
}

/// Restaurant landing page with full details.
class RestaurantPage extends StatefulWidget {
  /// Restaurant ID for loading from API.
  final String? restaurantId;

  /// Initial data to display while loading (optional).
  final RestaurantData? initialData;

  const RestaurantPage({super.key, this.restaurantId, this.initialData})
    : assert(restaurantId != null || initialData != null);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final _restaurantsRepository = RestaurantsRepository();
  bool _isLiked = false;
  bool _isLoading = false;
  bool _isLikeLoading = false;
  RestaurantData? _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    if (widget.restaurantId != null) {
      _loadRestaurantDetails();
      _loadLikedStatus();
    }
  }

  Future<void> _loadRestaurantDetails() async {
    if (widget.restaurantId == null) return;

    setState(() => _isLoading = true);

    final result = await _restaurantsRepository.getRestaurantDetail(
      widget.restaurantId!,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.success && result.restaurant != null) {
        _data = RestaurantData.fromApiModel(result.restaurant!);
      }
    });
  }

  Future<void> _loadLikedStatus() async {
    if (widget.restaurantId == null) return;

    final result = await _restaurantsRepository.getLikedRestaurantIds();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _isLiked = result.ids.contains(widget.restaurantId);
      });
    }
  }

  Future<void> _toggleLike() async {
    if (widget.restaurantId == null || _isLikeLoading) return;

    // Optimistic update
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _isLikeLoading = true;
    });

    // Send request
    final result = wasLiked
        ? await _restaurantsRepository.unlikeRestaurant(widget.restaurantId!)
        : await _restaurantsRepository.likeRestaurant(widget.restaurantId!);

    if (!mounted) return;

    setState(() => _isLikeLoading = false);

    if (!result.success) {
      // Revert on error
      setState(() => _isLiked = wasLiked);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to update favorite'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _openPhone() {
    if (_data == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${_data!.phone} (simulation)'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openSocial(String platform, String handle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $platform: $handle (simulation)'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showMenuPreview() {
    if (_data?.menuImageUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => _MenuPreviewDialog(imageUrl: _data!.menuImageUrl!),
    );
  }

  void _redeemDiscount() {
    if (_data == null) return;
    if (widget.restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing restaurant ID')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RedeemPage(
          restaurantId: widget.restaurantId!,
          restaurantName: _data!.name,
          logoUrl: _data!.logoUrl,
          discountPercent: _data!.discountPercent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null && _isLoading) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
          ),
        ),
      );
    }

    if (_data == null) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: kTextSecondary),
              const SizedBox(height: 16),
              Text('Failed to load restaurant', style: kBodyStyle),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              // App bar with back button
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                expandedHeight: 0,
                leading: _buildBackButton(),
                actions: [_buildShareButton()],
              ),
              // Gallery
              SliverToBoxAdapter(child: _buildGallery()),
              // Restaurant header
              SliverToBoxAdapter(child: _buildHeader()),
              // Description
              SliverToBoxAdapter(child: _buildDescriptionCard()),
              // Hashtags
              SliverToBoxAdapter(child: _buildHashtagsCard()),
              // Working hours
              SliverToBoxAdapter(child: _buildHoursCard()),
              // Contact info
              SliverToBoxAdapter(child: _buildContactCard()),
              // Menu
              if (_data!.menuImageUrl != null)
                SliverToBoxAdapter(child: _buildMenuCard()),
              // Bottom padding for floating button
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Floating bottom button
          if (_data!.discount != null) _buildFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kCardBg.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: const [kCardShadow],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: kTextPrimary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildShareButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kCardBg.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: const [kCardShadow],
      ),
      child: IconButton(
        icon: const Icon(Icons.share_outlined, color: kTextPrimary),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Share (simulation)'),
              backgroundColor: kPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGallery() {
    final images = _data!.galleryImages.isNotEmpty
        ? _data!.galleryImages.map((url) => CarouselNetworkImage(url)).toList()
        : [const CarouselNetworkImage('https://picsum.photos/800/400')];

    return GalleryCarousel(
      images: images,
      height: 250,
      borderRadius: 0,
      showDots: true,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kCardBg,
              border: Border.all(
                color: kTextSecondary.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: const [kCardShadow],
            ),
            child: ClipOval(
              child: _data!.logoUrl != null
                  ? Image.network(
                      _data!.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.restaurant,
                        size: 32,
                        color: kTextSecondary,
                      ),
                    )
                  : const Icon(
                      Icons.restaurant,
                      size: 32,
                      color: kTextSecondary,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Name and rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_data!.name, style: kTitleStyle.copyWith(fontSize: 22)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _data!.rating.toStringAsFixed(1),
                      style: kSubtitleStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_data!.discount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _data!.discount!,
                          style: const TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Heart button
          GestureDetector(
            onTap: _toggleLike,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isLiked ? Colors.red.withValues(alpha: 0.1) : kCardBg,
                shape: BoxShape.circle,
                boxShadow: const [kCardShadow],
              ),
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : kTextSecondary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RoundedCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.about,
              style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _data!.description,
              style: kBodyStyle.copyWith(color: kTextSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtagsCard() {
    final l10n = AppLocalizations.of(context)!;
    if (_data!.tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RoundedCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tags,
              style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _data!.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursCard() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RoundedCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: kPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.workingHours,
                  style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _data!.workingHours,
              style: kBodyStyle.copyWith(color: kTextSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RoundedCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contact,
              style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Address
            _buildContactRow(
              icon: Icons.location_on_outlined,
              text: _data!.address,
            ),
            const SizedBox(height: 12),
            // Phone
            GestureDetector(
              onTap: _openPhone,
              child: _buildContactRow(
                icon: Icons.phone_outlined,
                text: _data!.phone,
                isActive: true,
              ),
            ),
            // Social links
            if (_data!.instagram != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _openSocial('Instagram', _data!.instagram!),
                child: _buildContactRow(
                  icon: Icons.camera_alt_outlined,
                  text: _data!.instagram!,
                  isActive: true,
                ),
              ),
            ],
            if (_data!.telegram != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _openSocial('Telegram', _data!.telegram!),
                child: _buildContactRow(
                  icon: Icons.send_outlined,
                  text: _data!.telegram!,
                  isActive: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String text,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? kPrimary.withValues(alpha: 0.1)
                : kTextSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isActive ? kPrimary : kTextSecondary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: kBodyStyle.copyWith(
              color: isActive ? kPrimary : kTextSecondary,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        if (isActive)
          Icon(
            Icons.chevron_right,
            color: kPrimary.withValues(alpha: 0.5),
            size: 20,
          ),
      ],
    );
  }

  Widget _buildMenuCard() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RoundedCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: kPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.menu,
                  style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showMenuPreview,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: kTextSecondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _data!.menuImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: kTextSecondary.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.menu_book,
                            size: 48,
                            color: kTextSecondary,
                          ),
                        ),
                      ),
                      // Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                      // Tap hint
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.zoom_in,
                                size: 16,
                                color: kTextPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.viewFullMenu,
                                style: kBodyStyle.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: PrimaryButton(
        label: '${l10n.redeemDiscount} (${_data!.discount})',
        onPressed: _redeemDiscount,
      ),
    );
  }
}

/// Full-screen menu preview dialog.
class _MenuPreviewDialog extends StatelessWidget {
  final String imageUrl;

  const _MenuPreviewDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: kCardBg,
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: kTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
