import 'package:cloud_firestore/cloud_firestore.dart';
// Imports
import 'dart:async'; // Importado para usar StreamSubscription
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Note: 'location_app.dart' foi removido porque usaremos a biblioteca 'location' diretamente.
import 'package:tmjapp/screens/auth/sign_in_screen.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/custom_style.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/screens/dashboard/notifications_screen.dart';
import 'package:tmjapp/screens/dashboard/ride_summery_screen.dart';
import 'package:tmjapp/screens/dashboard/settings_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tmjapp/widgets/my_rating.dart';
import 'package:tmjapp/class/url_launcher.dart';
import 'package:tmjapp/screens/messaging_screen.dart';
import 'package:tmjapp/screens/invoice_screen.dart';
import 'package:tmjapp/widgets/trip_planner_bottomsheet.dart';
import 'package:tmjapp/widgets/driver_options_bottomsheet.dart';
import 'package:tmjapp/widgets/ride_loading_bottomsheet.dart';

bool isAccepted = true;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Função para buscar motoristas ativos e adicionar marcadores
  Future<void> fetchActiveDrivers() async {
    try {
      final QuerySnapshot snapshot = await firestore
          .collection('drivers')
          .where('active', isEqualTo: true)
          .get();
      final BitmapDescriptor carIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/car_yellow.png',
      );
      Set<Marker> driverMarkers = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final location = data['location'];
        if (location != null && location is GeoPoint) {
          driverMarkers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(location.latitude, location.longitude),
              icon: carIcon,
              infoWindow: InfoWindow(title: data['name'] ?? 'Motorista'),
            ),
          );
        }
      }
      setState(() {
        _markers = driverMarkers;
      });
    } catch (e) {
      debugPrint('Erro ao buscar motoristas: $e');
    }
  }

  // Função para salvar localização do usuário (motorista) no Firestore
  Future<void> saveUserLocation(double lat, double lng, String userId) async {
    try {
      await firestore.collection('drivers').doc(userId).update({
        'lat': lat,
        'lng': lng,
        'active': true,
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erro ao salvar localização: $e');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Use a biblioteca 'location' diretamente
  final Location location = Location();

  // Adicione um controlador para o mapa e uma subscrição para a localização
  GoogleMapController? _mapController;
  StreamSubscription<LocationData>? _locationSubscription;
  LatLng? _currentPosition;
  bool _isLoadingMap = true;

  TextEditingController searchController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  SharedPreferences? prefs;
  bool isAction = true;
  String? name;
  String? phone;

  Timer? _debounce;

  Set<Marker> _markers = {};
  Polyline? _routePolyline;

  bool isButtonVisible =
      true; // Variável para controlar a visibilidade do botão

  // Substitua pelo método correto para obter o ID do usuário logado
  final String userId = "id_do_usuario_logado";

  @override
  void initState() {
    super.initState();
    _listenToLocationUpdates(); // Nova função para obter a localização em tempo real
    getData();
    if (kDebugMode) {
      print('rider: $isAccepted');
    }
    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () {
        // fetchPlaceSuggestions(searchController.text); // Removido
      });
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    searchController.dispose(); // Libera o controller corretamente
    _debounce?.cancel();
    super.dispose();
  }

  // FUNÇÃO MELHORADA: Obtém e atualiza a localização em tempo real
  Future<void> _listenToLocationUpdates() async {
    // 1. Verifique as permissões de localização
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

    // 2. Inicia a subscrição para o stream de localização
    _locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) async {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _isLoadingMap = false; // O mapa está pronto para ser mostrado
        });
        // Salva localização do usuário (motorista) no Firestore
        // Substitua 'userId' pelo id do usuário logado
        if (name != null) {
          await saveUserLocation(
              currentLocation.latitude!, currentLocation.longitude!, name!);
        }
        // Move a câmara do mapa para a nova localização
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition!),
        );
        // Atualiza os motoristas ativos no mapa
        await fetchActiveDrivers();
        if (kDebugMode) {
          print(
              "Nova localização: Lat: ${_currentPosition?.latitude}, Long: ${_currentPosition?.longitude}");
        }
      }
    });
  }

  Future<void> getData() async {
    prefs = await SharedPreferences.getInstance();
    name = prefs?.getString(Strings.prefName);
    phone = prefs?.getString(Strings.prefNumber);
    setState(() {});
  }

  Future<LatLng?> fetchPlaceLocation(String placeId) async {
    final String apiKey = 'AIzaSyBggG1v_Lbevj0NiZERxC6sYjsvfrrCvMI';
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    }
    return null;
  }

  Future<void> drawRoute(LatLng destination) async {
    if (_currentPosition == null) return;
    final String apiKey = 'AIzaSyBggG1v_Lbevj0NiZERxC6sYjsvfrrCvMI';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey&language=pt-br';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      List<LatLng> polylineCoords = decodePolyline(points);
      setState(() {
        _routePolyline = Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: polylineCoords,
        );
      });
    }
  }

  List<LatLng> decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: const Text(
          'TMJ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Centraliza o título
        leading: IconButton(
          icon: Image.asset('assets/menu.png', color: Colors.black),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        actions: [],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                child: profileWidget(context),
                decoration: BoxDecoration(color: CustomColor.accentColor)),
            ListTile(
                title: Text(Strings.rideSummery, style: CustomStyle.textStyle),
                leading: Icon(Icons.history, color: CustomColor.greyColor),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RideSummeryScreen()));
                }),
            ListTile(
                title: Text(Strings.notification, style: CustomStyle.textStyle),
                leading:
                    Icon(Icons.notifications, color: CustomColor.greyColor),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationScreen()));
                }),
            ListTile(
                title: Text(Strings.settings, style: CustomStyle.textStyle),
                leading: Icon(Icons.settings, color: CustomColor.greyColor),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingsScreen()));
                }),
            ListTile(
                title: Text(Strings.signOut, style: CustomStyle.textStyle),
                leading: Icon(Icons.exit_to_app, color: CustomColor.greyColor),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                })
          ],
        ),
      ),
      body: Stack(
        children: [
          _isLoadingMap
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: GoogleMap(
                            zoomControlsEnabled: false,
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                              if (_currentPosition != null) {
                                _mapController!.animateCamera(
                                  CameraUpdate.newLatLng(_currentPosition!),
                                );
                              }
                            },
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition ??
                                  LatLng(-23.5505, -46.6333),
                              zoom: 15,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            markers: _markers,
                            polylines:
                                _routePolyline != null ? {_routePolyline!} : {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          Positioned(
            top: 20,
            left: MediaQuery.of(context).size.width / 2 -
                100, // Centraliza o botão considerando o novo tamanho
            child: Visibility(
              visible: isButtonVisible,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  setState(() {
                    isButtonVisible = false; // Oculta o botão ao pressionar
                  });

                  final routeResult = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => TripPlannerBottomSheet(
                      fromController: fromController,
                      toController: toController,
                      onFromTap: () {},
                      onToTap: () {},
                    ),
                  );

                  if (routeResult != null && routeResult is Map) {
                    // Extrai lat/lng dos objetos retornados
                    final from = routeResult['from'];
                    final to = routeResult['to'];
                    if (from != null &&
                        to != null &&
                        from['latitude'] != null &&
                        from['longitude'] != null &&
                        to['latitude'] != null &&
                        to['longitude'] != null) {
                      final toLatLng = LatLng(
                        double.tryParse(to['latitude']) ?? 0.0,
                        double.tryParse(to['longitude']) ?? 0.0,
                      );
                      await drawRoute(toLatLng);
                      // Exibe o DriverOptionsBottomSheet após carregar a rota
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => WillPopScope(
                          onWillPop: () async {
                            final shouldCancel = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Cancelar corrida'),
                                content:
                                    const Text('Deseja cancelar a corrida?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Não'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Sim'),
                                  ),
                                ],
                              ),
                            );
                            if (shouldCancel == true) {
                              setState(() {
                                _routePolyline = null;
                              });
                              return true;
                            }
                            return false;
                          },
                          child: SafeArea(
                            child: SingleChildScrollView(
                              child: DriverOptionsBottomSheet(
                                driverOptions: [
                                  {
                                    'image': 'assets/car1.png',
                                    'type': 'Comfort',
                                    'time': '12:24 · 4 min',
                                    'distance': '2 km',
                                    'price': 17.02,
                                  },
                                  {
                                    'image': 'assets/car2.png',
                                    'type': 'UberX',
                                    'time': '12:25 · 5 min',
                                    'distance': '3 km',
                                    'price': 11.94,
                                  },
                                  {
                                    'image': 'assets/car3.png',
                                    'type': 'Black',
                                    'time': '12:26 · 6 min',
                                    'distance': '4 km',
                                    'price': 20.62,
                                  },
                                  {
                                    'image': 'assets/car3.png',
                                    'type': 'Moto',
                                    'time': '12:27 · 3 min',
                                    'distance': '1.5 km',
                                    'price': 8.50,
                                  },
                                ],
                                userId: userId,
                                pickupLocation: {
                                  'address': from['title'] ?? '',
                                  'coordinates': {
                                    'latitude': from['latitude'] ?? 0.0,
                                    'longitude': from['longitude'] ?? 0.0,
                                  },
                                },
                                destinationLocation: {
                                  'address': to['title'] ?? '',
                                  'coordinates': {
                                    'latitude': to['latitude'] ?? 0.0,
                                    'longitude': to['longitude'] ?? 0.0,
                                  },
                                },
                                onSelect: (option, payment) {
                                  Navigator.of(context).pop();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        RideLoadingBottomSheet(
                                      from: from['title'] ?? '',
                                      to: to['title'] ?? '',
                                      price: double.tryParse(
                                              option['price'].toString()) ??
                                          0.0,
                                      payment: payment,
                                      onCancel: () async {
                                        setState(() {
                                          _routePolyline = null;
                                          isButtonVisible = true;
                                        });
                                        Navigator.of(context).pop(false);
                                        return true;
                                      },
                                      onClose: () async {
                                        setState(() {
                                          _routePolyline = null;
                                          isButtonVisible = true;
                                        });
                                        Navigator.of(context).pop(true);
                                        return true;
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        isButtonVisible =
                            true; // Exibe o botão novamente se não houver dados
                      });
                    }
                  } else {
                    setState(() {
                      isButtonVisible =
                          true; // Exibe o botão novamente se não houver dados
                    });
                  }
                },
                label: const Text('Para onde?'),
                icon: const Icon(Icons.search),
                backgroundColor: Colors.white, // Fundo branco
                foregroundColor:
                    Colors.black, // Ícone e texto pretos para contraste
                extendedPadding: const EdgeInsets.symmetric(
                    horizontal: 40), // Aumenta o tamanho
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- O resto do seu código permanece o mesmo ---
  profileWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: Dimensions.heightSize * 3),
        child: ListTile(
            leading: Image.asset('assets/driver.png'),
            title: Text(name ?? "não encontrado",
                style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: Dimensions.largeTextSize,
                    fontWeight: FontWeight.bold)),
            subtitle: Text(phone ?? "",
                style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: Dimensions.defaultTextSize))));
  }

  acceptedRiderWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
            left: Dimensions.marginSize,
            right: Dimensions.marginSize,
            top: Dimensions.heightSize * 3),
        child: Column(children: [
          Row(children: [
            Image.asset('assets/driver.png', width: 80, height: 80),
            const SizedBox(width: Dimensions.widthSize),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Luchi Kubala',
                  style: GoogleFonts.roboto(
                      color: CustomColor.primaryColor,
                      fontSize: Dimensions.largeTextSize,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: Dimensions.heightSize * 0.5),
              Text('Captown City', style: CustomStyle.textStyle),
              const SizedBox(height: Dimensions.heightSize * 0.5),
              const MyRating(rating: '5')
            ])
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                height: 40.0,
                width: 120.0,
                decoration: const BoxDecoration(
                    color: Color(0xFFFCEADA),
                    borderRadius: BorderRadius.all(
                        Radius.circular(Dimensions.radius * 2))),
                child: Center(
                    child: Text(Strings.driverArrived,
                        style: GoogleFonts.roboto(
                            color: CustomColor.accentColor)))),
            const SizedBox(width: Dimensions.widthSize),
            GestureDetector(
                child: Container(
                    height: 40.0,
                    width: 120.0,
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(
                            Radius.circular(Dimensions.radius * 2))),
                    child: Center(
                        child: Text(Strings.finishRide,
                            style: GoogleFonts.roboto(color: Colors.white)))),
                onTap: () {
                  setState(() {
                    isAccepted = true;
                  });
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => InvoiceScreen()));
                })
          ]),
          const SizedBox(height: Dimensions.heightSize * 3),
          const Divider(color: Colors.grey),
          Row(children: [
            Expanded(
                flex: 1,
                child: GestureDetector(
                    child: Container(
                        child: Text(Strings.cancelRide,
                            style: GoogleFonts.roboto(
                                color: Colors.red,
                                fontSize: Dimensions.defaultTextSize),
                            textAlign: TextAlign.center)),
                    onTap: () {
                      setState(() {
                        isAccepted = true;
                      });
                    })),
            Expanded(
                flex: 1,
                child: GestureDetector(
                    child: Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Icon(Icons.messenger, color: CustomColor.accentColor),
                          const SizedBox(width: Dimensions.widthSize * 0.5),
                          Text(Strings.message, style: CustomStyle.textStyle)
                        ])),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MessagingScreen()));
                    })),
            Expanded(
                flex: 1,
                child: GestureDetector(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call, color: CustomColor.accentColor),
                          const SizedBox(width: Dimensions.widthSize * 0.5),
                          Text(Strings.callDriver, style: CustomStyle.textStyle)
                        ]),
                    onTap: () {
                      UrlLauncher.url(Strings.phoneNumber);
                    }))
          ])
        ]));
  }

  // FUNÇÕES ANTIGAS REMOVIDAS
  // Future<void> initGeolocation() async { ... }
  // Não é mais necessário, pois usamos _listenToLocationUpdates()
}

