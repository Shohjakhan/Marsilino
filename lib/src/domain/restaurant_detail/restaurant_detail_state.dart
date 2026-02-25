import 'package:equatable/equatable.dart';
import '../../data/models/restaurant.dart';

/// Restaurant detail state.
sealed class RestaurantDetailState extends Equatable {
  const RestaurantDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no detail loaded.
class DetailInitial extends RestaurantDetailState {
  const DetailInitial();
}

/// Loading detail.
class DetailLoading extends RestaurantDetailState {
  const DetailLoading();
}

/// Detail loaded successfully.
class DetailLoaded extends RestaurantDetailState {
  final Restaurant restaurant;
  final bool isLiked;
  final bool isLikeToggling;

  const DetailLoaded({
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

  @override
  List<Object?> get props => [restaurant, isLiked, isLikeToggling];
}

/// Error loading detail.
class DetailError extends RestaurantDetailState {
  final String message;
  final String? restaurantId;

  const DetailError({required this.message, this.restaurantId});

  @override
  List<Object?> get props => [message, restaurantId];
}
