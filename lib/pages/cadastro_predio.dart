import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/services/building_service.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/widgets/appbar_edit.dart';
import 'package:provider/provider.dart';

class CreateBuilding extends StatefulWidget {
  const CreateBuilding({super.key});

  @override
  State<CreateBuilding> createState() => _CreateBuildingState();
}

class _CreateBuildingState extends State<CreateBuilding> {
  final Widget _appbaredit = const AppBarEdit(titleName: 'Cadastrar prédio');
  final _nameBuilding = TextEditingController();
  final _disabilityParking = TextEditingController(text: 'Não');
  final _accessRamps = TextEditingController(text: 'Não');
  final _elevator = TextEditingController(text: 'Não');
  final _floor = TextEditingController(text: 'Não');
  final _adaptedBathroom = TextEditingController(text: 'Não');

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? dropdownValue = 'Não';
  File? _iconImage;
  File? _buildingImage;

  static final GeoPoint? _coordinates = GeoPoint(0.0, 0.0);

  @override
  Widget build(BuildContext context) {
    Widget formPredio = Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Adicione um novo prédio',
            style: TextStyle(fontSize: 22),
          ),
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
                return 'Campo obrigatório';
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
          saveBuilding(),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: _appbaredit,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: formPredio,
        ),
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

  Widget saveBuilding() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              Building building = Building(
                name: _nameBuilding.text,
                parking: _disabilityParking.text,
                accessRamps: _accessRamps.text,
                elevator: _elevator.text,
                floor: _floor.text,
                adaptedBathroom: _adaptedBathroom.text,
                icon: _iconImage?.path ?? '',
                image: _buildingImage?.path ?? '',
                coordinates:
                    _coordinates, // Adicione as coordenadas aqui, se necessário
              );

              try {
                await Provider.of<BuildingService>(context, listen: false)
                    .createBuilding(building, _iconImage, _buildingImage);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prédio criado com sucesso!')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao criar o prédio: $e')),
                  );
                }
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
        ),
      ),
    );
  }
}
