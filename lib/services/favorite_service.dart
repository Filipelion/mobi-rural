import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobirural/models/building_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFavoriteBuilding(String? userId, Building building) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(building.id)
          .set({
        "buildingReference": {
          "id": building.id,
          "name": building.name, 
          "collection": "buildings",
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavoriteBuilding(String userId, String buildingId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(buildingId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isBuildingFavorite(String userId, String buildingId) async {
    if (userId.isNotEmpty && buildingId.isNotEmpty) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(buildingId)
          .get();

      return doc.exists;
    } else {
      return false;
    }
  }

  Future<List<Building>> getFavoriteBuildings(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      List<String> favoriteBuildingIds =
          querySnapshot.docs.map((doc) => doc.id).toList();

      List<Building> favoriteBuildings = [];

      for (String buildingId in favoriteBuildingIds) {
        DocumentSnapshot buildingSnapshot =
            await _firestore.collection('buildings').doc(buildingId).get();

        if (buildingSnapshot.exists) {
          Building building =
              Building.fromMap(buildingSnapshot.data() as Map<String, dynamic>);
          building.id = buildingSnapshot.id;
          favoriteBuildings.add(building);
        }
      }

      return favoriteBuildings;
    } catch (e) {
      rethrow;
    }
  }

  Future<Building?> getBuildingDetails(String? buildingId) async {
    try {
      DocumentSnapshot buildingSnapshot =
          await _firestore.collection('buildings').doc(buildingId).get();

      if (buildingSnapshot.exists) {
        return Building.fromMap(
            buildingSnapshot.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }
}