class ScheduleBottomSheet extends StatefulWidget {
  @override
  _ScheduleBottomSheetState createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  DateTime selectedDate = DateTime.now();
  String scheduleRideDate = 'Choose your trip date';

  TimeOfDay selectedStartTime = TimeOfDay.now();
  String startTime = 'Start Time';

  TimeOfDay selectedEndTime = TimeOfDay.now();
  String endTime = 'End Time';

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        color: const Color(0xFF737373),
        child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: Center(
                      child: Container(
                          height: 5.0,
                          width: 100.0,
                          decoration: const BoxDecoration(
                              color: CustomColor.primaryColor,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Dimensions.radius)))))),
              scheduleRideWidget(context)
            ])));
  }

  scheduleRideWidget(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.marginSize, right: Dimensions.marginSize),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Strings.scheduleRide,
                      style: GoogleFonts.roboto(
                          color: CustomColor.primaryColor,
                          fontSize: Dimensions.extraLargeTextSize * 1.5,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: Dimensions.heightSize * 3),
                  GestureDetector(
                      child: Text(scheduleRideDate,
                          style: GoogleFonts.roboto(
                              color: CustomColor.accentColor,
                              fontSize: Dimensions.extraLargeTextSize)),
                      onTap: () {
                        _selectDate(context);
                      }),
                  const Divider(color: Colors.grey),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    GestureDetector(
                        child: Text(startTime,
                            style: GoogleFonts.roboto(
                                color: CustomColor.greyColor,
                                fontSize: Dimensions.extraLargeTextSize)),
                        onTap: () {
                          _selectStartTime(context);
                        }),
                    Text(' - ',
                        style: GoogleFonts.roboto(
                            fontSize: Dimensions.largeTextSize * 2)),
                    GestureDetector(
                        child: Text(endTime,
                            style: GoogleFonts.roboto(
                                color: CustomColor.greyColor,
                                fontSize: Dimensions.extraLargeTextSize)),
                        onTap: () {
                          _selectEndTime(context);
                        })
                  ]),
                  const SizedBox(height: Dimensions.heightSize * 3),
                  GestureDetector(
                      child: Container(
                          height: 50.0,
                          decoration: const BoxDecoration(
                              color: CustomColor.primaryColor,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Dimensions.radius * 0.5))),
                          child: Center(
                              child: Text(Strings.setScheduleTime.toUpperCase(),
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: Dimensions.largeTextSize,
                                      fontWeight: FontWeight.bold)))),
                      onTap: () {
                        Navigator.of(context).pop();
                      })
                ])));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1950, 1),
        lastDate: DateTime(2022));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        scheduleRideDate = "${selectedDate.toLocal()}".split(' ')[0];
        print('date: ' + scheduleRideDate);
      });
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedStartTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!);
        });

    if (pickedTime != null && pickedTime != selectedStartTime)
      setState(() {
        selectedStartTime = pickedTime;
        startTime =
            selectedStartTime.toString().split('TimeOfDay(')[1].split(')')[0];
        print('2 : ' + startTime);
      });
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedEndTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!);
        });

    if (pickedTime != null && pickedTime != selectedEndTime)
      setState(() {
        selectedEndTime = pickedTime;

        endTime =
            selectedEndTime.toString().split('TimeOfDay(')[1].split(')')[0];
        print('2 : ' + endTime);
      });
  }
}

