class HomeProfile {
  const HomeProfile({
    required this.name,
    required this.phone,
    required this.userId,
  });

  final String name;
  final String phone;
  final String userId;

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
}
