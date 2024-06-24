import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteService {
  static const apiKey = 'CHAVE_API';

  Future<List<LatLng>> getDirections(
      Position origin, LatLng destination) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=walking&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);

      if (decodedResponse['routes'] != null &&
          decodedResponse['routes'].isNotEmpty) {
        List<LatLng> points = [];

        for (var leg in decodedResponse['routes'][0]['legs']) {
          for (var step in leg['steps']) {
            // Adiciona pontos intermediários para melhorar a precisão
            List<LatLng> intermediatePoints =
                decodePolyline(step['polyline']['points']);
            points.addAll(intermediatePoints);
          }
        }

        return points;
      } else {
        throw Exception('No routes found');
      }
    } else {
      throw Exception('Failed to fetch directions');
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int result = 1;
      int shift = 0;
      int b, lat0, lng0;

      do {
        b = encoded.codeUnitAt(index++) - 63 - 1;
        result += b << shift;
        shift += 5;
      } while (b >= 0x1F);

      lat0 = (result & 1) == 1 ? ~(result >> 1) : (result >> 1);

      result = 1;
      shift = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63 - 1;
        result += b << shift;
        shift += 5;
      } while (b >= 0x1F);

      lng0 = (result & 1) == 1 ? ~(result >> 1) : (result >> 1);

      lat += lat0;
      lng += lng0;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}
