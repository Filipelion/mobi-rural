import 'package:flutter/material.dart';
import 'package:mobirural/pages/building_form.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/services/building_service.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/widgets/appbar_edit.dart';
import 'package:provider/provider.dart';

class EditBuilding extends StatelessWidget {
  final Building building;

  const EditBuilding({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
    const Widget appbaredit = AppBarEdit(titleName: 'Editar prédio');

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: appbaredit,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: BuildingForm(
            building: building,
            onSave: (updatedBuilding, iconImage, buildingImage) async {
              try {
                await Provider.of<BuildingService>(context, listen: false)
                    .updateBuilding(updatedBuilding, iconImage, buildingImage);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Prédio atualizado com sucesso!')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao atualizar o prédio: $e')),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
