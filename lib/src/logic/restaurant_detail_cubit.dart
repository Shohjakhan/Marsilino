import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/restaurant.dart';
import '../data/repositories/restaurants_repository.dart';

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
  final int? restaurantId;

  DetailError({required this.message, this.restaurantId});
}

/// Cubit for managing restaurant detail and like state.
class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  final RestaurantsRepository _repository;
  static const _networkTimeout = Duration(seconds: 8);

  int? _currentRestaurantId;

  RestaurantDetailCubit({RestaurantsRepository? repository})
    : _repository = repository ?? RestaurantsRepository(),
      super(DetailInitial());

  /// Load restaurant detail by ID.
  Future<void> loadDetail(int restaurantId) async {
    _currentRestaurantId = restaurantId;
    emit(DetailLoading());

    try {
      // Load detail and like status in parallel
      final results = await Future.wait([
        _repository
            .getRestaurantDetail(restaurantId)
            .timeout(
              _networkTimeout,
              onTimeout: () {
                throw TimeoutException('Network request timed out');
              },
            ),
        _repository.getLikedRestaurantIds().timeout(
          _networkTimeout,
          onTimeout: () {
            // Non-critical, return empty result
            return const LikedIdsResult(success: true, ids: []);
          },
        ),
      ]);

      final detailResult = results[0] as RestaurantDetailResult;
      final likedResult = results[1] as LikedIdsResult;

      if (detailResult.success && detailResult.restaurant != null) {
        final isLiked =
            likedResult.success && likedResult.ids.contains(restaurantId);
        emit(
          DetailLoaded(restaurant: detailResult.restaurant!, isLiked: isLiked),
        );
      } else {
        emit(
          DetailError(
            message: detailResult.error ?? 'Failed to load restaurant details',
            restaurantId: restaurantId,
          ),
        );
      }
    } on TimeoutException {
      print(
        '[RestaurantDetailCubit] Network timeout for restaurant $restaurantId',
      );
      emit(
        DetailError(
          message: 'Network timeout. Please check your connection.',
          restaurantId: restaurantId,
        ),
      );
    } catch (e) {
      print('[RestaurantDetailCubit] loadDetail error: $e');
      emit(
        DetailError(
          message: 'Failed to load details: ${e.toString()}',
          restaurantId: restaurantId,
        ),
      );
    }
  }

  /// Toggle like with optimistic update.
  /// Returns true if API call succeeded, false if reverted.
  Future<bool> toggleLike(int restaurantId) async {
    final currentState = state;
    if (currentState is! DetailLoaded) return false;

    final wasLiked = currentState.isLiked;

    // Optimistic update - flip UI immediately
    emit(currentState.copyWith(isLiked: !wasLiked, isLikeToggling: true));

    try {
      // Call API
      final result = wasLiked
          ? await _repository.unlikeRestaurant(restaurantId)
          : await _repository.likeRestaurant(restaurantId);

      // Ensure we're still on the same restaurant
      if (_currentRestaurantId != restaurantId) return false;

      final latestState = state;
      if (latestState is! DetailLoaded) return false;

      if (result.success) {
        // Success - keep the optimistic state, just clear toggling flag
        emit(latestState.copyWith(isLikeToggling: false));
        return true;
      } else {
        // Failed - revert
        print('[RestaurantDetailCubit] Like toggle failed: ${result.error}');
        emit(latestState.copyWith(isLiked: wasLiked, isLikeToggling: false));
        return false;
      }
    } catch (e) {
      print('[RestaurantDetailCubit] toggleLike error: $e');
      // Revert on error
      final latestState = state;
      if (latestState is DetailLoaded && _currentRestaurantId == restaurantId) {
        emit(latestState.copyWith(isLiked: wasLiked, isLikeToggling: false));
      }
      return false;
    }
  }

  /// Retry loading the current restaurant.
  Future<void> retry() async {
    if (_currentRestaurantId != null) {
      await loadDetail(_currentRestaurantId!);
    }
  }
}
