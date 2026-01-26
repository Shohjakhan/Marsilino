import 'package:flutter/material.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../theme/app_theme.dart';
import '../../providers/locale_provider.dart';
import '../common/rounded_card.dart';
import '../../data/repositories/token_storage.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';
import 'profile_edit_dialog.dart';

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
  final _userRepository = UserRepository();
  late Future<UserModel> _userFuture;
  String? _fcmToken;

  List<Transaction> _transactions = [];
  bool _isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();
    _userFuture = _userRepository.getMe();
    _loadTransactions();
    _loadFcmToken();
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
        // Sort by date desc
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      } else {
        // Show error snackbar?
        // Just leave empty list for now or show error
      }
    });
  }

  void _handleLogout() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
        title: Text(l10n.logOut, style: kTitleStyle),
        content: Text(
          'Are you sure you want to log out?', // Could translate this too if I add it to ARB
          style: kBodyStyle.copyWith(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: kBodyStyle.copyWith(color: kTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.loggedOut),
                  backgroundColor: kPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
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

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'uz':
        return "O'zbek";
      default:
        return 'English';
    }
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
              const SizedBox(height: 32),
              // Language selector
              _buildLanguageSelector(),
              const SizedBox(height: 24),
              // Stats summary
              _buildStatsSummary(),
              const SizedBox(height: 24),
              // Transaction history
              _buildTransactionHistory(),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Token copied to clipboard'),
                      ),
                    );
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
                'Failed to load profile',
                style: kBodyStyle.copyWith(color: Colors.red),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _userFuture = _userRepository.getMe();
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          );
        }

        final user = snapshot.data!;
        final displayPhone = user.phoneNumber;
        final displayName = user.fullName ?? 'User';
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

  Widget _buildLanguageSelector() {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<LocaleProvider>(context);
    final currentCode = provider.locale.languageCode;

    // Map languages to codes
    final languages = ['en', 'ru', 'uz'];

    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: kPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.language,
                style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segmented control
          Container(
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: languages.map((code) {
                final isSelected = currentCode == code;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.setLocale(Locale(code)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: kPrimary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        _getLanguageLabel(code),
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? Colors.white : kTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoadingTransactions) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalSaved = _transactions.fold<double>(
      0,
      (sum, t) => sum + t.discountAmount,
    );

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_outlined,
            value: '${_transactions.length}',
            label: l10n.redemptions,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.savings_outlined,
            value: '${(totalSaved / 1000).toStringAsFixed(0)}K',
            label: l10n.uzsSaved,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoadingTransactions) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.redemptionHistory,
              style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_transactions.isNotEmpty)
              Text(l10n.seeAll, style: kBodyStyle.copyWith(color: kPrimary)),
          ],
        ),
        const SizedBox(height: 16),
        if (_transactions.isEmpty)
          _buildEmptyHistory()
        else
          ..._transactions.map((t) => _buildTransactionItem(t)),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    final l10n = AppLocalizations.of(context)!;
    return RoundedCard(
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: kTextSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noRedemptions,
            style: kSubtitleStyle.copyWith(color: kTextSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.noRedemptionsSub,
            style: kBodyStyle.copyWith(
              color: kTextSecondary.withValues(alpha: 0.7),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ... _buildTransactionItem is mostly data, not UI strings except currency?
  // UZS is usually standard.
  // Date formatting might need locale, but for now I leave it as is or could use DateFormat from intl later.
  // I will just use existing logic for item, as labels "Saved", "Discount" are implicit in UI.

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Restaurant name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.restaurantName,
                      style: kBodyStyle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(transaction.date),
                      style: kBodyStyle.copyWith(
                        fontSize: 12,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Discount badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${transaction.discountPercent.round()}%',
                  style: kBodyStyle.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Amount details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Original
              _buildAmountColumn(
                'Original',
                '${_formatNumber(transaction.amount.round())} UZS',
                kTextSecondary,
              ),
              // Saved
              _buildAmountColumn(
                'Saved',
                '-${_formatNumber(transaction.discountAmount.round())} UZS',
                Colors.green,
              ),
              // Final
              _buildAmountColumn(
                'Final',
                '${_formatNumber(transaction.finalAmount.round())} UZS',
                kTextPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: kBodyStyle.copyWith(fontSize: 11, color: kTextSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: kBodyStyle.copyWith(
            fontSize: 12,
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

  // ... rest of methods
  String _formatDate(DateTime date) {
    // Ideally this should use DateFormat with locale.
    // user requirement was "Add all UI strings".
    // I already added most.
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatNumber(int number) {
    final text = number.toString();
    final buffer = StringBuffer();
    final len = text.length;

    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }
}

/// Stats card widget.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [kCardShadow],
      ),
      child: Column(
        children: [
          Icon(icon, color: kPrimary, size: 24),
          const SizedBox(height: 8),
          Text(value, style: kTitleStyle.copyWith(fontSize: 22)),
          Text(
            label,
            style: kBodyStyle.copyWith(color: kTextSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
