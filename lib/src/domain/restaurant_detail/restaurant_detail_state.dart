import '../../data/models/restaurant.dart';

/// Restaurant detail state.
sealed class RestaurantDetailState {}

/// Initial state - no detail loaded.
class DetailInitial extends RestaurantDetailState {}

/// Loading detail.
class DetailLoading extends RestaurantDetailState {}

/// Detail loaded successfully.
class DetailLoaded extends RestaurantDetailState {
  final Restaurant restaurant;
  final bool isLiked;
  final bool isLikeToggling;

  DetailLoaded({
    required this.restaurant,
    this.isLiked = false,
    this.isLikeToggling = false,
  });

  DetailLoaded copyWith({
    Restaurant? restaurant,
    bool? isLiked,
    bool? isLikeToggling,
  }) {
    return DetailLoaded(
      restaurant: restaurant ?? this.restaurant,
      isLiked: isLiked ?? this.isLiked,
      isLikeToggling: isLikeToggling ?? this.isLikeToggling,
    );
  }
}

/// Error loading detail.
class DetailError extends RestaurantDetailState {
  final String message;
  final String? restaurantId;

  DetailError({required this.message, this.restaurantId});
}
