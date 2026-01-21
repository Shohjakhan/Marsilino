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
  final double? discountPercentage;
  final List<String> galleryImages;
  final double? latitude;
  final double? longitude;
  final bool? bookingAvailable;
  final int? maxPeople;
  final List<String>? availableTimes;

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
    this.locationText,
    this.discountPercentage,
    this.galleryImages = const [],
    this.latitude,
    this.longitude,
    this.bookingAvailable,
    this.maxPeople,
    this.availableTimes,
  });

  /// Parse from JSON.
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Parse gallery images
    List<String> gallery = [];
    if (json['gallery_images'] != null) {
      gallery = (json['gallery_images'] as List)
          .map((img) => img['image']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
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
      socialMedia: json['social_media'] as Map<String, dynamic>?,
      menu: json['menu'] as List<dynamic>?,
      locationText: json['location_text'] as String?,
      discountPercentage: _parseDouble(json['discount_percentage']),
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
    if (hashtags == null || hashtags!.isEmpty) return [];
    return hashtags!
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Get discount text (e.g., "10% off").
  String? get discountText {
    if (discountPercentage == null || discountPercentage! <= 0) return null;
    return '${discountPercentage!.toInt()}% off';
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
