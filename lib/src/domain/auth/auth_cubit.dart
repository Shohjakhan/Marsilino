import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/token_storage.dart';
import 'auth_state.dart';

export 'auth_state.dart';

/// Cubit for managing authentication state.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  static const _tokenCheckTimeout = Duration(seconds: 5);

  AuthCubit({AuthRepository? authRepository, TokenStorage? tokenStorage})
    : _authRepository = authRepository ?? AuthRepository(),
      _tokenStorage = tokenStorage ?? TokenStorage.instance,
      super(const AuthInitial());

  /// Request OTP for phone number.
  Future<void> requestOtp(String phoneNumber) async {
    emit(const AuthLoading());

    try {
      await _authRepository.requestOtp(phoneNumber);
      emit(AuthOtpRequested(phoneNumber: phoneNumber));
    } catch (e) {
      var message = e.toString().replaceFirst('Exception: ', '').trim();
      if (message.isEmpty) message = 'Failed to request OTP. Please try again.';
      emit(AuthFailure(message: message));
    }
  }

  /// Verify OTP and handle authentication.
  Future<void> verifyOtp(
    String phoneNumber,
    String code, {
    String? fullName,
  }) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.verifyOtp(
        phoneNumber,
        code,
        fullName: fullName,
      );

      if (result.success) {
        if (result.isNewUser && result.fullName == null) {
          // New user with no name provided — go to profile completion page
          emit(AuthNewUser(phone: phoneNumber));
        } else {
          // Existing user or new user who supplied a name during sign-up
          final name = result.fullName ?? await _tokenStorage.getUserName();
          emit(AuthAuthenticated(fullName: name, phone: phoneNumber));
        }
      } else {
        emit(AuthFailure(message: result.error ?? 'OTP verification failed'));
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(AuthFailure(message: message));
    }
  }

  /// Check for existing valid token with timeout protection.
  /// Returns AuthUnauthenticated on timeout or error to prevent blocking.
  Future<void> checkExistingToken() async {
    emit(const AuthLoading());

    try {
      // Use timeout to prevent infinite loading
      final isLoggedIn = await _authRepository.isLoggedIn().timeout(
        _tokenCheckTimeout,
        onTimeout: () {
          return false;
        },
      );

      if (isLoggedIn) {
        final fullName = await _tokenStorage.getUserName();
        final phone = await _tokenStorage.getUserPhone();
        emit(AuthAuthenticated(fullName: fullName, phone: phone));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Complete profile for new user.
  Future<void> completeProfile(String fullName) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.updateProfile(fullName: fullName);
      if (result.success) {
        final phone = await _tokenStorage.getUserPhone();
        emit(AuthAuthenticated(fullName: fullName, phone: phone));
      } else {
        emit(AuthFailure(message: result.error ?? 'Failed to update profile'));
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(AuthFailure(message: message));
    }
  }

  /// Clear authentication and logout.
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {}
    emit(const AuthUnauthenticated());
  }

  /// Reset to initial state (e.g., for retry from failure).
  void reset() {
    emit(const AuthInitial());
  }

  /// Set authenticated state directly (e.g., after successful profile update).
  void setAuthenticated({String? fullName, String? phone}) {
    emit(AuthAuthenticated(fullName: fullName, phone: phone));
  }
}
