import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/user_model.dart';
import 'package:mobirural/pages/configuracoes.dart';
import 'package:mobirural/pages/perfil_edit.dart';
import 'package:provider/provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  Widget build(BuildContext context) {
    Widget perfil = const SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Meu Perfil",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          )
        ],
      ),
    );

    Widget meuPerfil = Stack(
      alignment: Alignment.topCenter,
      children: [
        const Positioned(
          left: 16.0,
          top: -4.0,
          child: Text(
            'Detalhes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),
        Positioned(
          right: 16.0,
          top: -4.0,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const EditPerfil()));
            },
            child: const Text(
              'Editar',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<UserModel>(
                builder: (context, userModel, _) {
                  if (userModel.isLoggedIn()) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${userModel.userData["name"]}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '${userModel.firebaseUser!.email}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    );
                  } else {
                    return const Text('Usuário não logado');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );

    Widget configuracoes = Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Colors.transparent),
          ),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ConfiguracoesPage()));
        },
        child: const Text(
          "Configurações",
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );

    Widget exitButton = Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            UserModel userModel =
                Provider.of<UserModel>(context, listen: false);
            userModel.signOut();
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
            'Sair',
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
        backgroundColor: AppColors.backgroundColor,
        body: ListView(
          children: [
            perfil,
            meuPerfil,
            configuracoes,
            exitButton,
          ],
        ));
  }
}
