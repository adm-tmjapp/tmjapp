import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:tmjapp/core/config/app_config.dart';

class TripPlannerBottomSheet extends StatefulWidget {
  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback? onFromTap;
  final VoidCallback? onToTap;

  const TripPlannerBottomSheet({
    Key? key,
    required this.fromController,
    required this.toController,
    this.onFromTap,
    this.onToTap,
  }) : super(key: key);

  @override
  State<TripPlannerBottomSheet> createState() => _TripPlannerBottomSheetState();
}

class _TripPlannerBottomSheetState extends State<TripPlannerBottomSheet> {
  bool isLoading = false;
  List<Map<String, String>> recentLocations = [];
  bool searchingOrigin = false;

  Map<String, String> fromLocation = {};
  Map<String, String> toLocation = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final currentLocation = await location.getLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      final apiKey = AppConfig.instance.googlePlacesApiKey;
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentLocation.latitude},${currentLocation.longitude}&key=$apiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['results'][0]['formatted_address'];
        setState(() {
          widget.fromController.text = address;
          final loc = recentLocations.firstWhere(
            (loc) => loc['title'] == address,
            orElse: () => {},
          );

          fromLocation = {
            'title': address,
            'subtitle': loc['subtitle'] ?? '',
            'latitude': currentLocation.latitude.toString(),
            'longitude': currentLocation.longitude.toString(),
          };
        });
      }
    }
  }

  Future<void> searchPlaces(String input) async {
    setState(() {
      isLoading = true;
    });
    final apiKey = AppConfig.instance.googlePlacesApiKey;
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apiKey&language=pt-br';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = data['predictions'] as List;
      setState(() {
        recentLocations = predictions
            .map<Map<String, String>>((p) => {
                  'title':
                      (p['terms'] != null && (p['terms'] as List).isNotEmpty)
                          ? (p['terms'][0]['value'] ?? '')
                          : (p['description'] ?? ''),
                  'subtitle':
                      p['structured_formatting']?['secondary_text'] ?? '',
                  'place_id': p['place_id'] ?? '',
                })
            .toList();
        isLoading = false;
      });
    }
  }

  Future<Map<String, double>> fetchLatLng(String placeId) async {
    final apiKey = AppConfig.instance.googlePlacesApiKey;
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      return {
        'latitude': location['lat'],
        'longitude': location['lng'],
      };
    }
    return {};
  }

  void _returnRouteLocations() {
    if (fromLocation.isEmpty || toLocation.isEmpty) return;
    Navigator.of(context).pop({
      'from': fromLocation,
      'to': toLocation,
    });
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required Icon icon,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        icon: icon,
        hintText: hint,
        border: InputBorder.none,
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  controller.clear();
                  setState(() {
                    recentLocations = [];
                  });
                },
              )
            : null,
      ),
      style: GoogleFonts.roboto(fontSize: 16),
      onChanged: onChanged,
    );
  }

  Widget buildLocationList({
    required bool isLoading,
    required List<Map<String, String>> locations,
    required bool isSearchingOrigin,
    required void Function(Map<String, String>) onTap,
  }) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (locations.isNotEmpty) {
      return Column(
        children: locations
            .map((loc) => ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(loc['title'] ?? '', style: GoogleFonts.roboto()),
                  subtitle: Text(loc['subtitle'] ?? '',
                      style: GoogleFonts.roboto(fontSize: 13)),
                  onTap: () => onTap(loc),
                ))
            .toList(),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasResults = recentLocations.isNotEmpty;
    final minHeight =
        hasResults ? null : MediaQuery.of(context).size.height * 0.3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0,
        maxHeight:
            MediaQuery.of(context).size.height * (hasResults ? 0.8 : 0.9),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomInset > 0 ? bottomInset : 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    'Planeje sua próxima viagem',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  buildTextField(
                    controller: widget.fromController,
                    hint: 'Local de partida',
                    icon: const Icon(Icons.circle, size: 18),
                    onChanged: (value) {
                      setState(() {
                        searchingOrigin = true;
                      });
                      searchPlaces(value);
                    },
                  ),
                  const Divider(),
                  buildTextField(
                    controller: widget.toController,
                    hint: 'Para onde?',
                    icon: const Icon(Icons.square, size: 18),
                    onChanged: (value) {
                      setState(() {
                        searchingOrigin = false;
                      });
                      searchPlaces(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            buildLocationList(
              isLoading: searchingOrigin && isLoading,
              locations: searchingOrigin ? recentLocations : [],
              isSearchingOrigin: searchingOrigin,
              onTap: (loc) async {
                final latLng = await fetchLatLng(loc['place_id'] ?? '');
                widget.fromController.text = loc['title'] ?? '';
                setState(() {
                  searchingOrigin = false;
                  recentLocations = [];
                  fromLocation = {
                    'title': loc['title'] ?? '',
                    'subtitle': loc['subtitle'] ?? '',
                    'latitude': latLng['latitude'].toString(),
                    'longitude': latLng['longitude'].toString(),
                  };
                });
                _returnRouteLocations();
              },
            ),
            buildLocationList(
              isLoading: !searchingOrigin && isLoading,
              locations: !searchingOrigin ? recentLocations : [],
              isSearchingOrigin: !searchingOrigin,
              onTap: (loc) async {
                final latLng = await fetchLatLng(loc['place_id'] ?? '');
                widget.toController.text = loc['title'] ?? '';
                setState(() {
                  recentLocations = [];
                  toLocation = {
                    'title': loc['title'] ?? '',
                    'subtitle': loc['subtitle'] ?? '',
                    'latitude': latLng['latitude'].toString(),
                    'longitude': latLng['longitude'].toString(),
                  };
                });

                _returnRouteLocations();
              },
            ),
          ],
        ),
      ),
    );
  }
}
