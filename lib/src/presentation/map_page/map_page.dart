import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurants_repository.dart';
import '../../theme/app_theme.dart';
import '../restaurant_page/restaurant_page.dart';
import 'google_map_marker_helper.dart';

/// Map page with Google Maps, user location, and restaurant markers.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedFilters = {};
  final _restaurantsRepository = RestaurantsRepository();

  GoogleMapController? _mapController;
  Position? _userPosition;
  List<Restaurant> _restaurants = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = true;
  bool _locationPermissionDenied = false;
  String? _error;

  Set<Marker> _markers = {};

  // Default center: Tashkent
  static const _defaultCenter = LatLng(41.2995, 69.2401);
  static const _defaultZoom = 13.0;

  /// Available filter chips.
  static const List<String> _filterOptions = [
    'Family',
    'Bars',
    'Korean',
    'Halal',
    'Italian',
    'Fast Food',
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() => _isLoading = true);

    // Request location permission
    final status = await Permission.location.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() {
        _locationPermissionDenied = true;
        _isLoading = false;
      });
      // Still load restaurants for default location
      _loadNearbyRestaurants(_defaultCenter.latitude, _defaultCenter.longitude);
      return;
    }

    // Get current position
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _userPosition = position;
      });

      // Move camera to user location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          _defaultZoom,
        ),
      );

      // Load nearby restaurants
      _loadNearbyRestaurants(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _error = 'Could not get location';
        _isLoading = false;
      });
      // Fall back to default location
      _loadNearbyRestaurants(_defaultCenter.latitude, _defaultCenter.longitude);
    }
  }

  Future<void> _loadNearbyRestaurants(double lat, double lng) async {
    setState(() => _isLoading = true);

    final result = await _restaurantsRepository.getNearbyRestaurants(
      latitude: lat,
      longitude: lng,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.success) {
        _restaurants = result.restaurants;
        _buildMarkers();
      } else {
        _error = result.error;
      }
    });
  }

  Future<void> _buildMarkers() async {
    final newMarkers = <Marker>{};

    // Add restaurant markers
    for (final restaurant in _restaurants) {
      if (restaurant.latitude == null || restaurant.longitude == null) continue;

      final isSelected = _selectedRestaurant?.id == restaurant.id;
      final icon = await GoogleMapMarkerHelper.createMarkerIcon(
        logoUrl: restaurant.logo,
        isSelected: isSelected,
      );

      newMarkers.add(
        Marker(
          markerId: MarkerId('restaurant_${restaurant.id}'),
          position: LatLng(restaurant.latitude!, restaurant.longitude!),
          icon: icon,
          onTap: () => _onMarkerTap(restaurant),
        ),
      );
    }

    // Add user location marker
    if (_userPosition != null) {
      final userIcon = await GoogleMapMarkerHelper.createUserLocationMarker();
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          icon: userIcon,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }

  void _onMarkerTap(Restaurant restaurant) {
    setState(() {
      _selectedRestaurant = _selectedRestaurant?.id == restaurant.id
          ? null
          : restaurant;
    });
    _buildMarkers(); // Rebuild markers to update selected state
  }

  void _navigateToRestaurant(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantPage(
          restaurantId: restaurant.id,
          initialData: RestaurantData(
            name: restaurant.name,
            description: restaurant.description ?? '',
            address: restaurant.locationText ?? '',
            workingHours: restaurant.workingHours ?? '',
            phone: restaurant.phone ?? '',
            rating: 4.5,
            tags: restaurant.tagsList,
            galleryImages: restaurant.galleryImages,
            logoUrl: restaurant.logo,
            discount: restaurant.discountText,
            instagram: restaurant.instagram,
            telegram: restaurant.telegram,
          ),
        ),
      ),
    );
  }

  void _centerOnUser() {
    if (_userPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _locationPermissionDenied
                ? 'Location permission denied. Enable in settings.'
                : 'Getting location...',
          ),
          backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        _defaultZoom,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Map
            _buildMap(),
            // Top overlay: Search + Filters
            Positioned(top: 0, left: 0, right: 0, child: _buildTopOverlay()),
            // Error message
            if (_error != null && !_isLoading)
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: kBodyStyle.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            // Loading indicator
            if (_isLoading)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kCardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [kCardShadow],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading restaurants...',
                          style: kBodyStyle.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Bottom card when marker selected
            if (_selectedRestaurant != null) _buildBottomCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _userPosition != null
            ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
            : _defaultCenter,
        zoom: _defaultZoom,
      ),
      markers: _markers,
      myLocationEnabled: false, // We use custom user location marker
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onTap: (_) {
        setState(() => _selectedRestaurant = null);
        _buildMarkers();
      },
    );
  }

  Widget _buildTopOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kBackground,
            kBackground.withValues(alpha: 0.95),
            kBackground.withValues(alpha: 0),
          ],
          stops: const [0, 0.7, 1],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          _buildSearchBar(),
          const SizedBox(height: 12),
          // Filter chips
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [kCardShadow],
      ),
      child: TextField(
        controller: _searchController,
        style: kBodyStyle.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search restaurants nearby',
          hintStyle: kBodyStyle.copyWith(fontSize: 15, color: kTextSecondary),
          prefixIcon: Icon(
            Icons.search,
            color: kTextSecondary.withValues(alpha: 0.7),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.my_location, color: kPrimary),
            onPressed: _centerOnUser,
          ),
          filled: true,
          fillColor: kCardBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilters.contains(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _toggleFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kSecondary : kCardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [kCardShadow],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : kTextPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomCard() {
    final restaurant = _selectedRestaurant!;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: GestureDetector(
        onTap: () => _navigateToRestaurant(restaurant),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(kCardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kBackground,
                  border: Border.all(
                    color: kTextSecondary.withValues(alpha: 0.2),
                  ),
                ),
                child: ClipOval(
                  child: restaurant.logo != null
                      ? Image.network(
                          restaurant.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.restaurant,
                            color: kTextSecondary,
                          ),
                        )
                      : const Icon(Icons.restaurant, color: kTextSecondary),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: kSubtitleStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (restaurant.discountText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kSecondaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              restaurant.discountText!,
                              style: const TextStyle(
                                fontFamily: '.SF Pro Text',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Address
                    Text(
                      restaurant.locationText ?? '',
                      style: kBodyStyle.copyWith(
                        color: kTextSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Tags
                    if (restaurant.tagsList.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        children: restaurant.tagsList.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kSecondaryLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
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
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: kTextSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
