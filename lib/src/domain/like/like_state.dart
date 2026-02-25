import 'package:equatable/equatable.dart';

/// Like state.
sealed class LikeState extends Equatable {
  const LikeState();

  @override
  List<Object?> get props => [];
}

/// Initial state - all likes loaded.
class LikeInitial extends LikeState {
  final Set<String> likedRestaurantIds;

  const LikeInitial({this.likedRestaurantIds = const {}});

  @override
  List<Object?> get props => [likedRestaurantIds];
}

/// Currently toggling a like.
class LikeToggling extends LikeState {
  final String restaurantId;
  final Set<String> likedRestaurantIds;

  const LikeToggling({
    required this.restaurantId,
    required this.likedRestaurantIds,
  });

  @override
  List<Object?> get props => [restaurantId, likedRestaurantIds];
}

/// Like toggle completed.
class LikeToggled extends LikeState {
  final String restaurantId;
  final bool isLiked;
  final Set<String> likedRestaurantIds;

  const LikeToggled({
    required this.restaurantId,
    required this.isLiked,
    required this.likedRestaurantIds,
  });

  @override
  List<Object?> get props => [restaurantId, isLiked, likedRestaurantIds];
}

/// Like operation failed.
class LikeError extends LikeState {
  final String message;
  final String? restaurantId;
  final Set<String> likedRestaurantIds;

  const LikeError({
    required this.message,
    this.restaurantId,
    required this.likedRestaurantIds,
  });

  @override
  List<Object?> get props => [message, restaurantId, likedRestaurantIds];
}