class RequestBottomSheet extends StatefulWidget {
  @override
  _RequestBottomSheetState createState() => _RequestBottomSheetState();
}

class _RequestBottomSheetState extends State<RequestBottomSheet> {
  double progress = 0;
  Timer? _timer;
  int _start = 0;

  currentProgressColor() {
    if (progress >= 0.6 && progress < 0.8) {
      return Colors.orange;
    }
    if (progress >= 0.8) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  double percentage = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        color: const Color(0xFF737373),
        child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: Center(
                      child: Container(
                          height: 5.0,
                          width: 100.0,
                          decoration: const BoxDecoration(
                              color: CustomColor.primaryColor,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Dimensions.radius)))))),
              requestRideWidget(context)
            ])));
  }

  requestRideWidget(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.marginSize, right: Dimensions.marginSize),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(Strings.requestingRide,
                      style: GoogleFonts.roboto(
                          color: CustomColor.primaryColor,
                          fontSize: Dimensions.extraLargeTextSize * 1.5,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: Dimensions.heightSize * 3),
                  Padding(
                      padding: EdgeInsets.all(15.0),
                      child: LinearPercentIndicator(
                          animation: false,
                          lineHeight: 10.0,
                          animationDuration: 2500,
                          percent: percentage,
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: currentProgressColor(),
                          backgroundColor: CustomColor.primaryColor)),
                  const SizedBox(height: Dimensions.heightSize * 3),
                  GestureDetector(
                      child: Container(
                          height: 50.0,
                          decoration: const BoxDecoration(
                              color: CustomColor.primaryColor,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Dimensions.radius * 0.5))),
                          child: Center(
                              child: Text(Strings.cancelRequest.toUpperCase(),
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: Dimensions.largeTextSize,
                                      fontWeight: FontWeight.bold)))),
                      onTap: () {
                        Navigator.of(context).pop();
                      })
                ])));
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 100) {
        setState(() {
          timer.cancel();
          print('finish');
          Navigator.of(context).pop();
          isAccepted = false;
        });
      } else {
        setState(() {
          _start = _start + 20;
          percentage = _start.toDouble() / 100;
          if (kDebugMode) {
            print('timer: ' + percentage.toString());
          }
        });
      }
    });
  }
}
