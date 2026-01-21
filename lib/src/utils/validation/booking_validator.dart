import 'package:flutter/material.dart';

/// Booking data model containing all information needed for a table reservation.
class BookingData {
  final int people;
  final DateTime? date;
  final TimeOfDay? time;
  final String? comments;

  const BookingData({
    required this.people,
    this.date,
    this.time,
    this.comments,
  });

  BookingData copyWith({
    int? people,
    DateTime? date,
    TimeOfDay? time,
    String? comments,
  }) {
    return BookingData(
      people: people ?? this.people,
      date: date ?? this.date,
      time: time ?? this.time,
      comments: comments ?? this.comments,
    );
  }

  @override
  String toString() {
    return 'BookingData(people: $people, date: $date, time: $time, comments: $comments)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingData &&
        other.people == people &&
        other.date == date &&
        other.time == time &&
        other.comments == comments;
  }

  @override
  int get hashCode {
    return Object.hash(people, date, time, comments);
  }
}

/// Validator for booking data.
class BookingValidator {
  /// Validates booking data according to business rules:
  /// - people must be >= 1
  /// - date must not be null
  /// - date must be today or in the future
  /// - time must not be null
  static bool isValid(BookingData data) {
    // Validate people count
    if (data.people < 1) {
      return false;
    }

    // Validate date exists
    if (data.date == null) {
      return false;
    }

    // Validate date is not in the past (compare only dates, not times)
    final today = DateTime.now();
    final dateOnly = DateTime(
      data.date!.year,
      data.date!.month,
      data.date!.day,
    );
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (dateOnly.isBefore(todayOnly)) {
      return false;
    }

    // Validate time exists
    if (data.time == null) {
      return false;
    }

    return true;
  }

  /// Returns a list of validation error messages for the given booking data.
  /// Returns an empty list if all validations pass.
  static List<String> validate(BookingData data) {
    final errors = <String>[];

    if (data.people < 1) {
      errors.add('Number of people must be at least 1');
    }

    if (data.date == null) {
      errors.add('Please select a date');
    } else {
      final today = DateTime.now();
      final dateOnly = DateTime(
        data.date!.year,
        data.date!.month,
        data.date!.day,
      );
      final todayOnly = DateTime(today.year, today.month, today.day);

      if (dateOnly.isBefore(todayOnly)) {
        errors.add('Date cannot be in the past');
      }
    }

    if (data.time == null) {
      errors.add('Please select a time');
    }

    return errors;
  }
}
