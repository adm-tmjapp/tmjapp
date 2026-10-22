class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? role;
  String? password;
  String? creatAt;
  bool? emailVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.creatAt,
    this.emailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] ?? json["_id"],
      name: json["name"],
      email: json["email"],
      phone: json["phone"],
      role: json["role"],
      password: json["password"],
      creatAt: json["creatAt"],
      emailVerified: _parseEmailVerified(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "password": password,
      "creatAt": creatAt,
      "emailVerified": emailVerified,
    };
  }
}

bool? _parseEmailVerified(Map<String, dynamic> json) {
  final value = json['emailVerified'] ??
      json['isEmailVerified'] ??
      json['email_verified'] ??
      json['is_email_verified'];
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if ({'true', '1', 'yes', 'sim', 'verified', 'confirmed'}
        .contains(normalized)) {
      return true;
    }
    if ({'false', '0', 'no', 'não', 'nao', 'pending', 'unverified'}
        .contains(normalized)) {
      return false;
    }
  }
  final verifiedAt = json['email_verified_at'] ?? json['emailVerifiedAt'];
  if (verifiedAt is String && verifiedAt.trim().isNotEmpty) return true;
  return null;
}
