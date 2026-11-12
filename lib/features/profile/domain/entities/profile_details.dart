class ProfileDetails {
  const ProfileDetails({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.cpfMasked,
    this.hasCpf = false,
    required this.profilePhotoUrl,
  });

  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? cpfMasked;
  final bool hasCpf;
  final String? profilePhotoUrl;

  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Usuario';
    }

    return trimmed.split(' ').first;
  }

  String get initials {
    final parts =
        name.trim().split(' ').where((part) => part.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return 'TU';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  ProfileDetails copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? cpfMasked,
    bool? hasCpf,
    String? profilePhotoUrl,
  }) {
    return ProfileDetails(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cpfMasked: cpfMasked ?? this.cpfMasked,
      hasCpf: hasCpf ?? this.hasCpf,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}
