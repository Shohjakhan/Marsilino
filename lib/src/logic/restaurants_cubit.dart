import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/restaurant.dart';
import '../data/repositories/restaurants_repository.dart';

/// Restaurants state.
sealed class RestaurantsState {}

/// Initial state - no data loaded yet.
class RestaurantsInitial extends RestaurantsState {}

/// Loading state.
class RestaurantsLoading extends RestaurantsState {
  /// If true, showing cached data while refreshing.
  final List<Restaurant> cachedRestaurants;
  final bool isRefreshing;

  RestaurantsLoading({
    this.cachedRestaurants = const [],
    this.isRefreshing = false,
  });
}

/// Restaurants loaded successfully.
class RestaurantsLoaded extends RestaurantsState {
  final List<Restaurant> restaurants;
  final List<Restaurant> filteredRestaurants;
  final String searchQuery;
  final Set<String> activeFilters;
  final bool hasMore;
  final List<String> availableTags;
  final String? currentLocationName;

  RestaurantsLoaded({
    required this.restaurants,
    required this.filteredRestaurants,
    this.searchQuery = '',
    this.activeFilters = const {},
    this.hasMore = false,
    List<String>? availableTags,
    this.currentLocationName,
  }) : availableTags = availableTags ?? const [];

  RestaurantsLoaded copyWith({
    List<Restaurant>? restaurants,
    List<Restaurant>? filteredRestaurants,
    String? searchQuery,
    Set<String>? activeFilters,
    bool? hasMore,
    List<String>? availableTags,
    String? currentLocationName,
  }) {
    return RestaurantsLoaded(
      restaurants: restaurants ?? this.restaurants,
      filteredRestaurants: filteredRestaurants ?? this.filteredRestaurants,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      hasMore: hasMore ?? this.hasMore,
      availableTags: availableTags ?? this.availableTags,
      currentLocationName: currentLocationName ?? this.currentLocationName,
    );
  }
}

/// Error state with retry capability.
class RestaurantsError extends RestaurantsState {
  final String message;
  final List<Restaurant> cachedRestaurants;

  RestaurantsError({required this.message, this.cachedRestaurants = const []});
}

/// Cubit for managing restaurants list.
class RestaurantsCubit extends Cubit<RestaurantsState> {
  final RestaurantsRepository _repository;
  static const _networkTimeout = Duration(seconds: 8);

  // In-memory cache
  List<Restaurant> _cachedRestaurants = [];
  String _currentSearchQuery = '';
  Set<String> _currentFilters = {};

  RestaurantsCubit({RestaurantsRepository? repository})
    : _repository = repository ?? RestaurantsRepository(),
      super(RestaurantsInitial());

  /// Load restaurants with optional force refresh.
  Future<void> loadRestaurants({bool forceRefresh = false}) async {
    // Show cached data while loading if available
    if (_cachedRestaurants.isNotEmpty && !forceRefresh) {
      emit(
        RestaurantsLoading(
          cachedRestaurants: _cachedRestaurants,
          isRefreshing: true,
        ),
      );
    } else {
      emit(RestaurantsLoading());
    }

    try {
      final result = await _repository.getRestaurants().timeout(
        _networkTimeout,
        onTimeout: () {
          debugPrint(
            '[RestaurantsCubit] Network timeout after $_networkTimeout',
          );
          throw TimeoutException('Network request timed out');
        },
      );

      if (result.success) {
        _cachedRestaurants = result.restaurants;
        _applyFiltersAndEmit();
      } else {
        emit(
          RestaurantsError(
            message: result.error ?? 'Failed to load restaurants',
            cachedRestaurants: _cachedRestaurants,
          ),
        );
      }
    } on TimeoutException {
      emit(
        RestaurantsError(
          message:
              'Connection timed out. Please check your internet connection.',
          cachedRestaurants: _cachedRestaurants,
        ),
      );
    } catch (e) {
      debugPrint('[RestaurantsCubit] loadRestaurants error: $e');
      emit(
        RestaurantsError(
          message: 'Failed to load restaurants: ${e.toString()}',
          cachedRestaurants: _cachedRestaurants,
        ),
      );
    }
  }

