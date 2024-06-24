import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/obstacle_model.dart';
import 'package:mobirural/services/obstacle_service.dart';
import 'package:mobirural/widgets/appbar_edit.dart';
import 'package:provider/provider.dart';

class EditObstacleScreen extends StatefulWidget {
  final ObstacleModel obstacle;

  const EditObstacleScreen({super.key, required this.obstacle});

  @override
  State<EditObstacleScreen> createState() => _EditObstacleScreenState();
}

class _EditObstacleScreenState extends State<EditObstacleScreen> {
  final Widget _appbaredit = const AppBarEdit(titleName: 'Editar Sinalização');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  int _difficulty = 0;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.obstacle.title ?? '';
    _detailsController.text = widget.obstacle.details ?? '';
    _difficulty = widget.obstacle.difficulty ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: _appbaredit,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor)),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _detailsController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Detalhes',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor)),
                ),
              ),
              const SizedBox(height: 16.0),
              Text('Dificuldade: $_difficulty'),
              Slider(
                value: _difficulty.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                inactiveColor: AppColors.backgroundColor,
                activeColor: AppColors.primaryColor,
                label: _difficulty.toString(),
                onChanged: (value) {
                  setState(() {
                    _difficulty = value.round();
                  });
                },
              ),
              const SizedBox(height: 40.0),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _saveChanges();
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
                      'Salvar Alterações',
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
      ),
    );
  }

  Future<void> _saveChanges() async {
    final updatedObstacle = widget.obstacle.copyWith(
      title: _titleController.text,
      details: _detailsController.text,
      difficulty: _difficulty,
    );

    await Provider.of<ObstacleService>(context, listen: false)
        .updateObstacle(updatedObstacle);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}
