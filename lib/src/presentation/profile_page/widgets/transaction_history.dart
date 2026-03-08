import 'package:flutter/material.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../../data/repositories/transactions_repository.dart';
import '../../../theme/app_theme.dart';
import '../../common/rounded_card.dart';

/// Transaction history list with stats summary.
class TransactionHistory extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isLoading;

  const TransactionHistory({
    super.key,
    required this.transactions,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
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
            if (transactions.isNotEmpty)
              Text(l10n.seeAll, style: kBodyStyle.copyWith(color: kPrimary)),
          ],
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          _buildEmptyHistory(l10n)
        else
          ...transactions.map((t) => _buildTransactionItem(t)),
      ],
    );
  }

  Widget _buildEmptyHistory(AppLocalizations l10n) {
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

  Widget _buildTransactionItem(Transaction transaction) {
    final isCashback = transaction.cashbackAmount > 0;
    final color = isCashback ? Colors.green : kPrimary;
    final icon = Icons.receipt_long_outlined;
    final checkAmount = transaction.amount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [kCardShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.restaurantName,
                  style: kBodyStyle.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(transaction.date)} • ${_formatTime(transaction.date)}',
                  style: kBodyStyle.copyWith(
                    fontSize: 12,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatNumber(checkAmount.round())} UZS',
                style: kBodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              if (isCashback) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${_formatNumber(transaction.cashbackAmount.round())} UZS (${transaction.cashbackPercent.toInt()}%)',
                    style: kBodyStyle.copyWith(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
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

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatNumber(int number) {
    final text = number.toString();
    final buffer = StringBuffer();
    final len = text.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

/// Stats summary row showing redemption count and total saved.
class StatsSummary extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isLoading;

  const StatsSummary({
    super.key,
    required this.transactions,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalSaved = transactions.fold<double>(
      0,
      (sum, t) => sum + t.cashbackAmount,
    );

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_outlined,
            value: '${transactions.length}',
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
}

/// Individual stat card widget.
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
