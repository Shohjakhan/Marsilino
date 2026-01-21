import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking_request_model.dart';
import '../../data/repositories/bookings_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/validation/booking_validator.dart';
import '../common/primary_button.dart';
import '../common/rounded_card.dart';
import 'book_success_page.dart';

/// Booking confirmation page that displays booking details and a confirm button.
class BookConfirmPage extends StatefulWidget {
  final String restaurantName;
  final String restaurantId;
  final BookingData bookingData;

  const BookConfirmPage({
    super.key,
    required this.restaurantName,
    required this.restaurantId,
    required this.bookingData,
  });

  @override
  State<BookConfirmPage> createState() => _BookConfirmPageState();
}

class _BookConfirmPageState extends State<BookConfirmPage> {
  final _repository = BookingsRepository();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _confirmBooking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create booking request
      final request = BookingRequest.fromBookingData(
        restaurantId: widget.restaurantId,
        bookingData: widget.bookingData,
      );

      // Call API
      final result = await _repository.createBooking(request);

      if (!mounted) return;

      if (result.success && result.booking != null) {
        // Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookSuccessPage(
              restaurantName: widget.restaurantName,
              booking: result.booking!,
            ),
          ),
        );
      } else {
        // Show error
        setState(() {
          _isLoading = false;
          _errorMessage = result.error ?? 'Failed to create booking';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Confirm Booking',
          style: kTitleStyle.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review your booking',
                      style: kTitleStyle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please confirm the details below',
                      style: kBodyStyle.copyWith(color: kTextSecondary),
                    ),
                    const SizedBox(height: 24),
                    _buildRestaurantCard(),
                    const SizedBox(height: 16),
                    _buildDetailsCard(),
                    if (widget.bookingData.comments != null &&
                        widget.bookingData.comments!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildCommentsCard(),
                    ],
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) _buildErrorCard(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard() {
    return RoundedCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant, color: kPrimary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restaurantName,
                  style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Table Reservation',
                  style: kBodyStyle.copyWith(
                    color: kTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.people_outline,
            'Number of Guests',
            '${widget.bookingData.people} ${widget.bookingData.people == 1 ? 'person' : 'people'}',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.calendar_today,
            'Date',
            widget.bookingData.date != null
                ? DateFormat('EEEE, MMMM d, y').format(widget.bookingData.date!)
                : 'Not selected',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time,
            'Time',
            widget.bookingData.time != null
                ? _formatTime(widget.bookingData.time!)
                : 'Not selected',
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsCard() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_outlined, color: kTextSecondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Special Requests',
                style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.bookingData.comments!,
            style: kBodyStyle.copyWith(color: kTextSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: kPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kPrimary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: kBodyStyle.copyWith(color: kTextSecondary, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: kBodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: kBodyStyle.copyWith(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildBottomBar() {
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
      child: PrimaryButton(
        label: 'Confirm Booking',
        onPressed: _isLoading ? null : _confirmBooking,
        isLoading: _isLoading,
      ),
    );
  }
}
