import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobirural/models/building_model.dart';

class BuildingService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Building>> getBuildings() async {
    List<Building> buildings = [];

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('buildings').get();

      for (var doc in querySnapshot.docs) {
        Building building =
            Building.fromMap(doc.data() as Map<String, dynamic>?);
        building.id = doc.id;
        buildings.add(building);
      }

      return buildings;
    } catch (e) {
      debugPrint("Error fetching buildings: $e");
      return [];
    }
  }

  Future<List<Building>> getBuildingsByIds(List<String> buildingIds) async {
    try {
      List<Building> buildings = [];
      for (String id in buildingIds) {
        DocumentSnapshot doc =
            await _firestore.collection('buildings').doc(id).get();
        if (doc.exists) {
          buildings.add(Building.fromMap(doc.data() as Map<String, dynamic>?));
        }
      }
      return buildings;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createBuilding(Building building) async {
    try {
      await _firestore.collection('buildings').add({
        'access_ramps': building.accessRamps,
        'adapted_bathroom': building.adaptedBathroom,
        'coordinates': building.coordinates,
        'elevator': building.elevator,
        'floor': building.floor,
        'icon': building.icon,
        'name': building.name,
        'parking': building.parking,
        'image': building.image,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBuilding(Building building) async {
    try {
      await _firestore.collection('buildings').doc(building.id).update({
        'accessRamps': building.accessRamps,
        'adaptedBathroom': building.adaptedBathroom,
        'coordinates': building.coordinates,
        'elevator': building.elevator,
        'floor': building.floor,
        'icon': building.icon,
        'name': building.name,
        'parking': building.parking,
        'image': building.image,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBuilding(String buildingId) async {
    try {
      await _firestore.collection('buildings').doc(buildingId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
