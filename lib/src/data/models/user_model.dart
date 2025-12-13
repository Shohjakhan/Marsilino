class UserModel {
  final String id;
  final String phoneNumber;
  final String? fullName;

  const UserModel({required this.id, required this.phoneNumber, this.fullName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      fullName: json['full_name'] as String?,
    );
  }
}
