import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/models/user_model.dart';
import 'package:mobirural/services/building_service.dart';
import 'package:mobirural/widgets/buildingcard.dart';
import 'package:mobirural/pages/cadastro_predio.dart';
import 'package:provider/provider.dart';

class InicialScreen extends StatefulWidget {
  const InicialScreen({super.key});

  @override
  State<InicialScreen> createState() => _InicialScreenState();
}

class _InicialScreenState extends State<InicialScreen> {
  List<Building>? allBuildings;
  List<Building>? searchBuildings;
  String searchText = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: [
          SystemUiOverlay.top,
        ]);

    searchBuildings = [];
  }

  void _filterBuildings(String searchText) {
    setState(() {
      this.searchText = searchText;
      if (searchText.isEmpty) {
        searchBuildings = allBuildings;
      } else {
        List<Building> filtered = allBuildings
                ?.where((building) => building.name!
                    .toLowerCase()
                    .contains(searchText.toLowerCase()))
                .toList() ??
            [];
        searchBuildings = filtered.isEmpty ? allBuildings : filtered;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget barradebusca = Container(
      margin: const EdgeInsets.all(20.0),
      width: 278,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Buscar',
              ),
              onChanged: (String value) {
                _filterBuildings(value);
              },
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primaryColor,
              ),
              child: const Icon(Icons.mic, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    Widget boasvindas = Consumer<UserModel>(
      builder: (context, userModel, child) {
        return Center(
          child: SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Olá, ${!userModel.isLoggedIn() ? "" : userModel.userData["name"]}',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Estes são os prédios disponíveis:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );

    final buildingService =
        Provider.of<BuildingService>(context, listen: false);

    Widget buildGrid(List<Building> buildings, BuildContext context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 268,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1 / 1.25,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: buildings.length,
          itemBuilder: (context, index) {
            return BuildingCard(building: buildings[index]);
          },
        ),
      );
    }

    Widget colunadupla = FutureBuilder<List<Building>>(
      future: buildingService.getBuildings(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );

          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Center(
                child: Text('Erro ao carregar os dados dos prédios'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Nenhum prédio encontrado'),
              );
            } else {
              allBuildings = snapshot.data;
              List<Building> displayedBuildings =
                  (searchText.isEmpty || searchBuildings!.isEmpty)
                      ? allBuildings!
                      : searchBuildings!;
              return buildGrid(displayedBuildings, context);
            }

          default:
            return const Center(
              child: Text('Nenhum prédio encontrado'),
            );
        }
      },
    );

    Widget botaoFlutuante = Positioned(
      bottom: 85.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateBuilding(),
            ),
          );
        },
        backgroundColor: AppColors.accentColor,
        child: const Icon(
          Icons.add,
          size: 40.0,
          color: Colors.deepOrange,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          ListView(
            children: [
              barradebusca,
              boasvindas,
              colunadupla,
            ],
          ),
          botaoFlutuante,
        ],
      ),
    );
  }
}
