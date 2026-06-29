import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class FullViewMap extends StatefulWidget {




  const FullViewMap({super.key});

  @override
  State<FullViewMap> createState() => _FullViewMapState();
}

class _FullViewMapState extends State<FullViewMap> {

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final Map<String,Marker> _markers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: CameraPosition(

                  target: LatLng(23.87439585681482, 90.40610580847999),
                  zoom: 10
              ),
              markers: _markers.values.toSet(),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                addMarker('home', LatLng(23.87439585681482, 90.40610580847999),"Home");
              }
          ),
        ],
      ),
    );
  }


  addMarker(String id,LatLng location,String title) async{
    //todo: asset img
    final markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(20, 20)), "");

    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(title: title),
      // icon: networkIcon,
      icon: markerIcon,
    );
    _markers[id] = marker;
    setState(() {});
  }
}
