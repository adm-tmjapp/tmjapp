import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tmjapp/features/friend_ride/domain/entities/friend_driver.dart';

class FriendDriverRemoteDataSource {
  FriendDriverRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<FriendDriver?> findActiveDriverByPhone(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return null;

    final candidates = <String>{
      digits,
      if (digits.startsWith('55')) digits.substring(2),
      if (!digits.startsWith('55')) '55$digits',
      if (digits.startsWith('55')) '+$digits',
      if (!digits.startsWith('55')) '+55$digits',
      _formatBrazilianPhone(digits),
      _formatBrazilianPhone(digits, includeCountryCode: true),
    };

    for (final field in const ['phone_number', 'phoneNumber', 'phone']) {
      for (final candidate in candidates) {
        final snapshot = await _firestore
            .collection('drivers')
            .where(field, isEqualTo: candidate)
            .limit(1)
            .get();
        if (snapshot.docs.isEmpty) continue;

        final doc = snapshot.docs.first;
        final data = doc.data();
        // Não interrompa a busca em um documento antigo/inativo com o mesmo
        // telefone. O cadastro ativo pode estar no campo seguinte ou em outro
        // documento migrado do app do motorista.
        if (!_isAvailable(data)) continue;

        final vehicle = data['vehicle'] as Map<String, dynamic>?;
        return FriendDriver(
          id: doc.id,
          name: _text(data['name']) ?? 'Motorista parceiro',
          phoneNumber: _text(data[field]) ?? candidate,
          rating: (data['rating'] as num?)?.toDouble(),
          vehicle: _text(vehicle?['model']) ?? _text(data['vehicle_model']),
          licensePlate:
              _text(vehicle?['license_plate']) ?? _text(data['license_plate']),
        );
      }
    }
    return null;
  }

  String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  String _formatBrazilianPhone(
    String digits, {
    bool includeCountryCode = false,
  }) {
    final local = digits.startsWith('55') ? digits.substring(2) : digits;
    if (local.length != 11) return digits;
    final formatted = '(${local.substring(0, 2)}) '
        '${local.substring(2, 7)}-${local.substring(7)}';
    return includeCountryCode ? '+55 $formatted' : formatted;
  }

  /// O app do motorista publica disponibilidade como `availability: ONLINE`.
  /// Mantemos `active` por compatibilidade com os documentos legados, mas não
  /// devemos tratar o motorista online como indisponível apenas porque esse
  /// campo antigo não existe no Firestore.
  bool _isAvailable(Map<String, dynamic> data) {
    if (data['active'] == true ||
        data['isActive'] == true ||
        data['isAvailable'] == true ||
        data['online'] == true) {
      return true;
    }

    final values = [
      data['availability'],
      data['onlineStatus'],
      data['online_status'],
      data['status'],
      data['driverStatus'],
      data['driver_status'],
      data['isOnline'],
      data['is_online'],
    ];
    for (final value in values) {
      if (value == true) return true;
      if (value is Map) {
        if (_isAvailable(Map<String, dynamic>.from(value))) return true;
        continue;
      }
      final availability = value?.toString().trim().toUpperCase();
      if (availability == 'ONLINE' ||
          availability == 'AVAILABLE' ||
          availability == 'ACTIVE' ||
          availability == 'TRUE') {
        return true;
      }
    }
    return false;
  }
}
