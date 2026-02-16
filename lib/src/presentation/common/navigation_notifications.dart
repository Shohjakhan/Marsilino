import 'package:flutter/material.dart';

/// Notification to trigger navigation to the map tab.
class NavigateToMapNotification extends Notification {
  final double? latitude;
  final double? longitude;
  final String? restaurantId;

  NavigateToMapNotification({
    this.latitude,
    this.longitude,
    this.restaurantId,
  });
}
