import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../theme/app_theme.dart';
import 'package:http/http.dart' as http;

/// Helper class for creating custom Yandex Maps markers.
class MapMarkerHelper {
  static final Map<String, BitmapDescriptor> _iconCache = {};

  /// Creates a custom marker icon from a restaurant logo URL.
  /// Returns a default marker if logo is unavailable.
  static Future<BitmapDescriptor> createMarkerIcon({
    String? logoUrl,
    bool isSelected = false,
  }) async {
    final cacheKey = '${logoUrl ?? 'default'}_$isSelected';
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    if (logoUrl == null || logoUrl.isEmpty) {
      final icon = await _createDefaultMarker(isSelected);
      _iconCache[cacheKey] = icon;
      return icon;
    }

    try {
      // Download logo image
      final response = await http.get(Uri.parse(logoUrl));
      if (response.statusCode != 200) {
        return createMarkerIcon(logoUrl: null, isSelected: isSelected);
      }

      // Create custom marker with logo
      final Uint8List imageData = response.bodyBytes;
      final icon = await _createMarkerFromBytes(imageData, isSelected);
      _iconCache[cacheKey] = icon;
      return icon;
    } catch (e) {
      return createMarkerIcon(logoUrl: null, isSelected: isSelected);
    }
  }

  /// Creates a default marker icon (simple pin with generic icon).
  static Future<BitmapDescriptor> _createDefaultMarker(bool isSelected) async {
    final size = isSelected ? 100.0 : 80.0;
    final totalHeight = size * 1.3;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..color = isSelected ? kSecondary : kPrimary
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw pin shape (teardrop)
    final pinPath = Path()
      ..moveTo(size / 2, totalHeight)
      ..cubicTo(size * 0.1, size * 0.9, 0, size * 0.7, 0, size / 2)
      ..arcTo(Rect.fromLTWH(0, 0, size, size), 3.14159, 3.14159, false)
      ..cubicTo(size, size * 0.7, size * 0.9, size * 0.9, size / 2, totalHeight)
      ..close();

    canvas.drawPath(pinPath, paint);
    canvas.drawPath(pinPath, borderPaint);

    // Draw white inner circle to match the image hole
    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 4, holePaint);

    // Draw restaurant icon
    final iconPainter = TextPainter(
      text: const TextSpan(text: '🍽️', style: TextStyle(fontSize: 28)),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset((size - iconPainter.width) / 2, (size - iconPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), totalHeight.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  /// Creates a marker from image bytes (pin with logo).
  static Future<BitmapDescriptor> _createMarkerFromBytes(
    Uint8List imageData,
    bool isSelected,
  ) async {
    try {
      final size = isSelected ? 120.0 : 100.0;
      final totalHeight = size * 1.3;
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: (size * 0.8).toInt(),
        targetHeight: (size * 0.8).toInt(),
      );
      final frame = await codec.getNextFrame();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paint = Paint()
        ..color = isSelected ? kSecondary : kPrimary
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      // Draw pin shape (teardrop)
      final pinPath = Path()
        ..moveTo(size / 2, totalHeight)
        ..cubicTo(size * 0.1, size * 0.9, 0, size * 0.7, 0, size / 2)
        ..arcTo(Rect.fromLTWH(0, 0, size, size), 3.14159, 3.14159, false)
        ..cubicTo(
          size,
          size * 0.7,
          size * 0.9,
          size * 0.9,
          size / 2,
          totalHeight,
        )
        ..close();

      canvas.drawPath(pinPath, paint);
      canvas.drawPath(pinPath, borderPaint);

      // Draw white background for logo (circular area)
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(size / 2, size / 2), size * 0.35, whitePaint);

      // Draw circular logo clipped to the inner area
      final logoPath = Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(size / 2, size / 2),
            radius: size * 0.35 - 2,
          ),
        );
      canvas.clipPath(logoPath);

      // Center the logo image
      final double logoDiameter = size * 0.7;
      canvas.drawImage(
        frame.image,
        Offset(size / 2 - logoDiameter / 2, size / 2 - logoDiameter / 2),
        Paint(),
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), totalHeight.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
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
