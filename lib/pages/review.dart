import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/models/buildingreview_model.dart';
import 'package:mobirural/models/user_model.dart';
import 'package:mobirural/services/buildingreview_service.dart';
import 'package:mobirural/widgets/appbar_edit.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatefulWidget {
  final Building building;

  const ReviewScreen({super.key, required this.building});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final Widget _appbaredit = const AppBarEdit(titleName: 'Adicionar Avaliação');
  int _rating = 0;
  final TextEditingController _reviewTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: _appbaredit,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10.0),
              const Text(
                'Considerando a estrutura do prédio defina:',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              Text(
                'Pontuação: $_rating',
                style: const TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              Slider(
                value: _rating.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                inactiveColor: AppColors.backgroundColor,
                activeColor: AppColors.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _rating = value.round();
                  });
                },
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Faça um comentário baseado na sua vivência no prédio:',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5.0),
              TextField(
                controller: _reviewTextController,
                decoration: const InputDecoration(
                  labelText: 'Comentário (opcional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _submitReview(
                        userModel.getId(),
                        userModel.getUserName(),
                      );
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
                      'Enviar avaliação',
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

  Future<void> _submitReview(userId, userName) async {
  BuildingReview review = BuildingReview(
    userId: userId,
    userName: userName,
    buildingId: widget.building.id,
    buildingName: widget.building.name,
    rating: _rating.toInt(),
    reviewText: _reviewTextController.text,
  );

  try {
    bool hasReviewed = await BuildingReviewService().hasUserReviewedBuilding(userId, widget.building.id);

    if (!hasReviewed) {
      await BuildingReviewService().addReview(review);
      _showSuccessSnackbar();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      _showErrorSnackbar("Você já possui uma avaliação para este prédio, tente editá-la.");
    }
  } catch (e) {
    _showErrorSnackbar("Erro ao enviar avaliação: $e");
  }
}

void _showSuccessSnackbar() {
  const snackBar = SnackBar(
    content: Text('Avaliação enviada com sucesso!'),
    duration: Duration(seconds: 5),
    backgroundColor: AppColors.primaryColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void _showErrorSnackbar(String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 5),
    backgroundColor: Colors.red,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

}
