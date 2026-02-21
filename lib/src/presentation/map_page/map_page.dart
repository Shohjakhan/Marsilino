import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../domain/restaurants/restaurants_cubit.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurants_repository.dart';
import '../../theme/app_theme.dart';
import '../restaurant_page/restaurant_page.dart';
import 'map_marker_helper.dart';

/// Map page with Yandex Maps, user location, and restaurant markers.
class MapPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? restaurantId;

  const MapPage({
    super.key,
    this.initialLat,
    this.initialLng,
    this.restaurantId,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();

  YandexMapController? _mapController;
  Position? _userPosition;
  List<Restaurant> _restaurants = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = true;
  bool _locationPermissionDenied = false;
  String? _error;
  double _currentZoom = _defaultZoom;

  List<MapObject> _mapObjects = [];

  // Default center: Tashkent
  static const _defaultCenter = Point(latitude: 41.2995, longitude: 69.2401);
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
    if (widget.initialLat != null && widget.initialLng != null) {
      _isLoading = true;
      _loadNearbyRestaurants(widget.initialLat!, widget.initialLng!);
    } else {
      _initLocation();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() => _isLoading = true);

    final status = await Permission.location.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() {
        _locationPermissionDenied = true;
        _isLoading = false;
      });
      _loadNearbyRestaurants(_defaultCenter.latitude, _defaultCenter.longitude);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (RestaurantsRepository.kEnableMockData) {
        setState(() {
          _userPosition = position;
        });

        _mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            const CameraPosition(target: _defaultCenter, zoom: 13.0),
          ),
          animation: const MapAnimation(
            type: MapAnimationType.smooth,
            duration: 1.0,
          ),
        );
        _loadNearbyRestaurants(41.2995, 69.2401);
        return;
      }

      setState(() {
        _userPosition = position;
      });

      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: position.latitude,
              longitude: position.longitude,
            ),
            zoom: _defaultZoom,
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1.0,
        ),
      );

      _loadNearbyRestaurants(position.latitude, position.longitude);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.couldNotGetLocation;
        _isLoading = false;
      });
      _loadNearbyRestaurants(_defaultCenter.latitude, _defaultCenter.longitude);
    }
  }

  Future<void> _loadNearbyRestaurants(double lat, double lng) async {
    // We use the Cubit now.
    context.read<RestaurantsCubit>().loadNearbyRestaurants(lat, lng);
  }

  Future<void> _buildMarkers() async {
    final newMapObjects = <MapObject>[];

    for (final restaurant in _restaurants) {
      if (restaurant.latitude == null || restaurant.longitude == null) continue;

      final isSelected = _selectedRestaurant?.id == restaurant.id;

      double zoomScale = 1.0;
      if (_currentZoom > 13) {
        // Grow faster when zooming in (aggressive scaling)
        zoomScale = 1.0 + (_currentZoom - 13) * 0.8;
      } else if (_currentZoom < 13) {
        // Shrink faster when zooming out
        zoomScale = 1.0 - (13 - _currentZoom) * 0.25;
      }
      zoomScale = zoomScale.clamp(0.4, 4.0);

      final icon = await MapMarkerHelper.createMarkerIcon(
        logoUrl: restaurant.logo,
        isSelected: isSelected,
      );

      newMapObjects.add(
        PlacemarkMapObject(
          mapId: MapObjectId('restaurant_${restaurant.id}'),
          point: Point(
            latitude: restaurant.latitude!,
            longitude: restaurant.longitude!,
          ),
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: icon,
              scale: zoomScale,
              anchor: const Offset(0.5, 1.0), // Pin tip at bottom center
            ),
          ),
          text: PlacemarkText(
            text: restaurant.name,
            style: PlacemarkTextStyle(
              size: (8 + (_currentZoom - 13) * 0.5).clamp(8.0, 14.0),
              placement: TextStylePlacement.bottom,
              offset: 2,
            ),
          ),
          opacity: 1,
          onTap: (MapObject mapObject, Point point) {
            _onMarkerTap(restaurant);
          },
        ),
      );
    }

    if (_userPosition != null) {
      final userIcon = await MapMarkerHelper.createUserLocationMarker();
      newMapObjects.add(
        PlacemarkMapObject(
          mapId: const MapObjectId('user_location'),
          point: Point(
            latitude: _userPosition!.latitude,
            longitude: _userPosition!.longitude,
          ),
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(image: userIcon, scale: 1),
          ),
          opacity: 1,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _mapObjects = newMapObjects;
      });
    }
  }

  void _toggleFilter(String filter) {
    context.read<RestaurantsCubit>().applyFilter(filter);
  }

  void _onMarkerTap(Restaurant restaurant) {
    setState(() {
      if (_selectedRestaurant?.id == restaurant.id) {
        _selectedRestaurant = null;
      } else {
        _selectedRestaurant = restaurant;
      }
    });
    _buildMarkers();
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
            cashback: restaurant.cashbackText,
            instagram: restaurant.instagram,
            telegram: restaurant.telegram,
          ),
        ),
      ),
    );
  }

  void _centerOnUser() {
    final l10n = AppLocalizations.of(context)!;
    if (_userPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _locationPermissionDenied
                ? l10n.locationPermissionDenied
                : l10n.gettingLocation,
          ),
          backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: _userPosition!.latitude,
            longitude: _userPosition!.longitude,
          ),
          zoom: _defaultZoom,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: BlocConsumer<RestaurantsCubit, RestaurantsState>(
          listener: (context, state) {
            if (state is RestaurantsLoaded) {
              setState(() {
                _restaurants = state.filteredRestaurants;
                _isLoading = false;
                _error = null;
              });

              // Initial selection logic (only if not already selected)
              if (widget.restaurantId != null && _selectedRestaurant == null) {
                try {
                  _selectedRestaurant = _restaurants.firstWhere(
                    (r) => r.id == widget.restaurantId,
                  );
                } catch (_) {}
              }

              _buildMarkers();
            } else if (state is RestaurantsError) {
              setState(() {
                _error = state.message;
                _isLoading = false;
              });
            } else if (state is RestaurantsLoading) {
              if (_restaurants.isEmpty) {
                setState(() => _isLoading = true);
              }
            }
          },
          builder: (context, state) {
            final activeFilters = state is RestaurantsLoaded
                ? state.activeFilters
                : <String>{};

            return Stack(
              children: [
                _buildMap(),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopOverlay(activeFilters),
                ),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  kPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.loadingRestaurants,
                              style: kBodyStyle.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_selectedRestaurant != null) _buildBottomCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMap() {
    return YandexMap(
      onMapCreated: (controller) async {
        _mapController = controller;
        if (_userPosition != null) {
          await controller.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: Point(
                  latitude: _userPosition!.latitude,
                  longitude: _userPosition!.longitude,
                ),
                zoom: _defaultZoom,
              ),
            ),
          );
        }
      },
      onCameraPositionChanged: (cameraPosition, reason, finished) {
        if (_currentZoom != cameraPosition.zoom) {
          setState(() {
            _currentZoom = cameraPosition.zoom;
          });
          // Update markers instantly via scale property if Move has finished
          // Actually, just calling _buildMarkers is needed when restaurants change
          // or selection changes. For zoom, the engine handles 'scale: zoomScale'
          // BUT we need to rebuild the mapObjects list with the new scale.
          _buildMarkers();
        }
      },
      mapObjects: _mapObjects,
    );
  }

  Widget _buildTopOverlay(Set<String> activeFilters) {
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
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildFilterChips(activeFilters),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
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
          hintText: l10n.searchNearby,
          hintStyle: kBodyStyle.copyWith(fontSize: 15, color: kTextSecondary),
          prefixIcon: const Icon(Icons.search, color: kTextSecondary),
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

  Widget _buildFilterChips(Set<String> activeFilters) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = activeFilters.contains(filter);

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
                      ? Image.network(restaurant.logo!, fit: BoxFit.cover)
                      : const Icon(Icons.restaurant, color: kTextSecondary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      restaurant.name,
                      style: kSubtitleStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.locationText ?? '',
                            style: kBodyStyle.copyWith(
                              color: kTextSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (restaurant.cashbackText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kSecondaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              restaurant.cashbackText!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kTextSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
