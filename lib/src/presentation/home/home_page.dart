import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../data/models/restaurant.dart';
import '../../logic/restaurants_cubit.dart';
import '../../theme/app_theme.dart';
import '../common/restaurant_card.dart';
import '../restaurant_page/restaurant_page.dart';
import '../../services/location_service.dart';

/// Home page - Main discovery screen with search, filters, and restaurant list.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();

  // We keep local state for location name to initialize it,
  // or we can rely on Cubit if we push it there.
  // The user wanted "no ui changes".
  // Visuals depend on state.

  @override
  void initState() {
    super.initState();
    final cubit = context.read<RestaurantsCubit>();
    cubit.loadRestaurants();
    cubit.loadFilterTags();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final locationName = await _locationService.getCurrentLocationName();
    if (mounted) {
      context.read<RestaurantsCubit>().updateLocationName(locationName);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    // We don't restore text in controller from cubit automatically here
    // unless we want to persist search state across tabs.
    // For now, let's keep it simple.
  }

  void _onSearchChanged(String query) {
    context.read<RestaurantsCubit>().searchRestaurants(query);
  }

  void _toggleFilter(String filter) {
    context.read<RestaurantsCubit>().applyFilter(filter);
  }

  void _clearFilters() {
    context.read<RestaurantsCubit>().clearFilters();
  }

  void _showQuickFilter(
    BuildContext context,
    Set<String> activeFilters,
    List<String> options,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => QuickFilterSheet(
        options: options,
        selectedFilters: activeFilters,
        onToggle: (filter) {
          _toggleFilter(filter);
          // Navigator.pop(context); // User code had this commented/logic specific.
          // User code: "Navigator.pop(context);" was effectively doing single select behavior in one version
          // but the sheet logic I saw earlier had local state.
          // In the user's latest revert:
          // onToggle: (filter) { _toggleFilter(filter); Navigator.pop(context); }
          // So I must preserve that.
          Navigator.pop(context);
        },
        onClear: () {
          _clearFilters();
          Navigator.pop(context);
        },
        onApply: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToRestaurant(BuildContext context, Restaurant restaurant) {
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
            latitude: restaurant.latitude,
            longitude: restaurant.longitude,
          ),
        ),
      ),
    );
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
        child: BlocBuilder<RestaurantsCubit, RestaurantsState>(
          builder: (context, state) {
            final isLoading = state is RestaurantsLoading;
            final error = state is RestaurantsError ? state.message : null;

            List<Restaurant> filteredRestaurants = [];
            Set<String> activeFilters = {};
            List<String> options = [];
            String? locationName;

            if (state is RestaurantsLoaded) {
              // restaurants = state.restaurants; // Unused
              filteredRestaurants = state.filteredRestaurants;
              activeFilters = state.activeFilters;
              options = state.availableTags;
              locationName = state.currentLocationName;
            } else if (state is RestaurantsError) {
              filteredRestaurants = state.cachedRestaurants;
            } else if (state is RestaurantsLoading) {
              filteredRestaurants = state.cachedRestaurants;
            }

            // If strictly matching user's variable names for logic mapped to UI:
            // _filteredRestaurants => filteredRestaurants
            // _isLoading => isLoading (mostly)
            // _filterOptions => options
            // _selectedFilters => activeFilters
            // _currentLocation => locationName

            return RefreshIndicator(
              color: kPrimary,
              onRefresh: () => context.read<RestaurantsCubit>().loadRestaurants(
                forceRefresh: true,
              ),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(
                      context,
                      locationName ?? l10n.loading,
                      activeFilters,
                      options,
                      l10n,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildFilterChips(context, activeFilters, options),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSectionTitle(
                      filteredRestaurants.length,
                      isLoading &&
                          filteredRestaurants
                              .isEmpty, // Only show dots if no data
                      l10n,
                    ),
                  ),
                  if (isLoading && filteredRestaurants.isEmpty)
                    const SliverToBoxAdapter(child: _LoadingIndicator())
                  else if (error != null && filteredRestaurants.isEmpty)
                    SliverToBoxAdapter(child: _buildError(context, error, l10n))
                  else if (filteredRestaurants.isEmpty && !isLoading)
                    SliverToBoxAdapter(child: _buildEmpty(l10n))
                  else
                    _buildRestaurantList(context, filteredRestaurants),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String location,
    Set<String> activeFilters,
    List<String> options,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.discover,
                    style: kTitleStyle.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.findFood,
                    style: kBodyStyle.copyWith(color: kTextSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [kCardShadow],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 16, color: kPrimary),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: kBodyStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchInput(context, activeFilters, options, l10n),
        ],
      ),
    );
  }

  Widget _buildSearchInput(
    BuildContext context,
    Set<String> activeFilters,
    List<String> options,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [kCardShadow],
      ),
      child: TextField(
        controller: _searchController,
        style: kBodyStyle.copyWith(fontSize: 15),
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: l10n.searchPlaceholder,
          hintStyle: kBodyStyle.copyWith(fontSize: 15, color: kTextSecondary),
          prefixIcon: Icon(
            Icons.search,
            color: kTextSecondary.withValues(alpha: 0.7),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.tune, color: kPrimary),
            onPressed: () => _showQuickFilter(context, activeFilters, options),
          ),
          filled: true,
          fillColor: kCardBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    Set<String> activeFilters,
    List<String> options,
  ) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final filter = options[index];
          final isSelected = activeFilters.contains(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _toggleFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kSecondary : kCardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: kTextSecondary.withValues(alpha: 0.2),
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: kSecondary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 14,
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

  Widget _buildSectionTitle(int count, bool isLoading, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.nearbyRestaurants,
            style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            isLoading ? '...' : l10n.placesCount(count),
            style: kBodyStyle.copyWith(color: kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantList(
    BuildContext context,
    List<Restaurant> restaurants,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final restaurant = restaurants[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RestaurantCard(
              data: _toCardData(restaurant),
              onTap: () => _navigateToRestaurant(context, restaurant),
            ),
          );
        }, childCount: restaurants.length),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    String message,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.error_outline,
            size: 64,
            color: kTextSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: kBodyStyle.copyWith(color: kTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.read<RestaurantsCubit>().loadRestaurants(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.tryAgain),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: kTextSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(l10n.noRestaurantsFound, style: kSubtitleStyle),
          const SizedBox(height: 8),
          Text(
            l10n.adjustFilters,
            style: kBodyStyle.copyWith(color: kTextSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
        ),
      ),
    );
  }
}

