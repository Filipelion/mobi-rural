import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobirural/models/building_model.dart';
import 'package:mobirural/services/storage_service.dart';

class BuildingService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  Future<List<Building>> getBuildings() async {
    List<Building> buildings = [];

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('buildings').get();

      for (var doc in querySnapshot.docs) {
        Building building = Building.fromSnapshot(doc);
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
          Building building = Building.fromSnapshot(doc);
          buildings.add(building);
        }
      }
      return buildings;
    } catch (e) {
      debugPrint("Error fetching buildings by ids: $e");
      rethrow;
    }
  }

  Future<void> createBuilding(
      Building building, File? iconImage, File? buildingImage) async {
    try {
      String? iconUrl;
      String? buildingUrl;

      if (iconImage != null) {
        iconUrl = await _storageService.uploadImageToStorage(iconImage);
      }

      if (buildingImage != null) {
        buildingUrl = await _storageService.uploadImageToStorage(buildingImage);
      }
      await _firestore.collection('buildings').add({
        'accessRamps': building.accessRamps,
        'adaptedBathroom': building.adaptedBathroom,
        'coordinates': building.coordinates,
        'elevator': building.elevator,
        'floor': building.floor,
        'icon': iconUrl,
        'name': building.name,
        'parking': building.parking,
        'image': buildingUrl,
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Error creating building: $e");
      rethrow;
    }
  }

  Future<void> updateBuilding(
      Building building, File? iconImage, File? buildingImage) async {
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
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating building: $e");
      rethrow;
    }
  }

  Future<void> deleteBuilding(String buildingId) async {
    try {
      await _firestore.collection('buildings').doc(buildingId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting building: $e");
      rethrow;
    }
  }
}
