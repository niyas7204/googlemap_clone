import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapHomePage extends StatefulWidget {
  const GoogleMapHomePage({super.key});

  @override
  State<GoogleMapHomePage> createState() => _GoogleMapHomePageState();
}

class _GoogleMapHomePageState extends State<GoogleMapHomePage> {
  bool getLocation = false;
  double? longitude;
  double? latitude;
  late GoogleMapController mapController;
  List<LatLng> polylineCordinates = [];
  Map<String, Marker> markers = {};
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    addMarker(LatLng(latitude!, longitude!));
  }

  @override
  void initState() {
    handleLocationPermission();
    super.initState();
  }

  void getPoliPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
            origin: PointLatLng(latitude!, longitude!),
            destination: PointLatLng(13.009420, 77.588860),
            mode: TravelMode.driving),
        googleApiKey: "AIzaSyDTEKGMwz2hby0t7yTukfdvSnC6lDBb7WU");
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) {
          polylineCordinates.add(LatLng(point.latitude, point.longitude));
        },
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getLocation
          ? GoogleMap(
              polylines: {
                  Polyline(
                      width: 3,
                      polylineId: PolylineId("route"),
                      points: polylineCordinates),
                },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: markers.values.toSet(),
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                  target: LatLng(latitude!, longitude!), zoom: 14))
          : Center(child: const CircularProgressIndicator()),
    );
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      log("latitude $latitude longitude ${longitude}");
      getLocation = true;
    });
    return true;
  }

  addMarker(LatLng location) {
    Marker(
        markerId: MarkerId("id1"),
        position: location,
        infoWindow:
            const InfoWindow(title: "leapsurge", snippet: "----------------"));
    markers["id1"] = Marker(
        markerId: const MarkerId("id1"),
        position: location,
        infoWindow:
            const InfoWindow(title: "leapsurge", snippet: "----------------"));
    markers["id2"] = const Marker(
        markerId: MarkerId("id2"),
        position: LatLng(13.009420, 77.588860),
        infoWindow:
            InfoWindow(title: "secondmmard", snippet: "----------------"));
    getPoliPoints();
    setState(() {});
  }
}
