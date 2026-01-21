import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant/src/utils/validation/booking_validator.dart';

void main() {
  group('BookingValidator', () {
    test('isValid returns true for valid booking data', () {
      final bookingData = BookingData(
        people: 4,
        date: DateTime.now().add(const Duration(days: 1)),
        time: const TimeOfDay(hour: 19, minute: 30),
        comments: 'Window seat please',
      );

      expect(BookingValidator.isValid(bookingData), true);
    });

    test('isValid returns true for valid booking without comments', () {
      final bookingData = BookingData(
        people: 2,
        date: DateTime.now(),
        time: const TimeOfDay(hour: 12, minute: 0),
      );

      expect(BookingValidator.isValid(bookingData), true);
    });

    test('isValid returns false when people < 1', () {
      final bookingData = BookingData(
        people: 0,
        date: DateTime.now(),
        time: const TimeOfDay(hour: 19, minute: 30),
      );

      expect(BookingValidator.isValid(bookingData), false);
    });

    test('isValid returns false when date is null', () {
      const bookingData = BookingData(
        people: 4,
        date: null,
        time: TimeOfDay(hour: 19, minute: 30),
      );

      expect(BookingValidator.isValid(bookingData), false);
    });

    test('isValid returns false when date is in the past', () {
      final bookingData = BookingData(
        people: 4,
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: const TimeOfDay(hour: 19, minute: 30),
      );

      expect(BookingValidator.isValid(bookingData), false);
    });

    test('isValid returns false when time is null', () {
      final bookingData = BookingData(
        people: 4,
        date: DateTime.now(),
        time: null,
      );

      expect(BookingValidator.isValid(bookingData), false);
    });

    test('validate returns empty list for valid data', () {
      final bookingData = BookingData(
        people: 4,
        date: DateTime.now(),
        time: const TimeOfDay(hour: 19, minute: 30),
      );

      final errors = BookingValidator.validate(bookingData);
      expect(errors, isEmpty);
    });

    test('validate returns error for people < 1', () {
      final bookingData = BookingData(
        people: 0,
        date: DateTime.now(),
        time: const TimeOfDay(hour: 19, minute: 30),
      );

      final errors = BookingValidator.validate(bookingData);
      expect(errors, contains('Number of people must be at least 1'));
    });

    test('validate returns error for null date', () {
      const bookingData = BookingData(
        people: 4,
        date: null,
        time: TimeOfDay(hour: 19, minute: 30),
      );

      final errors = BookingValidator.validate(bookingData);
      expect(errors, contains('Please select a date'));
    });

    test('validate returns error for past date', () {
      final bookingData = BookingData(
        people: 4,
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: const TimeOfDay(hour: 19, minute: 30),
      );

      final errors = BookingValidator.validate(bookingData);
      expect(errors, contains('Date cannot be in the past'));
    });

    test('validate returns error for null time', () {
      final bookingData = BookingData(
        people: 4,
        date: DateTime.now(),
        time: null,
      );

      final errors = BookingValidator.validate(bookingData);
      expect(errors, contains('Please select a time'));
    });

    test('validate returns multiple errors for invalid data', () {
      const bookingData = BookingData(people: 0, date: null, time: null);

      final errors = BookingValidator.validate(bookingData);
      expect(errors.length, 3);
      expect(errors, contains('Number of people must be at least 1'));
      expect(errors, contains('Please select a date'));
      expect(errors, contains('Please select a time'));
    });
  });

  group('BookingData', () {
    test('copyWith creates new instance with updated values', () {
      final original = BookingData(
        people: 4,
        date: DateTime(2026, 1, 22),
        time: const TimeOfDay(hour: 19, minute: 30),
        comments: 'Original comment',
      );

      final updated = original.copyWith(people: 6, comments: 'Updated comment');

      expect(updated.people, 6);
      expect(updated.date, DateTime(2026, 1, 22));
      expect(updated.time, const TimeOfDay(hour: 19, minute: 30));
      expect(updated.comments, 'Updated comment');
    });

    test('equality works correctly', () {
      final booking1 = BookingData(
        people: 4,
        date: DateTime(2026, 1, 22),
        time: const TimeOfDay(hour: 19, minute: 30),
        comments: 'Test',
      );

      final booking2 = BookingData(
        people: 4,
        date: DateTime(2026, 1, 22),
        time: const TimeOfDay(hour: 19, minute: 30),
        comments: 'Test',
      );

      expect(booking1, booking2);
    });

    test('hashCode is consistent', () {
      final booking1 = BookingData(
        people: 4,
        date: DateTime(2026, 1, 22),
        time: const TimeOfDay(hour: 19, minute: 30),
      );

      final booking2 = BookingData(
        people: 4,
        date: DateTime(2026, 1, 22),
        time: const TimeOfDay(hour: 19, minute: 30),
      );

      expect(booking1.hashCode, booking2.hashCode);
    });
  });
}
