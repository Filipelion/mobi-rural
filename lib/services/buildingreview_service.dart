import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/models/buildingreview_model.dart';

class BuildingReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Building building = Building();

  Future<void> addReview(BuildingReview review) async {
    try {
      await _firestore.collection('buildingReviews').add(review.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasUserReviewedBuilding(
      String userId, String? buildingId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('buildingReviews')
          .where('userId', isEqualTo: userId)
          .where('buildingId', isEqualTo: buildingId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getAverageRatingForBuilding(String buildingId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('buildingReviews')
          .where('buildingId', isEqualTo: buildingId)
          .get();

      List<int?> ratings = querySnapshot.docs
          .map((doc) =>
              BuildingReview.fromMap(doc.data() as Map<String, dynamic>, doc.id)
                  .rating)
          .toList();

      if (ratings.isNotEmpty) {
        double averageRating = ratings.reduce((a, b) => a! + b!)! / ratings.length;
        return double.parse(
            averageRating.toStringAsFixed(1));
      } else {
        return 0.0;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BuildingReview>> getReviewsForUser(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('buildingReviews')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => BuildingReview.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BuildingReview>> getReviewsForBuilding(String buildingId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('buildingReviews')
          .where('buildingId', isEqualTo: buildingId)
          .get();

      return querySnapshot.docs
          .map((doc) => BuildingReview.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateReview(BuildingReview review) async {
    try {
      await _firestore
          .collection('buildingReviews')
          .doc(review.id)
          .update(review.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(BuildingReview review) async {
    try {
      await _firestore.collection('buildingReviews').doc(review.id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
