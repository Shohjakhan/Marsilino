import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Helper class for creating custom Google Maps markers.
class GoogleMapMarkerHelper {
  /// Creates a custom marker icon from a restaurant logo URL.
  /// Returns a default marker if logo is unavailable.
  static Future<BitmapDescriptor> createMarkerIcon({
    String? logoUrl,
    bool isSelected = false,
  }) async {
    if (logoUrl == null || logoUrl.isEmpty) {
      return _createDefaultMarker(isSelected);
    }

    try {
      // Download logo image
      final response = await http.get(Uri.parse(logoUrl));
      if (response.statusCode != 200) {
        return _createDefaultMarker(isSelected);
      }

      // Create custom marker with logo
      final Uint8List imageData = response.bodyBytes;
      return await _createMarkerFromBytes(imageData, isSelected);
    } catch (e) {
      return _createDefaultMarker(isSelected);
    }
  }

  /// Creates a default marker icon (simple colored circle).
  static Future<BitmapDescriptor> _createDefaultMarker(bool isSelected) async {
    final size = isSelected ? 80.0 : 60.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw circle
    final paint = Paint()
      ..color = isSelected ? const Color(0xFF2090F9) : const Color(0xFF8E8E93)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, paint);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, borderPaint);

    // Draw restaurant icon
    final iconPainter = TextPainter(
      text: const TextSpan(text: '🍽️', style: TextStyle(fontSize: 24)),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset((size - iconPainter.width) / 2, (size - iconPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  /// Creates a marker from image bytes.
  static Future<BitmapDescriptor> _createMarkerFromBytes(
    Uint8List imageData,
    bool isSelected,
  ) async {
    try {
      final size = isSelected ? 80.0 : 60.0;
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: size.toInt(),
        targetHeight: size.toInt(),
      );
      final frame = await codec.getNextFrame();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw circular background
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(size / 2, size / 2), size / 2, backgroundPaint);

      // Draw image in circle
      final path = Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(size / 2, size / 2),
            radius: size / 2 - 4,
          ),
        );
      canvas.clipPath(path);

      canvas.drawImage(frame.image, const Offset(2, 2), Paint());

      // Draw border
      final borderPaint = Paint()
        ..color = isSelected ? const Color(0xFF2090F9) : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 4 : 3;

      canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, borderPaint);

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
    } catch (e) {
      return _createDefaultMarker(isSelected);
    }
  }

  /// Creates a user location marker (blue dot).
  static Future<BitmapDescriptor> createUserLocationMarker() async {
    const size = 40.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Outer circle (light blue)
    final outerPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, outerPaint);

    // Inner circle (blue)
    final innerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(size / 2, size / 2), size / 4, innerPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(const Offset(size / 2, size / 2), size / 4, borderPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}
