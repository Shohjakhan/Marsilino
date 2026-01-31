import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking_response_model.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../common/rounded_card.dart';
import '../common/secondary_button.dart';

/// Success page displayed after booking confirmation.
class BookSuccessPage extends StatelessWidget {
  final String restaurantName;
  final BookingResponse booking;

  const BookSuccessPage({
    super.key,
    required this.restaurantName,
    required this.booking,
  });

  void _goToRestaurant(BuildContext context) {
    // Pop back to restaurant page (removes both success and confirm pages)
    Navigator.of(context).popUntil(
      (route) => route.isFirst || route.settings.name == '/restaurant',
    );
  }

  void _goToHome(BuildContext context) {
    // Navigate to home (root) - pop all routes
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildSuccessIcon(),
                    const SizedBox(height: 24),
                    Text(
                      'Booking Confirmed!',
                      style: kTitleStyle.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your table has been reserved successfully',
                      style: kBodyStyle.copyWith(
                        color: kTextSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildReferenceCard(),
                    const SizedBox(height: 16),
                    _buildSummaryCard(),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: kSuccess.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_circle, color: kSuccess, size: 64),
    );
  }

  Widget _buildReferenceCard() {
    return RoundedCard(
      child: Column(
        children: [
          Text(
            'Booking Reference',
            style: kBodyStyle.copyWith(color: kTextSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kSecondaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.reference,
              style: kTitleStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please show this reference when you arrive',
            style: kBodyStyle.copyWith(color: kTextSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant, color: kPrimary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: kSubtitleStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Status: ${booking.status}',
                      style: kBodyStyle.copyWith(
                        color: kTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildSummaryRow(
            Icons.people_outline,
            '${booking.people} ${booking.people == 1 ? 'Guest' : 'Guests'}',
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.calendar_today, _formatDate(booking.date)),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.access_time, _formatTime(booking.time)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: kTextSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: kBodyStyle.copyWith(fontSize: 15))),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('EEEE, MMM d, y').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: 'Back to Restaurant',
            onPressed: () => _goToRestaurant(context),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Go to Home',
            onPressed: () => _goToHome(context),
          ),
        ],
      ),
    );
  }
}
