import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobirural/pages/obstaclesadd.dart';
import 'package:mobirural/services/map_service.dart';
import 'package:mobirural/utils/user_current_local.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? mapController;
  LatLng? userLocation;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _loadMarkers();
  }

  Future<void> _requestLocationPermission() async {
    Position? location = await getCurrentLocation();
    if (location != null) {
      setState(() {
        userLocation = LatLng(location.latitude, location.longitude);
      });
    }
  }

  Future<void> _loadMarkers() async {
    Set<Marker> buildingMarkers = await MapService().getBuildingMarkers();
    Set<Marker> obstacleMarkers = await MapService().getObstacleMarkers();
    setState(() {
      _markers.addAll(buildingMarkers);
      _markers.addAll(obstacleMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) async {
              mapController = controller;
              await _setMapStyle();
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(-8.0169873, -34.946948),
              zoom: 15.0,
            ),
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            compassEnabled: true,
            onCameraMove: (CameraPosition position) {
              userLocation = position.target;
            },
          ),
          Positioned(
            bottom: 85.0, // Define a posição vertical do botão
            right: 16.0, // Define a posição horizontal do botão
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddObstacleScreen()),
                );
              },
              backgroundColor: AppColors.accentColor,
              child: const Icon(
                Icons.warning_rounded,
                size: 40.0,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/maps/silver.json');
    mapController?.setMapStyle(style);
  }
}
