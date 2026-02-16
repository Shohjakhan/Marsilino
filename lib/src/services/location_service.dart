import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle location-related logic.
class LocationService {
  /// Request location permission.
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Get current user coordinates.
  Future<Position?> getCurrentPosition() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Convert coordinates to a human-readable city/area name.
  Future<String?> getCityName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Try city, then sub-locality, then locality
        return placemark.locality ?? placemark.subLocality ?? placemark.name;
      }
    } catch (e) {
      // Ignore geocoding errors
    }
    return null;
  }

  /// Convenience method to get formatted location name.
  Future<String> getCurrentLocationName() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return 'Location Denied';

    final position = await getCurrentPosition();
    if (position == null) return 'Tashkent'; // Default fallback

    final cityName = await getCityName(position.latitude, position.longitude);
    return cityName ?? 'Unknown Location';
  }
}
