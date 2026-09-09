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
    };

    for (final field in const ['phone_number', 'phone']) {
      for (final candidate in candidates) {
        final snapshot = await _firestore
            .collection('drivers')
            .where(field, isEqualTo: candidate)
            .limit(1)
            .get();
        if (snapshot.docs.isEmpty) continue;

        final doc = snapshot.docs.first;
        final data = doc.data();
        if (data['active'] != true) return null;

        final vehicle = data['vehicle'] as Map<String, dynamic>?;
        return FriendDriver(
          id: doc.id,
          name: _text(data['name']) ?? 'Motorista parceiro',
          phoneNumber: candidate,
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
}
