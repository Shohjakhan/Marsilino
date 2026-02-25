/// Model for a restaurant tag/category from the API.
///
/// API response format:
/// ```json
/// {"id": 1, "name": "Fast Food", "icon_url": "http://example.com/icon.png"}
/// ```
class RestaurantTag {
  final int id;
  final String name;
  final String? iconUrl;

  const RestaurantTag({required this.id, required this.name, this.iconUrl});

  factory RestaurantTag.fromJson(Map<String, dynamic> json) {
    return RestaurantTag(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      iconUrl: json['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (iconUrl != null) 'icon_url': iconUrl};
  }

  @override
  String toString() => 'RestaurantTag(id: $id, name: $name)';
}
