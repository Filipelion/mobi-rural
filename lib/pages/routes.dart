import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/services/map_service.dart';
import 'package:mobirural/utils/user_current_local.dart';
import 'package:mobirural/widgets/appbar_edit.dart';

class RouteScreen extends StatefulWidget {
  final List<LatLng> routePoints;

  const RouteScreen({super.key, required this.routePoints});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final Widget _appbaredit = const AppBarEdit(titleName: 'Rota até o destino');
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: _appbaredit,
      ),
      body: GoogleMap(
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: widget.routePoints,
            color: AppColors.accentColor,
            width: 5,
          ),
        },
        onMapCreated: (controller) async {
          mapController = controller;
          await _setMapStyle();
        },
        initialCameraPosition: CameraPosition(
          target: widget.routePoints.first,
          zoom: 15,
        ),
        markers: _markers,
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        compassEnabled: true,
        onCameraMove: (CameraPosition position) {
          userLocation = position.target;
        },
      ),
    );
  }

  Future<void> _setMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/maps/silver.json');
    mapController?.setMapStyle(style);
  }
}
