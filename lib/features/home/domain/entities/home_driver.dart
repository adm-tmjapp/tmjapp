import 'package:tmjapp/features/home/domain/entities/home_location.dart';

class HomeDriver {
  const HomeDriver({
    required this.id,
    required this.name,
    required this.location,
  });

  final String id;
  final String name;
  final HomeLocation location;
}
