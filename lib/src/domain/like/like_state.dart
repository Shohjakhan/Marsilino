/// Like state.
sealed class LikeState {}

/// Initial state - all likes loaded.
class LikeInitial extends LikeState {
  final Set<String> likedRestaurantIds;

  LikeInitial({this.likedRestaurantIds = const {}});
}

/// Currently toggling a like.
class LikeToggling extends LikeState {
  final String restaurantId;
  final Set<String> likedRestaurantIds;

  LikeToggling({required this.restaurantId, required this.likedRestaurantIds});
}

/// Like toggle completed.
class LikeToggled extends LikeState {
  final String restaurantId;
  final bool isLiked;
  final Set<String> likedRestaurantIds;

  LikeToggled({
    required this.restaurantId,
    required this.isLiked,
    required this.likedRestaurantIds,
  });
}

/// Like operation failed.
class LikeError extends LikeState {
  final String message;
  final String? restaurantId;
  final Set<String> likedRestaurantIds;

  LikeError({
    required this.message,
    this.restaurantId,
    required this.likedRestaurantIds,
  });
}
