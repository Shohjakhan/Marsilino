import 'tag_model.dart';

/// Restaurant model from API.
class Restaurant {
  final String id;
  final String name;
  final String? logo;
  final String? description;
  final String? hashtags;
  final String? workingHours;
  final String? contactInformation;
  final Map<String, dynamic>? socialMedia;
  final List<dynamic>? menu;
  final String? locationText;
  final double? cashbackPercentage;
  final String? tin;
  final List<RestaurantTag> tags;
  final List<String> galleryImages;
  final double? latitude;
  final double? longitude;
  final bool? bookingAvailable;
  final int? maxPeople;
  final List<String>? availableTimes;
  final String? menuUrl;

  const Restaurant({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    this.hashtags,
    this.workingHours,
    this.contactInformation,
    this.socialMedia,
    this.menu,
    this.menuUrl,
    this.locationText,
    this.cashbackPercentage,
    this.tin,
    this.tags = const [],
    this.galleryImages = const [],
    this.latitude,
    this.longitude,
    this.bookingAvailable,
    this.maxPeople,
    this.availableTimes,
  });

  /// Parse from JSON.
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Parse gallery images (handle both 'gallery' and 'gallery_images')
    List<String> gallery = [];
    final rawGallery = json['gallery'] ?? json['gallery_images'];
    if (rawGallery != null && rawGallery is List) {
      gallery = rawGallery
          .map((img) {
            if (img is Map) return img['image']?.toString() ?? '';
            return img.toString();
          })
          .where((url) => url.isNotEmpty)
          .toList();
    }

    // Handle menu (can be List or String URL)
    List<dynamic>? menuList;
    String? menuUrl;
    if (json['menu'] is List) {
      menuList = json['menu'] as List<dynamic>;
    } else if (json['menu'] is String) {
      menuUrl = json['menu'] as String;
    }

    // Parse tags (structured objects from new API)
    List<RestaurantTag> parsedTags = [];
    final rawTags = json['tags'];
    if (rawTags is List) {
      parsedTags = rawTags
          .whereType<Map<String, dynamic>>()
          .map((t) => RestaurantTag.fromJson(t))
          .toList();
    }

    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      hashtags: json['hashtags'] as String?,
      workingHours: json['working_hours'] as String?,
      contactInformation: json['contact_information'] as String?,
      socialMedia: json['social_media'] is Map
          ? json['social_media'] as Map<String, dynamic>
          : null,
      menu: menuList,
      menuUrl: menuUrl,
      locationText: json['location_text'] as String?,
      cashbackPercentage:
          _parseDouble(json['cashback_percentage']) ??
          _parseDouble(json['discount_percentage']),
      tin: json['tin'] as String?,
      tags: parsedTags,
      galleryImages: gallery,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      bookingAvailable: json['booking_available'] as bool?,
      maxPeople: json['max_people'] as int?,
      availableTimes: (json['available_times'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Get hashtags as list.
  List<String> get tagsList {
    // Prefer structured tags from new API, fallback to hashtags string
    if (tags.isNotEmpty) {
      return tags.map((t) => t.name).toList();
    }
    if (hashtags == null || hashtags!.isEmpty) return [];
    return hashtags!
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Get cashback text (e.g., "10% cashback").
  String? get cashbackText {
    if (cashbackPercentage == null || cashbackPercentage! <= 0) return null;
    return '${cashbackPercentage!.toInt()}% cashback';
  }

  /// Get Instagram handle from social media.
  String? get instagram {
    return socialMedia?['instagram'] as String?;
  }

  /// Get Telegram handle from social media.
  String? get telegram {
    return socialMedia?['telegram'] as String?;
  }

  /// Get phone from contact information.
  String? get phone {
    // Try to extract phone from contact info
    if (contactInformation == null) return null;
    final phoneMatch = RegExp(
      r'\+?\d[\d\s\-]{8,}',
    ).firstMatch(contactInformation!);
    return phoneMatch?.group(0);
  }
}
