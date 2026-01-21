import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/validation/booking_validator.dart';
import '../../common/input_field.dart';

/// A reusable booking form widget that manages booking data and validation.
///
/// This widget exposes callbacks for data changes and validation state changes,
/// and provides a public API to retrieve the current booking data.
class BookingForm extends StatefulWidget {
  /// Callback invoked whenever any field in the form changes.
  final ValueChanged<BookingData>? onChanged;

  /// Callback invoked whenever the validation state changes.
  final ValueChanged<bool>? onValidChanged;

  /// Initial booking data (optional).
  final BookingData? initialData;

  const BookingForm({
    super.key,
    this.onChanged,
    this.onValidChanged,
    this.initialData,
  });

  @override
  State<BookingForm> createState() => BookingFormState();
}

class BookingFormState extends State<BookingForm> {
  late int _peopleCount;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _commentsController = TextEditingController();

  bool _lastValidState = false;

  @override
  void initState() {
    super.initState();
    // Initialize from initial data or defaults
    _peopleCount = widget.initialData?.people ?? 4;
    _selectedDate = widget.initialData?.date;
    _selectedTime = widget.initialData?.time;
    _commentsController.text = widget.initialData?.comments ?? '';

    // Check initial validation state
    _lastValidState = BookingValidator.isValid(getBookingData());
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  /// Returns the current booking data from the form.
  BookingData getBookingData() {
    return BookingData(
      people: _peopleCount,
      date: _selectedDate,
      time: _selectedTime,
      comments: _commentsController.text.trim().isEmpty
          ? null
          : _commentsController.text.trim(),
    );
  }

  void _notifyChanges() {
    final data = getBookingData();
    widget.onChanged?.call(data);

    // Check if validation state changed
    final isValid = BookingValidator.isValid(data);
    if (isValid != _lastValidState) {
      _lastValidState = isValid;
      widget.onValidChanged?.call(isValid);
    }
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
      setState(() {
        _selectedDate = picked;
      });
      _notifyChanges();
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
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
      setState(() {
        _selectedTime = picked;
      });
      _notifyChanges();
    }
  }

  void _updatePeople(int delta) {
    final newValue = (_peopleCount + delta).clamp(1, 20);
    if (newValue != _peopleCount) {
      setState(() {
        _peopleCount = newValue;
      });
      _notifyChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPeopleCounter(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDatePicker()),
            const SizedBox(width: 12),
            Expanded(child: _buildTimePicker()),
          ],
        ),
        const SizedBox(height: 16),
        InputField(
          controller: _commentsController,
          placeholder: 'Comments (optional)',
          label: 'Comments',
          mode: InputFieldMode.text,
          onChanged: (_) => _notifyChanges(),
          borderRadius: 12,
        ),
      ],
    );
  }

  Widget _buildPeopleCounter() {
    return Row(
      children: [
        Icon(Icons.people_outline, color: kTextSecondary, size: 20),
        const SizedBox(width: 8),
        Text('People', style: kBodyStyle.copyWith(color: kTextSecondary)),
        const Spacer(),
        GestureDetector(
          onTap: () => _updatePeople(-1),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kTextSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove, size: 18, color: kTextPrimary),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$_peopleCount',
            textAlign: TextAlign.center,
            style: kTitleStyle.copyWith(fontSize: 18),
          ),
        ),
        GestureDetector(
          onTap: () => _updatePeople(1),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, size: 18, color: kPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final text = _selectedDate != null
        ? DateFormat('MMM d, y').format(_selectedDate!)
        : 'Select Date';
    final isSelected = _selectedDate != null;

    return GestureDetector(
      onTap: _pickDate,
      child: _buildSelectorContainer(
        icon: Icons.calendar_today,
        text: text,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildTimePicker() {
    final text = _selectedTime != null
        ? _selectedTime!.format(context)
        : 'Select Time';
    final isSelected = _selectedTime != null;

    return GestureDetector(
      onTap: _pickTime,
      child: _buildSelectorContainer(
        icon: Icons.access_time,
        text: text,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildSelectorContainer({
    required IconData icon,
    required String text,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? kPrimary : kTextSecondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? kPrimary : kTextSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: kBodyStyle.copyWith(
                color: isSelected ? kTextPrimary : kTextSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
