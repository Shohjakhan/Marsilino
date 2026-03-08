import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../domain/auth/auth_cubit.dart';
import '../../domain/cashback/cashback_cubit.dart';
import '../../data/api_client.dart';
import '../../data/repositories/bookings_repository.dart';
import '../../data/repositories/restaurants_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../data/models/booking_response_model.dart';
import '../../theme/app_theme.dart';
import '../common/rounded_card.dart';
import '../../data/repositories/token_storage.dart';
import '../onboarding/onboarding_page.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';
import 'profile_edit_dialog.dart';
import 'widgets/wallet_card.dart';
import 'widgets/language_selector.dart';
import 'widgets/transaction_history.dart';

/// Available languages for the app.
enum AppLanguage { english, russian, uzbek }

/// Profile page showing user info, language selector, and transaction history.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _transactionsRepository = TransactionsRepository();
  final _bookingsRepository = BookingsRepository();
  final _restaurantsRepository = RestaurantsRepository();
  final _userRepository = UserRepository();
  final _cashbackCubit = CashbackCubit();
  late Future<UserModel> _userFuture;
  String _userName = '';
  String? _fcmToken;

  List<Transaction> _transactions = [];
  bool _isLoadingTransactions = true;

  List<BookingResponse> _bookings = [];
  bool _isLoadingBookings = true;
  final Map<String, String> _restaurantNames = {}; // Cache for restaurant names

  @override
  void initState() {
    super.initState();
    _userFuture = _userRepository.getMe().then((user) {
      if (mounted) {
        setState(() {
          _userName = (user.fullName?.split(' ').first) ?? '';
        });
      }
      return user;
    });
    _loadTransactions();
    if (AppConfig.enableBookings) _loadBookings();
    _loadFcmToken();
    _cashbackCubit.loadBalance();
  }

  @override
  void dispose() {
    _cashbackCubit.close();
    super.dispose();
  }

  Future<void> _loadFcmToken() async {
    final token = await TokenStorage.instance.getFcmToken();
    if (mounted) {
      setState(() {
        _fcmToken = token;
      });
    }
  }

  Future<void> _loadTransactions() async {
    final result = await _transactionsRepository.getTransactions();
    if (!mounted) return;

    setState(() {
      _isLoadingTransactions = false;
      if (result.success) {
        _transactions = result.transactions;
        // Sort by date desc (newest first)
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      }
    });
  }

  Future<void> _loadBookings() async {
    final result = await _bookingsRepository.getUserBookings();
    if (!mounted) return;

    setState(() {
      _isLoadingBookings = false;
      if (result.success) {
        _bookings = result.bookings;
        // Sort by date (future first)
        // Need to parse date string
        _bookings.sort((a, b) => b.date.compareTo(a.date));

        // Fetch restaurant names for bookings
        _fetchRestaurantNames();
      }
    });
  }

  Future<void> _fetchRestaurantNames() async {
    for (final booking in _bookings) {
      if (!_restaurantNames.containsKey(booking.restaurant)) {
        // Assume booking.restaurant is the ID
        try {
          // We can't easily get just the name without fetching details
          final result = await _restaurantsRepository.getRestaurantDetail(
            booking.restaurant,
          );
          if (result.restaurant != null) {
            if (mounted) {
              setState(() {
                _restaurantNames[booking.restaurant] = result.restaurant!.name;
              });
            }
          }
        } catch (e) {
          // Ignore errors
        }
      }
    }
  }

  void _handleLogout() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
        title: Text(l10n.logOut, style: kTitleStyle),
        content: Text(
          l10n.logoutConfirm,
          style: kBodyStyle.copyWith(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: kBodyStyle.copyWith(color: kTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Clear auth state
              await context.read<AuthCubit>().logout();
              ApiClient.instance.clearAuthToken();
              await TokenStorage.instance.clear();

              if (!mounted) return;

              // Navigate to onboarding and clear the navigation stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingPage()),
                (route) => false,
              );
            },
            child: Text(
              l10n.logOut,
              style: kBodyStyle.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: l10n is accessed inside build methods or widgets that depend on it
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile header
              _buildProfileHeader(),
              const SizedBox(height: 24),
              // Cashback wallet
              WalletCard(
                cashbackCubit: _cashbackCubit,
                userName: _userName,
                userRepository: _userRepository,
                userFuture: _userFuture,
              ),
              const SizedBox(height: 32),
              // Language selector
              const LanguageSelector(),
              const SizedBox(height: 24),
              // Stats summary
              StatsSummary(
                transactions: _transactions,
                isLoading: _isLoadingTransactions,
              ),
              const SizedBox(height: 24),
              // Bookings list (only when feature is enabled)
              if (AppConfig.enableBookings) ...[
                _buildBookingsList(),
                const SizedBox(height: 24),
              ],
              // Transaction history
              TransactionHistory(
                transactions: _transactions,
                isLoading: _isLoadingTransactions,
              ),
              const SizedBox(height: 32),
              // Logout button
              _buildLogoutButton(),
              const SizedBox(height: 24),
              // Debug FCM Token
              if (_fcmToken != null) _buildFcmTokenDebug(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFcmTokenDebug() {
    final l10n = AppLocalizations.of(context)!;
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FCM Token (Debug)',
                style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  if (_fcmToken != null) {
                    Clipboard.setData(ClipboardData(text: _fcmToken!));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.tokenCopied)));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            _fcmToken!,
            style: kBodyStyle.copyWith(
              fontSize: 10,
              color: kTextSecondary,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<UserModel>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                l10n.failedLoadProfile,
                style: kBodyStyle.copyWith(color: Colors.red),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _userFuture = _userRepository.getMe();
                  });
                },
                child: Text(l10n.retryButton),
              ),
            ],
          );
        }

        final user = snapshot.data!;
        final displayPhone = user.phoneNumber;
        final displayName = user.fullName ?? l10n.defaultUser;
        final initial = displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : '?';

        return Column(
          children: [
            // Avatar (Placeholder with initial)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kCardBg,
                border: Border.all(color: kPrimary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: kTitleStyle.copyWith(fontSize: 40, color: kPrimary),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(displayName, style: kTitleStyle.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            // Phone
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_outlined, size: 16, color: kTextSecondary),
                const SizedBox(width: 6),
                Text(
                  displayPhone,
                  style: kBodyStyle.copyWith(color: kTextSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Edit profile button
            OutlinedButton.icon(
              onPressed: () async {
                final updated = await showProfileEditDialog(
                  context,
                  currentName: displayName,
                );
                if (updated && mounted) {
                  setState(() {
                    _userFuture = _userRepository.getMe();
                  });
                }
              },
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(l10n.editProfile),
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimary,
                side: BorderSide(color: kPrimary.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: _handleLogout,
      icon: const Icon(Icons.logout, size: 18),
      label: Text(l10n.logOut),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonRadius),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    // Safety guard — should not be called when flag is off, but be defensive.
    if (!AppConfig.enableBookings) return const SizedBox.shrink();

    if (_isLoadingBookings) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_bookings.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.upcomingReservations,
              style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._bookings.map((booking) => _buildBookingItem(booking)),
      ],
    );
  }

  Widget _buildBookingItem(BookingResponse booking) {
    final l10n = AppLocalizations.of(context)!;
    // Get restaurant name from cache or fallback to ID
    final restaurantName = _restaurantNames[booking.restaurant] ?? 'Restaurant';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [kCardShadow],
        border: Border.all(color: kPrimary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_available,
                  color: kPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: kBodyStyle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.bookingRef(booking.btid),
                      style: kBodyStyle.copyWith(
                        fontSize: 12,
                        color: kTextSecondary,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      booking.time,
                      style: kBodyStyle.copyWith(
                        color: kSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: kTextSecondary),
              const SizedBox(width: 6),
              Text(
                booking.date,
                style: kBodyStyle.copyWith(fontSize: 13, color: kTextSecondary),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people_outline, size: 14, color: kTextSecondary),
              const SizedBox(width: 6),
              Text(
                '${booking.numberOfPeople} guests',
                style: kBodyStyle.copyWith(fontSize: 13, color: kTextSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
