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
