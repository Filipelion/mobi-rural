import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/models/buildingreview_model.dart';
import 'package:mobirural/services/buildingreview_service.dart';
import 'package:mobirural/widgets/appbar_edit.dart';

class ReviewsForBuildingScreen extends StatefulWidget {
  final Building building;

  const ReviewsForBuildingScreen({super.key, required this.building});

  @override
  State<ReviewsForBuildingScreen> createState() => _ReviewsForBuildingScreenState();
}

class _ReviewsForBuildingScreenState extends State<ReviewsForBuildingScreen> {
  late Future<List<BuildingReview>> _reviewsFuture;
  late AppBarEdit _appbaredit;


  String _getname() {
    return 'Avaliações para ${widget.building.name}';
  }

  @override
  void initState() {
    super.initState();
    _appbaredit = AppBarEdit(titleName: _getname());
    _reviewsFuture = BuildingReviewService().getReviewsForBuilding(widget.building.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: _appbaredit,
      ),
      body: FutureBuilder<List<BuildingReview>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar avaliações: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Não há avaliações para este prédio.'),
            );
          } else {
            List<BuildingReview> reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                BuildingReview review = reviews[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('${review.userName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pontuação: ${review.rating}'),
                        Text('Avaliação: ${review.reviewText}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
