// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/buildingreview_model.dart';
import 'package:mobirural/services/buildingreview_service.dart';
import 'package:mobirural/widgets/appbar_edit.dart';

class UpdateReviewScreen extends StatefulWidget {
  final BuildingReview review;

  const UpdateReviewScreen({super.key, required this.review});

  @override
  State<UpdateReviewScreen> createState() => _UpdateReviewScreenState();
}

class _UpdateReviewScreenState extends State<UpdateReviewScreen> {
  final Widget _appbaredit = const AppBarEdit(titleName: 'Atualizar Avaliação');
  final TextEditingController _reviewTextController = TextEditingController();
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.review.rating ?? 0;
    _reviewTextController.text = widget.review.reviewText ?? '';
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
              Center(
                child: Text(widget.review.buildingName ?? '',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              const SizedBox(height: 16.0),
              Text('Pontuação: $_rating'),
              Slider(
                value: _rating.toDouble(),
                min: 0,
                max: 5,
                inactiveColor: AppColors.backgroundColor,
                activeColor: AppColors.primaryColor,
                divisions: 5,
                label: _rating.toString(),
                onChanged: (value) {
                  setState(() {
                    _rating = value.round();
                  });
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Texto da Avaliação:'),
              TextField(
                  controller: _reviewTextController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  )),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _updateReview(context);
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

  Future<void> _updateReview(BuildContext context) async {
    try {
      int rating = int.parse(_rating.toString());
      String reviewText = _reviewTextController.text;

      BuildingReview updatedReview = widget.review.copyWith(
        rating: rating,
        reviewText: reviewText,
      );

      await BuildingReviewService().updateReview(updatedReview);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar avaliação. Tente novamente.'),
        ),
      );
    }
  }
}
