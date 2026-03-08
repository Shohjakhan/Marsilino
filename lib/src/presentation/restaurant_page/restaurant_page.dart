import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../config/app_config.dart';
import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurants_repository.dart';
import '../../theme/app_theme.dart';
import '../common/gallery_carousel.dart';
import '../common/primary_button.dart';
import '../common/rounded_card.dart';
import 'booking_section.dart';
import '../qr_scan/qr_scan_page.dart';
import '../common/navigation_notifications.dart';

/// Restaurant landing page with full details.
///
/// Accepts a [Restaurant] model directly from the API to guarantee all
/// parsed fields (gallery, menu, locationLink, etc.) are preserved.
class RestaurantPage extends StatefulWidget {
  /// Restaurant ID for loading from API.
  final String? restaurantId;

  /// Pre-loaded restaurant model. All fields come straight from the API JSON.
  final Restaurant? initialRestaurant;

  const RestaurantPage({super.key, this.restaurantId, this.initialRestaurant})
    : assert(restaurantId != null || initialRestaurant != null);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final _restaurantsRepository = RestaurantsRepository();
  bool _isLiked = false;
  bool _isLoading = false;
  bool _isLikeLoading = false;

  /// The restaurant data driving the entire page.
  Restaurant? _restaurant;

  @override
  void initState() {
    super.initState();
    _restaurant = widget.initialRestaurant;
    _isLiked = _restaurant?.isLiked ?? false;

    if (widget.restaurantId != null) {
      _loadRestaurantDetails();
      _loadLikedStatus();
    }
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

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
        final fetched = result.restaurant!;
        final old = _restaurant;
        // Merge: prefer fetched data, fall back to initialRestaurant data.
        _restaurant = Restaurant(
          id: fetched.id,
          name: fetched.name.isNotEmpty ? fetched.name : (old?.name ?? ''),
          logo: fetched.logo ?? old?.logo,
          description: (fetched.description?.isNotEmpty == true)
              ? fetched.description
              : old?.description,
          hashtags: fetched.hashtags ?? old?.hashtags,
          workingHours: (fetched.workingHours?.isNotEmpty == true)
              ? fetched.workingHours
              : old?.workingHours,
          contactInformation:
              fetched.contactInformation ?? old?.contactInformation,
          socialMedia: fetched.socialMedia ?? old?.socialMedia,
          menu: fetched.menu ?? old?.menu,
          menuUrl: fetched.menuUrl ?? old?.menuUrl,
          menuImages: fetched.menuImages.isNotEmpty
              ? fetched.menuImages
              : (old?.menuImages ?? const []),
          locationLink: fetched.locationLink ?? old?.locationLink,
          locationText: (fetched.locationText?.isNotEmpty == true)
              ? fetched.locationText
              : old?.locationText,
          locationDescriptionEn:
              (fetched.locationDescriptionEn?.isNotEmpty == true)
              ? fetched.locationDescriptionEn
              : old?.locationDescriptionEn,
          locationDescriptionRu:
              (fetched.locationDescriptionRu?.isNotEmpty == true)
              ? fetched.locationDescriptionRu
              : old?.locationDescriptionRu,
          locationDescriptionUz:
              (fetched.locationDescriptionUz?.isNotEmpty == true)
              ? fetched.locationDescriptionUz
              : old?.locationDescriptionUz,
          cashbackPercentage:
              fetched.cashbackPercentage ?? old?.cashbackPercentage,
          tin: fetched.tin ?? old?.tin,
          tags: fetched.tags.isNotEmpty
              ? fetched.tags
              : (old?.tags ?? const []),
          galleryImages: fetched.galleryImages.isNotEmpty
              ? fetched.galleryImages
              : (old?.galleryImages ?? const []),
          latitude: fetched.latitude ?? old?.latitude,
          longitude: fetched.longitude ?? old?.longitude,
          bookingAvailable: fetched.bookingAvailable ?? old?.bookingAvailable,
          maxPeople: fetched.maxPeople ?? old?.maxPeople,
          availableTimes: fetched.availableTimes ?? old?.availableTimes,
          isLiked: fetched.isLiked || (old?.isLiked ?? false),
          averageRating: fetched.averageRating ?? old?.averageRating,
          totalRatings: fetched.totalRatings ?? old?.totalRatings,
        );
        _isLiked = _restaurant!.isLiked;
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

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _toggleLike() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.restaurantId == null || _isLikeLoading) return;

    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _isLikeLoading = true;
    });

    final result = wasLiked
        ? await _restaurantsRepository.unlikeRestaurant(widget.restaurantId!)
        : await _restaurantsRepository.likeRestaurant(widget.restaurantId!);

    if (!mounted) return;

    setState(() => _isLikeLoading = false);

    if (!result.success) {
      setState(() => _isLiked = wasLiked);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? l10n.failedUpdateFavorite),
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
    final l10n = AppLocalizations.of(context)!;
    final phone = _restaurant?.phone;
    if (phone == null || phone.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.callingSimulation(phone)),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openSocial(String platform, String handle) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.openingSocialSimulation(platform, handle)),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showMenuPreview() {
    if (_menuImages.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => _MenuPreviewDialog(imageUrls: _menuImages),
    );
  }

  void _navigateToMap() {
    final l10n = AppLocalizations.of(context)!;
    if (_restaurant == null) return;

    if (_restaurant!.latitude != null && _restaurant!.longitude != null) {
      Navigator.pop(context);

      NavigateToMapNotification(
        latitude: _restaurant!.latitude,
        longitude: _restaurant!.longitude,
        restaurantId: widget.restaurantId ?? _restaurant!.id,
      ).dispatch(context);
    } else if (_restaurant!.locationLink != null) {
      // Typically we'd use url_launcher here.
      // Using social simulation style to prevent crashing if uninstalled or unhandled.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.openingMapLink(_restaurant!.locationLink!)),
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

  void _redeemCashback() {
    final l10n = AppLocalizations.of(context)!;
    if (_restaurant == null) return;
    final id = widget.restaurantId ?? _restaurant!.id;
    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorMissingRestaurantId)));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScanPage(
          restaurantId: id,
          restaurantName: _restaurant!.name,
          cashbackPercent: _cashbackPercent,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  String get _name => _restaurant?.name ?? '';
  String get _description => _restaurant?.description ?? '';
  String _getAddress(BuildContext context) =>
      _restaurant?.displayAddress(
        Localizations.localeOf(context).languageCode,
      ) ??
      '';
  String get _workingHours => _restaurant?.workingHours ?? '';
  String get _phone => _restaurant?.phone ?? '';
  String? get _logoUrl => _restaurant?.logo;
  List<String> get _menuImages {
    final List<String> images = [];
    if (_restaurant?.menuImages.isNotEmpty == true) {
      images.addAll(_restaurant!.menuImages);
    } else if (_restaurant?.menuUrl != null) {
      images.add(_restaurant!.menuUrl!);
    }
    return images;
  }

  String? get _cashbackText => _restaurant?.cashbackText;
  String? get _instagram => _restaurant?.instagram;
  String? get _telegram => _restaurant?.telegram;
  List<String> get _galleryImages => _restaurant?.galleryImages ?? const [];
  List<String> get _tags => _restaurant?.tagsList ?? const [];
  double get _rating => _restaurant?.averageRating ?? 4.5;

  int get _cashbackPercent {
    final text = _cashbackText;
    if (text == null) return 0;
    final match = RegExp(r'(\d+)').firstMatch(text);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  bool get _hasLocationMap =>
      (_restaurant?.latitude != null && _restaurant?.longitude != null) ||
      _restaurant?.locationLink != null;
  bool _hasContactInfo(BuildContext context) =>
      _getAddress(context).isNotEmpty ||
      _hasLocationMap ||
      _phone.isNotEmpty ||
      _instagram != null ||
      _telegram != null;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_restaurant == null && _isLoading) {
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

    if (_restaurant == null) {
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
              Text(l10n.failedLoadRestaurant, style: kBodyStyle),
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
              if (_description.isNotEmpty)
                SliverToBoxAdapter(child: _buildDescriptionCard()),
              // Hashtags
              if (_tags.isNotEmpty)
                SliverToBoxAdapter(child: _buildHashtagsCard()),
              // Working hours
              if (_workingHours.isNotEmpty)
                SliverToBoxAdapter(child: _buildHoursCard()),
              // Contact info
              if (_hasContactInfo(context))
                SliverToBoxAdapter(child: _buildContactCard(context)),
              // Menu
              if (_menuImages.isNotEmpty)
                SliverToBoxAdapter(child: _buildMenuCard()),
              // Booking (behind feature flag)
              if (AppConfig.enableBookings)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: BookingSection(
                      restaurantName: _name,
                      restaurantId: widget.restaurantId ?? _restaurant!.id,
                      bookingAvailable: _restaurant!.bookingAvailable,
                      maxPeople: _restaurant!.maxPeople,
                      availableTimes: _restaurant!.availableTimes,
                    ),
                  ),
                ),
              // Bottom padding for floating button
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Floating bottom button
          if (_cashbackText != null) _buildFloatingButton(),
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
    final l10n = AppLocalizations.of(context)!;
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
              content: Text(l10n.shareSimulation),
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
    final images = _galleryImages
        .map((url) => CarouselNetworkImage(url))
        .toList();

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
              child: _logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _logoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kPrimary,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
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
                Text(_name, style: kTitleStyle.copyWith(fontSize: 22)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _rating.toStringAsFixed(1),
                      style: kSubtitleStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_cashbackText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kSecondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _cashbackText!,
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
              _description,
              style: kBodyStyle.copyWith(color: kTextSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtagsCard() {
    final l10n = AppLocalizations.of(context)!;
    if (_tags.isEmpty) return const SizedBox.shrink();

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
              children: _tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kSecondaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kSecondaryLight,
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
              _workingHours,
              style: kBodyStyle.copyWith(color: kTextSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final address = _getAddress(context);
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
            if (address.isNotEmpty) ...[
              GestureDetector(
                onTap: _navigateToMap,
                child: _buildContactRow(
                  icon: Icons.location_on_outlined,
                  text: address,
                  isActive: true,
                ),
              ),
              const SizedBox(height: 12),
            ] else if (_hasLocationMap) ...[
              GestureDetector(
                onTap: _navigateToMap,
                child: _buildContactRow(
                  icon: Icons.location_on_outlined,
                  text: l10n.viewOnMap,
                  isActive: true,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Phone
            if (_phone.isNotEmpty) ...[
              GestureDetector(
                onTap: _openPhone,
                child: _buildContactRow(
                  icon: Icons.phone_outlined,
                  text: _phone,
                  isActive: true,
                ),
              ),
            ],
            // Social links
            if (_instagram != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _openSocial('Instagram', _instagram!),
                child: _buildContactRow(
                  icon: Icons.camera_alt_outlined,
                  text: _instagram!,
                  isActive: true,
                ),
              ),
            ],
            if (_telegram != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _openSocial('Telegram', _telegram!),
                child: _buildContactRow(
                  icon: Icons.send_outlined,
                  text: _telegram!,
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
                      CachedNetworkImage(
                        imageUrl: _menuImages.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        placeholder: (_, __) => Container(
                          color: kTextSecondary.withValues(alpha: 0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kPrimary,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
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
        label: '${l10n.redeemCashback} ($_cashbackText)',
        onPressed: _redeemCashback,
      ),
    );
  }
}

/// Full-screen menu preview dialog supporting multiple images.
class _MenuPreviewDialog extends StatefulWidget {
  final List<String> imageUrls;

  const _MenuPreviewDialog({required this.imageUrls});

  @override
  State<_MenuPreviewDialog> createState() => _MenuPreviewDialogState();
}

class _MenuPreviewDialogState extends State<_MenuPreviewDialog> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _nextPage() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image PageView
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: kPrimary,
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
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
                );
              },
            ),
          ),
          // Navigation controls
          if (widget.imageUrls.length > 1) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 8,
                child: GestureDetector(
                  onTap: _previousPage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            if (_currentIndex < widget.imageUrls.length - 1)
              Positioned(
                right: 8,
                child: GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            // Page Indicator
            Positioned(
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.imageUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
