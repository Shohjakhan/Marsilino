import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/restaurants_repository.dart';
import 'like_state.dart';

export 'like_state.dart';

/// Centralized cubit for managing like state across pages.
class LikeCubit extends Cubit<LikeState> {
  final RestaurantsRepository _repository;
  Set<String> _likedIds = {};

  LikeCubit({RestaurantsRepository? repository})
    : _repository = repository ?? RestaurantsRepository(),
      super(const LikeInitial());

  /// Load initial liked restaurant IDs.
  Future<void> loadLikedIds() async {
    try {
      final result = await _repository.getLikedRestaurantIds();
      if (result.success) {
        _likedIds = Set.from(result.ids);
        emit(LikeInitial(likedRestaurantIds: _likedIds));
      }
    } catch (_) {
      // Keep existing state on error
    }
  }

  /// Check if a restaurant is liked.
  bool isLiked(String restaurantId) {
    return _likedIds.contains(restaurantId);
  }

  /// Get current set of liked IDs.
  Set<String> get likedIds => Set.unmodifiable(_likedIds);

  /// Add a like (optimistic with revert on error).
  Future<bool> addLike(String restaurantId) async {
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
  Future<bool> removeLike(String restaurantId) async {
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
  Future<bool> toggleLike(String restaurantId) {
    return isLiked(restaurantId)
        ? removeLike(restaurantId)
        : addLike(restaurantId);
  }
}
