import 'package:flutter/material.dart';
import 'package:mobirural/pages/building_form.dart';
import 'package:mobirural/services/building_service.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/widgets/appbar_edit.dart';
import 'package:provider/provider.dart';

class CreateBuilding extends StatelessWidget {
  const CreateBuilding({super.key});

  @override
  Widget build(BuildContext context) {
    const Widget appbaredit = AppBarEdit(titleName: 'Cadastrar prédio');

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
            onSave: (building, iconImage, buildingImage) async {
              try {
                await Provider.of<BuildingService>(context, listen: false)
                    .createBuilding(building, iconImage, buildingImage);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prédio criado com sucesso!')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao criar o prédio: $e')),
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