  /// Search restaurants by query.
  void searchRestaurants(String query) {
    _currentSearchQuery = query.toLowerCase().trim();
    _applyFiltersAndEmit();
  }

  /// Toggle a filter tag.
  void applyFilter(String tag) {
    if (_currentFilters.contains(tag)) {
      _currentFilters = Set.from(_currentFilters)..remove(tag);
    } else {
      _currentFilters = Set.from(_currentFilters)..add(tag);
    }
    _applyFiltersAndEmit();
  }

  /// Clear all filters.
  void clearFilters() {
    _currentFilters = {};
    _currentSearchQuery = '';
    _applyFiltersAndEmit();
  }

  /// Load more restaurants (pagination).
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! RestaurantsLoaded || !currentState.hasMore) return;

    // TODO: Implement pagination when API supports it
    // For now, this is a placeholder
    debugPrint(
      '[RestaurantsCubit] loadMore called - pagination not yet implemented',
    );
  }

  /// Apply current search and filters and emit loaded state.
  void _applyFiltersAndEmit() {
    if (_cachedRestaurants.isEmpty) {
      emit(
        RestaurantsLoaded(
          restaurants: [],
          filteredRestaurants: [],
          searchQuery: _currentSearchQuery,
          activeFilters: _currentFilters,
          availableTags: availableTags,
          currentLocationName: _currentLocationName,
        ),
      );
      return;
    }

    List<Restaurant> filtered = _cachedRestaurants;

    // Apply search
    if (_currentSearchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final name = r.name.toLowerCase();
        final tags = r.tagsList.join(' ').toLowerCase();
        final location = (r.locationText ?? '').toLowerCase();
        return name.contains(_currentSearchQuery) ||
            tags.contains(_currentSearchQuery) ||
            location.contains(_currentSearchQuery);
      }).toList();
    }

    // Apply tag filters
    if (_currentFilters.isNotEmpty) {
      filtered = filtered.where((r) {
        final restaurantTags = r.tagsList.map((t) => t.toLowerCase()).toSet();
        return _currentFilters.any(
          (filter) => restaurantTags.contains(filter.toLowerCase()),
        );
      }).toList();
    }

    emit(
      RestaurantsLoaded(
        restaurants: _cachedRestaurants,
        filteredRestaurants: filtered,
        searchQuery: _currentSearchQuery,
        activeFilters: _currentFilters,
        hasMore: false, // Update when pagination is implemented
        availableTags: availableTags,
        currentLocationName: _currentLocationName,
      ),
    );
  }

  /// Get all unique tags.
  List<String> get availableTags {
    // If we loaded them from repo, return those.
    // Otherwise derive from restaurants.
    if (_cachedTags.isNotEmpty) return _cachedTags;

    final tags = <String>{};
    for (final restaurant in _cachedRestaurants) {
      tags.addAll(restaurant.tagsList);
    }
    return tags.toList()..sort();
  }

  List<String> _cachedTags = [];
  String? _currentLocationName;

  Future<void> loadFilterTags() async {
    try {
      _cachedTags = await _repository.getFilterTags();
      _applyFiltersAndEmit();
    } catch (_) {
      // Ignore error for tags, just proceed
    }
  }

  Future<void> updateLocationName(String name) async {
    _currentLocationName = name;
    _applyFiltersAndEmit();
  }

  /// Load nearby restaurants.
  Future<void> loadNearbyRestaurants(double lat, double lng) async {
    // If we have cached data, show it while loading
    if (_cachedRestaurants.isNotEmpty) {
      // Optional: emit loading with data
    }

    emit(RestaurantsLoading(cachedRestaurants: _cachedRestaurants));

    try {
      final result = await _repository.getNearbyRestaurants(
        latitude: lat,
        longitude: lng,
      );

      if (result.success) {
        _cachedRestaurants = result.restaurants;
        _applyFiltersAndEmit();
      } else {
        emit(
          RestaurantsError(
            message: result.error ?? 'Failed to load nearby restaurants',
            cachedRestaurants: _cachedRestaurants,
          ),
        );
      }
    } catch (e) {
      emit(
        RestaurantsError(
          message: 'Failed to load restaurants: ${e.toString()}',
          cachedRestaurants: _cachedRestaurants,
        ),
      );
    }
  }
}
