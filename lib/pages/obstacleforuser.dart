import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/obstacle_model.dart';
import 'package:mobirural/models/user_model.dart';
import 'package:mobirural/pages/obstaclesedit.dart';
import 'package:mobirural/services/obstacle_service.dart';
import 'package:mobirural/widgets/appbar_edit.dart';
import 'package:provider/provider.dart';

class UserObstaclesScreen extends StatefulWidget {
  const UserObstaclesScreen({super.key});

  @override
  State<UserObstaclesScreen> createState() => _UserObstaclesScreenState();
}

class _UserObstaclesScreenState extends State<UserObstaclesScreen> {
  List<ObstacleModel> localObstacles = [];
  final Widget _appbaredit = const AppBarEdit(titleName: 'Minhas Sinalizações');

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: _appbaredit,
      ),
      body: FutureBuilder<List<ObstacleModel>>(
        future: Provider.of<ObstacleService>(context)
            .getUserObstacles(userModel.getId()!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            );
          } else if (snapshot.hasError) {
            return const Text('Erro ao carregar sinalizações de obstáculos.');
          } else {
            final obstacles = snapshot.data;

            if (obstacles == null || obstacles.isEmpty) {
              return const Center(
                child: Text('Nenhum obstáculo adicionado.'),
              );
            }

            localObstacles = obstacles;

            return ListView.builder(
              itemCount: localObstacles.length, // Use a lista local
              itemBuilder: (context, index) {
                final obstacle = localObstacles[index];

                return Column(
                  children: [
                    Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: AppColors.accentColor,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: const Icon(
                          Icons.delete,
                          color: AppColors.textColor,
                        ),
                      ),
                      onDismissed: (direction) {
                        _confirmDelete(context, obstacle, index);
                      },
                      child: ListTile(
                        title: Text(
                          obstacle.title ?? '',
                          selectionColor: AppColors.primaryColor,
                        ),
                        subtitle: Text(obstacle.details ?? ''),
                        trailing: Text('Dificuldade: ${obstacle.difficulty}'),
                        onTap: () {
                          _navigateToEditScreen(context, obstacle);
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, ObstacleModel obstacle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditObstacleScreen(obstacle: obstacle),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ObstacleModel obstacle, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text(
              'Você tem certeza de que deseja excluir esta sinalização?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      await Provider.of<ObstacleService>(context, listen: false)
          .deleteObstacle(obstacle.id!);
    } else {
      setState(() {
        localObstacles.insert(index, obstacle);
      });
    }
  }
}
