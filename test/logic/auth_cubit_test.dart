import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant/src/data/repositories/auth_repository.dart';
import 'package:restaurant/src/data/repositories/token_storage.dart';
import 'package:restaurant/src/logic/auth_cubit.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockAuthRepository;
  late MockTokenStorage mockTokenStorage;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTokenStorage = MockTokenStorage();
    authCubit = AuthCubit(
      authRepository: mockAuthRepository,
      tokenStorage: mockTokenStorage,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    group('checkExistingToken', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when token exists',
        build: () {
          when(
            () => mockAuthRepository.isLoggedIn(),
          ).thenAnswer((_) async => true);
          when(
            () => mockTokenStorage.getUserName(),
          ).thenAnswer((_) async => 'John Doe');
          when(
            () => mockTokenStorage.getUserPhone(),
          ).thenAnswer((_) async => '+1234567890');
          return authCubit;
        },
        act: (cubit) => cubit.checkExistingToken(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>()
              .having((s) => s.fullName, 'fullName', 'John Doe')
              .having((s) => s.phone, 'phone', '+1234567890'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no token exists',
        build: () {
          when(
            () => mockAuthRepository.isLoggedIn(),
          ).thenAnswer((_) async => false);
          return authCubit;
        },
        act: (cubit) => cubit.checkExistingToken(),
        expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on timeout',
        build: () {
          when(() => mockAuthRepository.isLoggedIn()).thenAnswer(
            (_) => Future.delayed(const Duration(seconds: 10), () => true),
          );
          return authCubit;
        },
        act: (cubit) => cubit.checkExistingToken(),
        wait: const Duration(seconds: 6),
        expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on error',
        build: () {
          when(
            () => mockAuthRepository.isLoggedIn(),
          ).thenThrow(Exception('Network error'));
          return authCubit;
        },
        act: (cubit) => cubit.checkExistingToken(),
        expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      );
    });

    group('requestOtp', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthOtpRequested] on successful OTP request',
        build: () {
          when(
            () => mockAuthRepository.requestOtp(any()),
          ).thenAnswer((_) async {});
          return authCubit;
        },
        act: (cubit) => cubit.requestOtp('+1234567890'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthOtpRequested>().having(
            (s) => s.phoneNumber,
            'phoneNumber',
            '+1234567890',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthFailure] on OTP request failure',
        build: () {
          when(
            () => mockAuthRepository.requestOtp(any()),
          ).thenThrow(Exception('Rate limited'));
          return authCubit;
        },
        act: (cubit) => cubit.requestOtp('+1234567890'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (s) => s.message,
            'message',
            contains('Rate limited'),
          ),
        ],
      );
    });

    group('verifyOtp', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful verification',
        build: () {
          when(() => mockAuthRepository.verifyOtp(any(), any())).thenAnswer(
            (_) async => const OtpVerifyResult(
              success: true,
              accessToken: 'token',
              refreshToken: 'refresh',
              isNewUser: false,
            ),
          );
          when(
            () => mockTokenStorage.getUserName(),
          ).thenAnswer((_) async => 'John');
          return authCubit;
        },
        act: (cubit) => cubit.verifyOtp('+1234567890', '123456'),
        expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthNewUser] for new users',
        build: () {
          when(() => mockAuthRepository.verifyOtp(any(), any())).thenAnswer(
            (_) async => const OtpVerifyResult(
              success: true,
              accessToken: 'token',
              refreshToken: 'refresh',
              isNewUser: true,
            ),
          );
          return authCubit;
        },
        act: (cubit) => cubit.verifyOtp('+1234567890', '123456'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthNewUser>().having((s) => s.phone, 'phone', '+1234567890'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthFailure] on verification failure',
        build: () {
          when(
            () => mockAuthRepository.verifyOtp(any(), any()),
          ).thenThrow(Exception('Invalid code'));
          return authCubit;
        },
        act: (cubit) => cubit.verifyOtp('+1234567890', '000000'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (s) => s.message,
            'message',
            contains('Invalid code'),
          ),
        ],
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthUnauthenticated] after logout',
        build: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [isA<AuthUnauthenticated>()],
      );
    });
  });
}
