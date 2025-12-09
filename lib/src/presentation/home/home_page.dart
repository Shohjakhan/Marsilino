import 'package:flutter/material.dart';
import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurants_repository.dart';
import '../../theme/app_theme.dart';
import '../common/restaurant_card.dart';
import '../restaurant_page/restaurant_page.dart';

/// Home page - Main discovery screen with search, filters, and restaurant list.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final RestaurantsRepository _repository = RestaurantsRepository();

  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = true;
  String? _error;

  static const List<String> _filterOptions = [
    'Family',
    'Bars',
    'Korean',
    'Halal',
    'Italian',
    'Fast Food',
    'Vegetarian',
    'Seafood',
    'Desserts',
    'Coffee',
  ];

  Set<String> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getRestaurants();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.success) {
          _restaurants = result.restaurants;
          _applyFilters();
        } else {
          _error = result.error;
        }
      });
    }
  }

  void _onSearchChanged(String query) {
    _applyFilters();
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
      _applyFilters();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedFilters.clear();
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredRestaurants = _restaurants.where((r) {
        final matchesQuery =
            r.name.toLowerCase().contains(query) ||
            (r.tagsList.any((t) => t.toLowerCase().contains(query)));

        final matchesFilters =
            _selectedFilters.isEmpty ||
            _selectedFilters.every((f) => r.tagsList.contains(f));

        return matchesQuery && matchesFilters;
      }).toList();
    });
  }

  void _showQuickFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => QuickFilterSheet(
        options: _filterOptions,
        selectedFilters: _selectedFilters,
        onToggle: (filter) {
          _toggleFilter(filter);
          Navigator.pop(context); // Close after selection or keep open?
          // Typically sheet stays open for multiple selects or closes on apply
          // We'll update state, but sheet needs to rebuild to show selection.
          // Since sheet is a separate widget, we need to pass state down or StatefulBuilder
          // For simplicity in this revert, let's keep it simple and just close or reuse logic
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
            discount: restaurant.discountText,
            instagram: restaurant.instagram,
            telegram: restaurant.telegram,
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
      discount: r.discountText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickFilter(context),
        backgroundColor: kPrimary,
        child: const Icon(Icons.filter_list, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kPrimary,
          onRefresh: _loadRestaurants,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildFilterChips(context)),
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  _filteredRestaurants.length,
                  _isLoading,
                ),
              ),
              if (_isLoading)
                const SliverToBoxAdapter(child: _LoadingIndicator())
              else if (_error != null)
                SliverToBoxAdapter(child: _buildError(context, _error!))
              else if (_filteredRestaurants.isEmpty)
                SliverToBoxAdapter(child: _buildEmpty())
              else
                _buildRestaurantList(context, _filteredRestaurants),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  Text('Discover', style: kTitleStyle.copyWith(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(
                    'Find your favorite restaurants',
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
                      'Tashkent',
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
          _buildSearchInput(context),
        ],
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context) {
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
          hintText: 'Search restaurants, cuisine, location',
          hintStyle: kBodyStyle.copyWith(fontSize: 15, color: kTextSecondary),
          prefixIcon: Icon(
            Icons.search,
            color: kTextSecondary.withValues(alpha: 0.7),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.tune, color: kPrimary),
            onPressed: () => _showQuickFilter(context),
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

  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilters.contains(filter);

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
                  color: isSelected ? kPrimary : kCardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: kTextSecondary.withValues(alpha: 0.2),
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.3),
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

  Widget _buildSectionTitle(int count, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nearby Restaurants',
            style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            isLoading ? '...' : '$count places',
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

  Widget _buildError(BuildContext context, String message) {
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
            onPressed: () => _loadRestaurants(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
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
          Text('No restaurants found', style: kSubtitleStyle),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
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
  // We need local state if we want to defer updates, but for now we rely on parent rebuilding
  // Actually, if parent rebuilds, this widget might not rebuild if we don't handle it
  // But since we are passing callbacks, it's easier if we just call them directly.
  // However, for the sheet to update visually while open, it needs to be stateful
  // OR the parent needs to rebuild and pass new selectedFilters.
  // Since showModalBottomSheet pushes a new route, parent rebuild doesn't update sheet contents automatically unless using StatefulBuilder or similar.
  // Let's implement local state for the sheet and sync on apply.

  late Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = Set.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Quick Filters', style: kTitleStyle),
          const SizedBox(height: 8),
          Text(
            'Select categories to filter restaurants',
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
                  child: const Text('Clear All'),
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
                  child: const Text('Apply'),
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
