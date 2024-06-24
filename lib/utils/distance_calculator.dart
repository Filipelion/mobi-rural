import 'dart:math' show atan2, cos, pow, sin, sqrt;
import 'package:geolocator/geolocator.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/utils/user_current_local.dart';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double radius = 6371;

  double degToRad(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  // Fórmula de Haversine para calcular a distância entre dois pontos
  double dLat = degToRad(lat2 - lat1);
  double dLon = degToRad(lon2 - lon1);
  double a = pow(sin(dLat / 2), 2) +
      cos(degToRad(lat1)) * cos(degToRad(lat2)) * pow(sin(dLon / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = radius * c;

  return distance;
}

Future<double?> calculateDistanceToBuilding(Building building) async {
  Position? userLocation = await getCurrentLocation();

  if (userLocation != null && building.coordinates != null) {
    double userLat = userLocation.latitude;
    double userLon = userLocation.longitude;
    double buildingLat = building.coordinates!.latitude;
    double buildingLon = building.coordinates!.longitude;

    double distance = calculateDistance(
      userLat,
      userLon,
      buildingLat,
      buildingLon,
    );

    return distance;
  } else {
    return null; // Se a localização do usuário ou as coordenadas do prédio forem nulas
  }
}
