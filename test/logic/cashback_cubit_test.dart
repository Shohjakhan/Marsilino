import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant/src/data/models/wallet_model.dart';
import 'package:restaurant/src/data/repositories/wallet_repository.dart';
import 'package:restaurant/src/domain/cashback/cashback_cubit.dart';
import 'package:restaurant/src/domain/cashback/cashback_state.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late CashbackCubit cubit;
  late MockWalletRepository mockRepo;

  setUp(() {
    mockRepo = MockWalletRepository();
    cubit = CashbackCubit(walletRepository: mockRepo);
  });

  tearDown(() => cubit.close());

  group('CashbackCubit', () {
    group('loadBalance', () {
      final walletInfo = WalletInfo(
        userId: 'u1',
        balance: 50000,
        currency: 'UZS',
        totalEarned: 80000,
        totalTransferred: 30000,
      );

      blocTest<CashbackCubit, CashbackState>(
        'emits loading then loaded state on success',
        build: () {
          when(() => mockRepo.getWallet()).thenAnswer(
            (_) async =>
                WalletResult<WalletInfo>(success: true, data: walletInfo),
          );
          return cubit;
        },
        act: (c) => c.loadBalance(),
        expect: () => [
          // Loading state
          isA<CashbackState>().having((s) => s.isLoading, 'loading', true),
          // Loaded state
          isA<CashbackState>()
              .having((s) => s.balance, 'balance', 50000)
              .having((s) => s.currency, 'currency', 'UZS')
              .having((s) => s.totalEarned, 'earned', 80000)
              .having((s) => s.totalTransferred, 'transferred', 30000)
              .having((s) => s.isLoading, 'loading', false),
        ],
      );

      blocTest<CashbackCubit, CashbackState>(
        'emits error state on failure',
        build: () {
          when(() => mockRepo.getWallet()).thenAnswer(
            (_) async =>
                WalletResult<WalletInfo>(success: false, error: 'Server error'),
          );
          return cubit;
        },
        act: (c) => c.loadBalance(),
        expect: () => [
          isA<CashbackState>().having((s) => s.isLoading, 'loading', true),
          isA<CashbackState>()
              .having((s) => s.isLoading, 'loading', false)
              .having((s) => s.errorMessage, 'error', 'Server error'),
        ],
      );

      blocTest<CashbackCubit, CashbackState>(
        'emits error state on exception',
        build: () {
          when(() => mockRepo.getWallet()).thenThrow(Exception('timeout'));
          return cubit;
        },
        act: (c) => c.loadBalance(),
        expect: () => [
          isA<CashbackState>().having((s) => s.isLoading, 'loading', true),
          isA<CashbackState>()
              .having((s) => s.isLoading, 'loading', false)
              .having((s) => s.errorMessage, 'error', contains('timeout')),
        ],
      );
    });

    group('addCashback', () {
      blocTest<CashbackCubit, CashbackState>(
        'adds amount to balance and sets lastAddedAmount',
        seed: () => const CashbackState(balance: 10000),
        build: () => cubit,
        act: (c) => c.addCashback(5000),
        expect: () => [
          isA<CashbackState>()
              .having((s) => s.balance, 'balance', 15000)
              .having((s) => s.lastAddedAmount, 'lastAdded', 5000)
              .having((s) => s.errorMessage, 'no error', null),
        ],
      );
    });

    group('updateBalance', () {
      blocTest<CashbackCubit, CashbackState>(
        'sets balance to new value',
        seed: () => const CashbackState(balance: 10000),
        build: () => cubit,
        act: (c) => c.updateBalance(25000),
        expect: () => [
          isA<CashbackState>()
              .having((s) => s.balance, 'balance', 25000)
              .having((s) => s.errorMessage, 'no error', null),
        ],
      );
    });

    group('transferToCard', () {
      final transferResult = TransferResult(
        transactionId: 'tx1',
        transferredAmount: 10000,
        newBalance: 0,
        cardLastFour: '1234',
      );

      blocTest<CashbackCubit, CashbackState>(
        'emits loading then updated balance on success',
        seed: () => const CashbackState(balance: 10000),
        build: () {
          when(
            () => mockRepo.transferToCard(
              amount: any(named: 'amount'),
              cardLastFour: any(named: 'cardLastFour'),
            ),
          ).thenAnswer(
            (_) async => WalletResult<TransferResult>(
              success: true,
              data: transferResult,
            ),
          );
          return cubit;
        },
        act: (c) => c.transferToCard(cardLastFour: '1234'),
        expect: () => [
          isA<CashbackState>().having((s) => s.isLoading, 'loading', true),
          isA<CashbackState>()
              .having((s) => s.balance, 'balance', 0)
              .having((s) => s.isLoading, 'loading', false),
        ],
      );

      blocTest<CashbackCubit, CashbackState>(
        'emits error when balance is zero',
        seed: () => const CashbackState(balance: 0),
        build: () => cubit,
        act: (c) => c.transferToCard(cardLastFour: '1234'),
        expect: () => [
          isA<CashbackState>().having(
            (s) => s.errorMessage,
            'error',
            'No balance to transfer',
          ),
        ],
      );

      blocTest<CashbackCubit, CashbackState>(
        'emits error on API failure',
        seed: () => const CashbackState(balance: 10000),
        build: () {
          when(
            () => mockRepo.transferToCard(
              amount: any(named: 'amount'),
              cardLastFour: any(named: 'cardLastFour'),
            ),
          ).thenAnswer(
            (_) async => WalletResult<TransferResult>(
              success: false,
              error: 'Transfer failed',
            ),
          );
          return cubit;
        },
        act: (c) => c.transferToCard(cardLastFour: '1234'),
        expect: () => [
          isA<CashbackState>().having((s) => s.isLoading, 'loading', true),
          isA<CashbackState>()
              .having((s) => s.isLoading, 'loading', false)
              .having((s) => s.errorMessage, 'error', 'Transfer failed'),
        ],
      );
    });
  });
}
