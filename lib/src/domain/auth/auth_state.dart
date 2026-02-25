import 'package:equatable/equatable.dart';

/// Authentication state.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no action taken yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - operation in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// OTP has been requested successfully.
class AuthOtpRequested extends AuthState {
  final String phoneNumber;

  const AuthOtpRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// User is authenticated (existing user).
class AuthAuthenticated extends AuthState {
  final String? fullName;
  final String? phone;

  const AuthAuthenticated({this.fullName, this.phone});

  @override
  List<Object?> get props => [fullName, phone];
}

/// User is a new user - needs to complete profile.
class AuthNewUser extends AuthState {
  final String? phone;

  const AuthNewUser({this.phone});

  @override
  List<Object?> get props => [phone];
}

/// User is not authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication failure with error message.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
