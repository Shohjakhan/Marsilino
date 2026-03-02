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
  final String? locationLink;
  final bool isLiked;
  final double? averageRating;
  final int? totalRatings;

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
    this.locationLink,
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
    this.isLiked = false,
    this.averageRating,
    this.totalRatings,
  });

  /// Parse from JSON.
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Parse gallery images (handle both 'gallery', 'gallery_images', and 'media' arrays)
    List<String> gallery = [];
    final rawGallery =
        json['gallery'] ?? json['gallery_images'] ?? json['media'];
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
    final rawMenu = json['menu'];
    if (rawMenu is List) {
      menuList = rawMenu;
    } else if (rawMenu != null) {
      menuUrl = rawMenu.toString();
    }

    // Parse location_link
    final rawLocationLink = json['location_link'];
    final String? locationLink = rawLocationLink != null
        ? rawLocationLink.toString()
        : null;

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
      locationLink: locationLink,
      locationText: json['location_text'] as String?,
      cashbackPercentage:
          _parseDouble(json['cashback_percentage']) ??
          _parseDouble(json['discount_percentage']),
      tin: json['tin'] as String?,
      tags: parsedTags,
      galleryImages: gallery,
      latitude:
          _parseDouble(json['latitude']) ??
          _extractLatFromYandex(json['yandex_map_url'] as String?),
      longitude:
          _parseDouble(json['longitude']) ??
          _extractLngFromYandex(json['yandex_map_url'] as String?),
      bookingAvailable: json['booking_available'] as bool?,
      maxPeople: json['max_people'] as int?,
      availableTimes: (json['available_times'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      isLiked: json['is_liked'] as bool? ?? false,
      averageRating: _parseDouble(json['average_rating']),
      totalRatings: json['total_ratings'] as int?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static double? _extractLatFromYandex(String? url) {
    if (url == null || url.isEmpty) return null;
    // Try to find lat,lng in coordinates like ?ll=69.2401%2C41.2995 or coordinates param
    // format is often ll=longitude,latitude or pt=longitude,latitude in yandex urls
    // Some urls might have coordinates in path /maps/org/name/id/?ll=lng,lat

    // Yandex standard format is usually ll=longitude,latitude
    final llMatch = RegExp(r'll=([0-9.]+)(?:,|%2C)([0-9.]+)').firstMatch(url);
    if (llMatch != null && llMatch.groupCount >= 2) {
      return double.tryParse(
        llMatch.group(2)!,
      ); // Group 2 is latitude in Yandex (ll=lon,lat)
    }

    // Also try pt parameter
    final ptMatch = RegExp(r'pt=([0-9.]+)(?:,|%2C)([0-9.]+)').firstMatch(url);
    if (ptMatch != null && ptMatch.groupCount >= 2) {
      return double.tryParse(ptMatch.group(2)!);
    }

    // Could also just be something like lat=41.123
    final latMatch = RegExp(r'lat=([0-9.]+)').firstMatch(url);
    if (latMatch != null) return double.tryParse(latMatch.group(1)!);

    return null;
  }

  static double? _extractLngFromYandex(String? url) {
    if (url == null || url.isEmpty) return null;

    final llMatch = RegExp(r'll=([0-9.]+)(?:,|%2C)([0-9.]+)').firstMatch(url);
    if (llMatch != null && llMatch.groupCount >= 1) {
      return double.tryParse(llMatch.group(1)!); // Group 1 is longitude
    }

    final ptMatch = RegExp(r'pt=([0-9.]+)(?:,|%2C)([0-9.]+)').firstMatch(url);
    if (ptMatch != null && ptMatch.groupCount >= 1) {
      return double.tryParse(ptMatch.group(1)!);
    }

    final lonMatch = RegExp(r'lon(?:gitude)?=([0-9.]+)').firstMatch(url);
    if (lonMatch != null) return double.tryParse(lonMatch.group(1)!);

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
