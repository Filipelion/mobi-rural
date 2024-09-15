import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobirural/utils/user_current_local.dart';

class BuildingForm extends StatefulWidget {
  final Building? building;
  final Future<void> Function(
      Building building, File? iconImage, File? buildingImage) onSave;

  const BuildingForm({super.key, this.building, required this.onSave});

  @override
  _BuildingFormState createState() => _BuildingFormState();
}

class _BuildingFormState extends State<BuildingForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameBuilding;
  late TextEditingController _disabilityParking;
  late TextEditingController _accessRamps;
  late TextEditingController _elevator;
  late TextEditingController _floor;
  late TextEditingController _adaptedBathroom;

  File? _iconImage;
  File? _buildingImage;
  Future<void>? _saveFuture;

  bool _useCurrentLocation = false;
  GeoPoint? _coordinates;

  @override
  void initState() {
    super.initState();

    _nameBuilding = TextEditingController(text: widget.building?.name ?? '');
    _disabilityParking = TextEditingController(
        text: widget.building!.parking?.capitalize() ?? 'Não');
    _accessRamps = TextEditingController(
        text: widget.building!.accessRamps?.capitalize() ?? 'Não');
    _elevator = TextEditingController(
        text: widget.building!.elevator?.capitalize() ?? 'Não');
    _floor = TextEditingController(
        text: widget.building!.floor?.capitalize() ?? 'Não');
    _adaptedBathroom = TextEditingController(
        text: widget.building!.adaptedBathroom?.capitalize() ?? 'Não');

    _coordinates = widget.building?.coordinates ?? const GeoPoint(0.0, 0.0);

    _initializeLocationStatus();
  }

  Future<void> _initializeLocationStatus() async {
    if (widget.building != null && widget.building!.coordinates != null) {
      setState(() {
        _coordinates = widget.building!.coordinates;
      });
    } else {
      Position? position = await getCurrentLocation();
      if (position != null) {
        setState(() {
          _useCurrentLocation = true;
          _coordinates = GeoPoint(position.latitude, position.longitude);
        });
      } else {
        setState(() {
          _useCurrentLocation = false;
          _coordinates = const GeoPoint(0.0, 0.0);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameBuilding,
            decoration: const InputDecoration(
              labelText: 'Nome',
              labelStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Não se esqueça de nomear o prédio!';
              }
              return null;
            },
          ),
          formsOptions('Vagas Especiais', _disabilityParking),
          formsOptions('Rampas de Acesso', _accessRamps),
          formsOptions('Elevadores', _elevator),
          formsOptions('Banheiro Adaptado', _adaptedBathroom),
          formsOptions('Piso Tátil', _floor),
          formsImage('Imagem do ícone', _iconImage, (File? image) {
            setState(() {
              _iconImage = image;
            });
          }),
          formsImage('Imagem do prédio', _buildingImage, (File? image) {
            setState(() {
              _buildingImage = image;
            });
          }),
          _getUserLocationCheckbox(),
          _saveBuildingButton(),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery(void Function(File?) onImagePicked) async {
    try {
      final returnedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (returnedImage != null) {
        setState(() {
          onImagePicked(File(returnedImage.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar a imagem: $e')),
      );
    }
  }

  Row formsOptions(String title, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 40),
        SizedBox(
          child: DropdownButton<String>(
            value: controller.text,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(
              color: Colors.deepPurpleAccent,
              fontSize: 18,
            ),
            onChanged: (String? newValue) {
              setState(() {
                controller.text = newValue!;
              });
            },
            items: <String>['Sim', 'Não']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Row formsImage(
      String title, File? imageFile, void Function(File?) onImagePicked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 10),
        imageFile == null
            ? IconButton(
                icon: const Icon(Icons.image),
                onPressed: () => _pickImageFromGallery(onImagePicked),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    imageFile,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _pickImageFromGallery(onImagePicked),
                    color: Colors.white,
                    iconSize: 30,
                  ),
                ],
              ),
      ],
    );
  }

  Widget _getUserLocationCheckbox() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Checkbox(
            value: _useCurrentLocation,
            onChanged: (bool? value) async {
              setState(() {
                _useCurrentLocation = value ?? false;
              });

              if (_useCurrentLocation) {
                Position? position = await getCurrentLocation();
                if (position != null) {
                  setState(() {
                    _coordinates =
                        GeoPoint(position.latitude, position.longitude);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Localização obtida com sucesso!')),
                  );
                } else {
                  setState(() {
                    _coordinates = const GeoPoint(0.0, 0.0);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Não foi possível obter a localização.')),
                  );
                }
              } else {
                setState(() {
                  _coordinates = const GeoPoint(0.0, 0.0);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('A localização será definida posteriormente')),
                );
              }
            },
          ),
          const Text('Usar minha localização atual'),
        ],
      ),
    );
  }

  Widget _saveBuildingButton() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: FutureBuilder<void>(
              future: _saveFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_validateImages()) {
                          setState(() {
                            _saveFuture = _saveBuilding();
                          });
                        }
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
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                }
              }),
        ));
  }

  Future<void> _saveBuilding() async {
    Building building = Building(
      id: widget.building?.id,
      name: _nameBuilding.text,
      parking: _disabilityParking.text,
      accessRamps: _accessRamps.text,
      elevator: _elevator.text,
      floor: _floor.text,
      adaptedBathroom: _adaptedBathroom.text,
      icon: _iconImage?.path ?? widget.building?.icon ?? '',
      image: _buildingImage?.path ?? widget.building?.image ?? '',
      coordinates: _coordinates,
    );

    try {
      await widget.onSave(building, _iconImage, _buildingImage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar o prédio: $e')),
        );
      }
    }
  }

  bool _validateImages() {
    if (_iconImage == null && widget.building?.icon == null ||
        _buildingImage == null && widget.building?.image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ícone e imagem do prédio são obrigatórios'),
        ),
      );
      return false;
    }

    final validExtensions = ['.jpg', '.png'];
    if (_iconImage != null) {
      final iconExtension = _iconImage?.path.split('.').last.toLowerCase();
      if (!validExtensions.contains('.$iconExtension')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apenas são permitidos arquivos do tipo .JPG e .PNG'),
          ),
        );
        return false;
      }
    }

    if (_buildingImage != null) {
      final buildingExtension =
          _buildingImage?.path.split('.').last.toLowerCase();
      if (!validExtensions.contains('.$buildingExtension')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apenas são permitidos arquivos do tipo .JPG e .PNG'),
          ),
        );
        return false;
      }
    }

    return true;
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
