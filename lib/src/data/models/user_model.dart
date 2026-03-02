class UserModel {
  final String id;
  final String phoneNumber;
  final String? fullName;
  final double? walletBalance;
  final String? language;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.walletBalance,
    this.language,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['user_id'] ?? json['pk'])?.toString() ?? '',
      phoneNumber:
          json['phone_number'] as String? ?? json['phone'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String?,
      walletBalance: double.tryParse(json['wallet_balance']?.toString() ?? ''),
      language: json['language'] as String?,
    );
  }
}
