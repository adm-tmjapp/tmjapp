class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? role;
  String? password;
  String? creatAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.creatAt,
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
    };
  }
}
