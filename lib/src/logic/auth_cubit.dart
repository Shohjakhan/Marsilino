import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/token_storage.dart';

/// Authentication state.
sealed class AuthState {}

/// Initial state - no action taken yet.
class AuthInitial extends AuthState {}

/// Loading state - operation in progress.
class AuthLoading extends AuthState {}

/// OTP has been requested successfully.
class AuthOtpRequested extends AuthState {
  final String phoneNumber;
  AuthOtpRequested({required this.phoneNumber});
}

/// User is authenticated (existing user).
class AuthAuthenticated extends AuthState {
  final String? fullName;
  final String? phone;
  AuthAuthenticated({this.fullName, this.phone});
}

/// User is a new user - needs to complete profile.
class AuthNewUser extends AuthState {
  final String? phone;
  AuthNewUser({this.phone});
}

/// User is not authenticated.
class AuthUnauthenticated extends AuthState {}

/// Authentication failure with error message.
class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}

/// Cubit for managing authentication state.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  static const _tokenCheckTimeout = Duration(seconds: 5);

  AuthCubit({AuthRepository? authRepository, TokenStorage? tokenStorage})
    : _authRepository = authRepository ?? AuthRepository(),
      _tokenStorage = tokenStorage ?? TokenStorage.instance,
      super(AuthInitial());

  /// Request OTP for phone number.
  Future<void> requestOtp(String phoneNumber) async {
    emit(AuthLoading());

    try {
      await _authRepository.requestOtp(phoneNumber);
      emit(AuthOtpRequested(phoneNumber: phoneNumber));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      print('[AuthCubit] requestOtp error: $message');
      emit(AuthFailure(message: message));
    }
  }

  /// Verify OTP and handle authentication.
  Future<void> verifyOtp(String phoneNumber, String code) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.verifyOtp(phoneNumber, code);

      if (result.success) {
        if (result.isNewUser) {
          emit(AuthNewUser(phone: phoneNumber));
        } else {
          final fullName = await _tokenStorage.getUserName();
          emit(AuthAuthenticated(fullName: fullName, phone: phoneNumber));
        }
      } else {
        emit(AuthFailure(message: result.error ?? 'OTP verification failed'));
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      print('[AuthCubit] verifyOtp error: $message');
      emit(AuthFailure(message: message));
    }
  }

  /// Check for existing valid token with timeout protection.
  /// Returns AuthUnauthenticated on timeout or error to prevent blocking.
  Future<void> checkExistingToken() async {
    emit(AuthLoading());

    try {
      // Use timeout to prevent infinite loading
      final isLoggedIn = await _authRepository.isLoggedIn().timeout(
        _tokenCheckTimeout,
        onTimeout: () {
          print('[AuthCubit] Token check timed out after $_tokenCheckTimeout');
          return false;
        },
      );

      if (isLoggedIn) {
        final fullName = await _tokenStorage.getUserName();
        final phone = await _tokenStorage.getUserPhone();
        emit(AuthAuthenticated(fullName: fullName, phone: phone));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('[AuthCubit] checkExistingToken error: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// Complete profile for new user.
  Future<void> completeProfile(String fullName) async {
    emit(AuthLoading());

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
      print('[AuthCubit] completeProfile error: $message');
      emit(AuthFailure(message: message));
    }
  }

  /// Clear authentication and logout.
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      print('[AuthCubit] logout error: $e');
    }
    emit(AuthUnauthenticated());
  }

  /// Reset to initial state (e.g., for retry from failure).
  void reset() {
    emit(AuthInitial());
  }

  /// Set authenticated state directly (e.g., after successful profile update).
  void setAuthenticated({String? fullName, String? phone}) {
    emit(AuthAuthenticated(fullName: fullName, phone: phone));
  }
}
