import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/widgets/appbar_edit.dart';

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
  // final _icon = TextEditingController(); TODO: procurar entrada correta
  // final _coordinates = TextEditingController(); TODO: procurar entrada correta
  // final _image = TextEditingController(); TODO: procurar entrada correta

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? dropdownValue = 'Não';

  @override
  Widget build(BuildContext context) {
    Widget teste = const Center(
      child: Text('Adição de Predio'),
    );

    Widget formPredio = SizedBox(
      child: Form(
        key: _formKey,
        child: SizedBox(
          height: 350,
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
            ],
          ),
        ),
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
        child: ListView(
          children: [
            const SizedBox(height: 20),
            formPredio,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
}
