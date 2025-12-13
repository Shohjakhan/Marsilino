import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/restaurants_repository.dart';

/// Like state.
sealed class LikeState {}

/// Initial state - all likes loaded.
class LikeInitial extends LikeState {
  final Set<int> likedRestaurantIds;

  LikeInitial({this.likedRestaurantIds = const {}});
}

/// Currently toggling a like.
class LikeToggling extends LikeState {
  final int restaurantId;
  final Set<int> likedRestaurantIds;

  LikeToggling({required this.restaurantId, required this.likedRestaurantIds});
}

/// Like toggle completed.
class LikeToggled extends LikeState {
  final int restaurantId;
  final bool isLiked;
  final Set<int> likedRestaurantIds;

  LikeToggled({
    required this.restaurantId,
    required this.isLiked,
    required this.likedRestaurantIds,
  });
}

/// Like operation failed.
class LikeError extends LikeState {
  final String message;
  final int? restaurantId;
  final Set<int> likedRestaurantIds;

  LikeError({
    required this.message,
    this.restaurantId,
    required this.likedRestaurantIds,
  });
}

/// Centralized cubit for managing like state across pages.
class LikeCubit extends Cubit<LikeState> {
  final RestaurantsRepository _repository;
  Set<int> _likedIds = {};

  LikeCubit({RestaurantsRepository? repository})
    : _repository = repository ?? RestaurantsRepository(),
      super(LikeInitial());

  /// Load initial liked restaurant IDs.
  Future<void> loadLikedIds() async {
    try {
      final result = await _repository.getLikedRestaurantIds();
      if (result.success) {
        _likedIds = Set.from(result.ids);
        emit(LikeInitial(likedRestaurantIds: _likedIds));
      }
    } catch (e) {
      print('[LikeCubit] loadLikedIds error: $e');
      // Keep existing state on error
    }
  }

  /// Check if a restaurant is liked.
  bool isLiked(int restaurantId) {
    return _likedIds.contains(restaurantId);
  }

  /// Get current set of liked IDs.
  Set<int> get likedIds => Set.unmodifiable(_likedIds);

  /// Add a like (optimistic with revert on error).
  Future<bool> addLike(int restaurantId) async {
    if (_likedIds.contains(restaurantId)) return true; // Already liked

    // Optimistic update
    _likedIds = Set.from(_likedIds)..add(restaurantId);
    emit(
      LikeToggling(restaurantId: restaurantId, likedRestaurantIds: _likedIds),
    );

    try {
      final result = await _repository.likeRestaurant(restaurantId);

      if (result.success) {
        emit(
          LikeToggled(
            restaurantId: restaurantId,
            isLiked: true,
            likedRestaurantIds: _likedIds,
          ),
        );
        return true;
      } else {
        // Revert on failure
        _likedIds = Set.from(_likedIds)..remove(restaurantId);
        emit(
          LikeError(
            message: result.error ?? 'Failed to like restaurant',
            restaurantId: restaurantId,
            likedRestaurantIds: _likedIds,
          ),
        );
        return false;
      }
    } catch (e) {
      print('[LikeCubit] addLike error: $e');
      // Revert on error
      _likedIds = Set.from(_likedIds)..remove(restaurantId);
      emit(
        LikeError(
          message: 'Failed to like: ${e.toString()}',
          restaurantId: restaurantId,
          likedRestaurantIds: _likedIds,
        ),
      );
      return false;
    }
  }

  /// Remove a like (optimistic with revert on error).
  Future<bool> removeLike(int restaurantId) async {
    if (!_likedIds.contains(restaurantId)) return true; // Already not liked

    // Optimistic update
    _likedIds = Set.from(_likedIds)..remove(restaurantId);
    emit(
      LikeToggling(restaurantId: restaurantId, likedRestaurantIds: _likedIds),
    );

    try {
      final result = await _repository.unlikeRestaurant(restaurantId);

      if (result.success) {
        emit(
          LikeToggled(
            restaurantId: restaurantId,
            isLiked: false,
            likedRestaurantIds: _likedIds,
          ),
        );
        return true;
      } else {
        // Revert on failure
        _likedIds = Set.from(_likedIds)..add(restaurantId);
        emit(
          LikeError(
            message: result.error ?? 'Failed to unlike restaurant',
            restaurantId: restaurantId,
            likedRestaurantIds: _likedIds,
          ),
        );
        return false;
      }
    } catch (e) {
      print('[LikeCubit] removeLike error: $e');
      // Revert on error
      _likedIds = Set.from(_likedIds)..add(restaurantId);
      emit(
        LikeError(
          message: 'Failed to unlike: ${e.toString()}',
          restaurantId: restaurantId,
          likedRestaurantIds: _likedIds,
        ),
      );
      return false;
    }
  }

  /// Toggle like state.
  Future<bool> toggleLike(int restaurantId) {
    return isLiked(restaurantId)
        ? removeLike(restaurantId)
        : addLike(restaurantId);
  }
}
