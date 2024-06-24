// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';
import 'package:mobirural/models/buildingreview_model.dart';
import 'package:mobirural/pages/reviewupdate.dart';
import 'package:mobirural/services/buildingreview_service.dart';
import 'package:mobirural/widgets/appbar_edit.dart';

class UserReviewsScreen extends StatefulWidget {
  final String? userId;

  const UserReviewsScreen({super.key, required this.userId});

  @override
  State<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  late List<BuildingReview> _userReviews;
  List<BuildingReview> reviews = [];
  final Widget _appbaredit = const AppBarEdit(titleName: 'Minhas Avaliações');

  @override
  void initState() {
    super.initState();
    _userReviews = [];
    _loadUserReviews();
  }

  Future<void> _loadUserReviews() async {
    try {
      List<BuildingReview> reviews =
          await BuildingReviewService().getReviewsForUser(widget.userId!);
      setState(() {
        _userReviews = reviews;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao carregar avaliações do usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: _appbaredit,
      ),
      // ignore: unnecessary_null_comparison
      body: _userReviews != null
          ? _buildReviewList()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildReviewList() {
    return ListView.builder(
      itemCount: _userReviews.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UpdateReviewScreen(review: _userReviews[index]),
                  ),
                );
              },
              child: Dismissible(
                key: Key(_userReviews[index].id!),
                onDismissed: (direction) {
                  _deleteReview(context, index);
                },
                background: Container(
                  color: AppColors.primaryColor,
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.black,
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(_userReviews[index].buildingName ?? ''),
                  subtitle:
                      Text(_userReviews[index].reviewText ?? 'Sem comentário'),
                  trailing: Text('Pontuação: ${_userReviews[index].rating}'),
                ),
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Future<void> _deleteReview(BuildContext context, int index) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir esta avaliação?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.primaryColor)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  BuildingReview reviewToDelete = _userReviews[index];
                  await BuildingReviewService().deleteReview(reviewToDelete);

                  Navigator.of(context).pop(true); // Confirmou a exclusão
                } catch (e) {
                  Navigator.of(context).pop(false); // Não confirmou a exclusão
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Erro ao excluir avaliação. Tente novamente.'),
                    ),
                  );
                }
              },
              child:
                  const Text('Confirmar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      _removeReview(index);
    }
  }

  void _removeReview(int index) {
    setState(() {
      _userReviews.removeAt(index);
    });
  }
}
