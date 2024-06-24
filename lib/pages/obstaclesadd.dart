import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/user_model.dart';
import 'package:mobirural/models/obstacle_model.dart';
import 'package:mobirural/services/obstacle_service.dart';
import 'package:mobirural/utils/user_current_local.dart';
import 'package:mobirural/widgets/appbar_edit.dart';
import 'package:provider/provider.dart';

class AddObstacleScreen extends StatefulWidget {
  const AddObstacleScreen({super.key});

  @override
  State<AddObstacleScreen> createState() => _AddObstacleScreenState();
}

class _AddObstacleScreenState extends State<AddObstacleScreen> {
  final Widget _appbaredit =
      const AppBarEdit(titleName: 'Adicionar Sinalização');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  int? _difficulty;
  Position? _userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    Position? position = await getCurrentLocation();
    setState(() {
      _userLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: _appbaredit,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _detailsController,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Detalhes'),
            ),
            DropdownButton<int>(
              value: _difficulty,
              onChanged: (value) {
                setState(() {
                  _difficulty = value;
                });
              },
              items: List.generate(
                6,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text('Dificuldade: $index'),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_userLocation != null) {
                      String? userId = userModel.getId();
                      String userName = userModel.userData['name'];
                      String title = _titleController.text;
                      String details = _detailsController.text;

                      if (userId != null &&
                          title.isNotEmpty &&
                          details.isNotEmpty &&
                          _difficulty != null) {
                        ObstacleModel obstacle = ObstacleModel(
                          userId: userId,
                          userName: userName,
                          coordinates: GeoPoint(_userLocation!.latitude,
                              _userLocation!.longitude),
                          title: title,
                          details: details,
                          difficulty: _difficulty!,
                        );

                        await ObstacleService().createObstacle(obstacle);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      AppColors.primaryColor,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(vertical: 10.0),
                    ),
                  ),
                  child: const Text(
                    'Salvar Sinalização',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}