class QuickFilterSheet extends StatefulWidget {
  final List<String> options;
  final Set<String> selectedFilters;
  final Function(String) onToggle;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const QuickFilterSheet({
    super.key,
    required this.options,
    required this.selectedFilters,
    required this.onToggle,
    required this.onClear,
    required this.onApply,
  });

  @override
  State<QuickFilterSheet> createState() => _QuickFilterSheetState();
}

class _QuickFilterSheetState extends State<QuickFilterSheet> {
  late Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = Set.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kTextSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.quickFilters, style: kTitleStyle),
          const SizedBox(height: 8),
          Text(
            l10n.selectCategories,
            style: kBodyStyle.copyWith(color: kTextSecondary),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.options.map((filter) {
              final isSelected = _localSelected.contains(filter);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _localSelected.remove(filter);
                    } else {
                      _localSelected.add(filter);
                    }
                  });
                  // Also trigger parent callback immediately? Or wait for Apply?
                  // If we wait for apply, we shouldn't call widget.onToggle.
                  // Let's assume immediate update for simple interaction from previous code.
                  widget.onToggle(filter);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary : kCardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: kTextSecondary.withValues(alpha: 0.2),
                          ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? Colors.white : kTextPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _localSelected.clear();
                    });
                    widget.onClear();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kTextSecondary,
                    side: BorderSide(
                      color: kTextSecondary.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kButtonRadius),
                    ),
                  ),
                  child: Text(l10n.clearAll),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kButtonRadius),
                    ),
                  ),
                  child: Text(l10n.apply),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
