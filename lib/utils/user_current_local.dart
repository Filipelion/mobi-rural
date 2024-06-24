import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Verificar se os serviços de localização estão ativados
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissão negada pelo usuário
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissão negada permanentemente, mostrar uma mensagem ou direcionar para as configurações do dispositivo
    return null;
  }

  // Obter a posição atual do usuário
  return await Geolocator.getCurrentPosition();
}
