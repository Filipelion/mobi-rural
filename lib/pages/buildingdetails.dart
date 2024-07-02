import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/models/user_model.dart';
import 'package:mobirural/pages/review.dart';
import 'package:mobirural/pages/reviewsforbuilding.dart';
import 'package:mobirural/pages/routes.dart';
import 'package:mobirural/services/buildingreview_service.dart';
import 'package:mobirural/utils/accessibility_info.dart';
import 'package:mobirural/utils/directions.dart';
import 'package:mobirural/utils/distance_calculator.dart';
import 'package:mobirural/services/favorite_service.dart';
import 'package:mobirural/utils/user_current_local.dart';
import 'package:provider/provider.dart';

class BuildingDetailsScreen extends StatefulWidget {
  final Building building;

  const BuildingDetailsScreen({super.key, required this.building});

  @override
  State<BuildingDetailsScreen> createState() => _BuildingDetailsScreenState();
}

class _BuildingDetailsScreenState extends State<BuildingDetailsScreen> {
  late bool isFavorite = false;
  late String userId;
  LatLng? destination;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final userId = userModel.getId();

    bool favoriteStatus = await FavoriteService()
        .isBuildingFavorite(userId ?? '', widget.building.id ?? '');
    setState(() {
      isFavorite = favoriteStatus;
    });
  }

  Future<void> toggleFavorite() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final userId = userModel.getId();

    if (isFavorite) {
      await FavoriteService()
          .removeFavoriteBuilding(userId!, widget.building.id!);
    } else {
      await FavoriteService().addFavoriteBuilding(userId!, widget.building);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<double> _getAverageRating() async {
    try {
      double averageRating = await BuildingReviewService()
          .getAverageRatingForBuilding(widget.building.id ?? '');

      return averageRating;
    } catch (e) {
      return 0.0; // Ou algum valor padrão em caso de erro
    }
  }

  @override
  Widget build(BuildContext context) {
    Building building = widget.building;

    Widget appbar = PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Center(
              child: Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 40.0,
                semanticLabel: 'Voltar',
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              toggleFavorite();
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: AppColors.primaryColor,
              size: 50.0,
            ),
          ),
        ],
      ),
    );

    Widget imagem = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: Image.network(
                  building.image ?? '',
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );

    Widget predio = Text(
      building.name ?? '',
      style: const TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );

    Widget distancia = FutureBuilder<double?>(
      future: calculateDistanceToBuilding(building),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Calculando distância...',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor),
            textAlign: TextAlign.center,
          );
        } else if (snapshot.hasError) {
          return Text(
            'Erro ao calcular distância: ${snapshot.error}',
            style: const TextStyle(
                fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.red),
            textAlign: TextAlign.center,
          );
        } else if (snapshot.hasData) {
          double? distance = snapshot.data;
          return Text(
            'distância: ${distance?.toStringAsFixed(2)} Km',
            style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor),
            textAlign: TextAlign.center,
          );
        } else {
          return const Text('Distância indisponível',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor),
              textAlign: TextAlign.center);
        }
      },
    );

    Widget mediaAvaliacoes = FutureBuilder<double>(
      future: _getAverageRating(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Calculando média das avaliações...',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          );
        } else if (snapshot.hasError) {
          return Text(
            'Erro ao calcular média das avaliações: ${snapshot.error}',
            style: const TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          );
        } else if (snapshot.hasData) {
          double averageRating = snapshot.data ?? 0.0;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReviewsForBuildingScreen(building: building),
                ),
              );
            },
            child: Text(
              'Média das avaliações: ${averageRating.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return const Text(
            'Média das avaliações indisponível',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          );
        }
      },
    );

    Widget infos = Padding(
        padding: const EdgeInsets.all(10.0),
        child: AccessibilityInfoWidget(
          specialParking: building.parking,
          accessRamps: building.accessRamps,
          elevator: building.elevator,
          adaptedBathroom: building.adaptedBathroom,
          tactilePaving: building.floor,
        ));

    Widget avalia = Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewScreen(building: building),
            ),
          );
        },
        child: const Text(
          'Avalie este prédio',
          style: TextStyle(
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );

    Widget guiar = Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            Position? userLocation = await getCurrentLocation();
            LatLng destination = LatLng(
              building.coordinates?.latitude ?? 0.0,
              building.coordinates?.longitude ?? 0.0,
            );

            RouteService routeService = RouteService();
            if (userLocation != null) {
              List<LatLng> routePoints =
                  await routeService.getDirections(userLocation, destination);

              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RouteScreen(routePoints: routePoints),
                ),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              AppColors.primaryColor,
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 10.0),
            ),
          ),
          child: const Text(
            'Guie-me até o prédio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: ListView(
        children: [
          appbar,
          imagem,
          const SizedBox(height: 5.0),
          predio,
          distancia,
          mediaAvaliacoes,
          infos,
          avalia,
          guiar,
        ],
      ),
    );
  }
}
