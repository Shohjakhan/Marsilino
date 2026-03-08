import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../utils/validation/booking_validator.dart';
import '../common/input_field.dart';
import '../common/primary_button.dart';
import '../common/rounded_card.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import 'book_confirm_page.dart';

class BookingSection extends StatefulWidget {
  final String restaurantName;
  final String restaurantId;
  final bool? bookingAvailable;
  final int? maxPeople;
  final List<String>? availableTimes;

  const BookingSection({
    super.key,
    required this.restaurantName,
    required this.restaurantId,
    this.bookingAvailable,
    this.maxPeople,
    this.availableTimes,
  });

  @override
  State<BookingSection> createState() => _BookingSectionState();
}

class _BookingSectionState extends State<BookingSection> {
  int _peopleCount = 4;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _commentsController = TextEditingController();

  // Track if the user has started interacting with the form
  bool _hasStartedEditing = false;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void _onInteraction() {
    if (!_hasStartedEditing) {
      setState(() {
        _hasStartedEditing = true;
      });
    }
  }

  bool get _isValid {
    // If booking is strictly unavailable, form is invalid
    if (widget.bookingAvailable == false) return false;
    return _selectedDate != null && _selectedTime != null;
  }

  void _incrementPeople() {
    _onInteraction();
    setState(() {
      // Check max limit if available
      if (widget.maxPeople != null && _peopleCount >= widget.maxPeople!) {
        return;
      }
      if (_peopleCount < 20) _peopleCount++;
    });
  }

  void _decrementPeople() {
    _onInteraction();
    setState(() {
      if (_peopleCount > 1) _peopleCount--;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimary,
              onPrimary: Colors.white,
              surface: kCardBg,
              onSurface: kTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _onInteraction();
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final initialDateTime = _selectedTime != null
        ? DateTime(
            now.year,
            now.month,
            now.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          )
        : now;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: kCardBg,
          child: SafeArea(
            top: false,
            child: CupertinoDatePicker(
              initialDateTime: initialDateTime,
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              onDateTimeChanged: (DateTime newDateTime) {
                _onInteraction();
                final time = TimeOfDay.fromDateTime(newDateTime);
                setState(() {
                  _selectedTime = time;
                  // Force 24h format string manually
                  final hour = time.hour.toString().padLeft(2, '0');
                  final minute = time.minute.toString().padLeft(2, '0');
                  _timeController.text = '$hour:$minute';
                });
              },
            ),
          ),
        );
      },
    );
  }

  void _selectSuggestedTime(String timeStr) {
    _onInteraction();
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final time = TimeOfDay(hour: hour, minute: minute);
      setState(() {
        _selectedTime = time;
        _timeController.text = time.format(context);
      });
    } catch (e) {
      // Ignore invalid format
    }
  }

  @override
  Widget build(BuildContext context) {
    // If booking is explicitly unavailable
    if (widget.bookingAvailable == false) {
      return RoundedCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: kTextSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Booking Unavailable',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This restaurant is not accepting bookings at the moment.',
                style: TextStyle(color: kTextSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.bookTableTitle, style: kTitleStyle),
          const SizedBox(height: 24),

          // People Count
          _buildPeopleCounter(),
          const SizedBox(height: 24),

          // Date & Time
          Row(
            children: [
              Expanded(
                child: InputField(
                  controller: _dateController,
                  placeholder: 'Date',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InputField(
                  controller: _timeController,
                  placeholder: 'Time',
                  icon: Icons.access_time,
                  readOnly: true,
                  onTap: _pickTime,
                ),
              ),
            ],
          ),

          // Suggested Times (if available)
          if (widget.availableTimes != null &&
              widget.availableTimes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Available Times',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.availableTimes!.map((time) {
                  final looksSelected =
                      _selectedTime != null &&
                      '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}' ==
                          time;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(time),
                      backgroundColor: looksSelected
                          ? kPrimary.withValues(alpha: 0.1)
                          : kBackground,
                      labelStyle: TextStyle(
                        color: looksSelected ? kPrimary : kTextPrimary,
                        fontWeight: looksSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: looksSelected
                            ? kPrimary
                            : kTextSecondary.withValues(alpha: 0.2),
                      ),
                      onPressed: () => _selectSuggestedTime(time),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Comments
          InputField(
            controller: _commentsController,
            placeholder: 'Any special requests? (Optional)',
            maxLines: 3,
            textInputAction: TextInputAction.done,
            // When user types in comments, we consider that interaction too
            onChanged: (_) => _onInteraction(),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: PrimaryButton(
                label: l10n.bookTableBtn,
                onPressed: _isValid
                    ? () {
                        final bookingData = BookingData(
                          people: _peopleCount,
                          date: _selectedDate,
                          time: _selectedTime,
                          comments: _commentsController.text.trim().isEmpty
                              ? null
                              : _commentsController.text.trim(),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookConfirmPage(
                              restaurantName: widget.restaurantName,
                              restaurantId: widget.restaurantId,
                              bookingData: bookingData,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ),
            crossFadeState: _hasStartedEditing
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            if (widget.maxPeople != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Max ${widget.maxPeople} people',
                  style: const TextStyle(fontSize: 12, color: kTextSecondary),
                ),
              ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: kBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kTextSecondary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              _buildCounterButton(Icons.remove, _decrementPeople),
              SizedBox(
                width: 40,
                child: Text(
                  '$_peopleCount',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildCounterButton(Icons.add, _incrementPeople),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 20, color: kTextPrimary),
        ),
      ),
    );
  }
}
