import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobirural/models/buildingreview_model.dart';

class Building {
  String? id;
  final String? accessRamps;
  final String? adaptedBathroom;
  final GeoPoint? coordinates;
  final String? elevator;
  final String? floor;
  final String? icon;
  final String? name;
  final String? parking;
  final String? image;

  Building({
    this.id,
    this.accessRamps,
    this.adaptedBathroom,
    this.coordinates,
    this.elevator,
    this.floor,
    this.icon,
    this.name,
    this.parking,
    this.image,
  });

  factory Building.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return Building();
    }
    return Building(
      accessRamps: data['accessRamps'],
      adaptedBathroom: data['adaptedBathroom'],
      coordinates: data['coordinates'],
      elevator: data['elevator'],
      floor: data['floor'],
      icon: data['icon'],
      name: data['name'],
      parking: data['parking'],
      image: data['image'],
    );
  }

  List<BuildingReview> reviews = [];

  Map<String, dynamic> toMap() {
    return {
      'access_ramps': accessRamps,
      'adapted_bathroom': adaptedBathroom,
      'coordinates': coordinates,
      'elevator': elevator,
      'floor': floor,
      'icon': icon,
      'name': name,
      'parking': parking,
      'image': image,
      'reviews': reviews.map((review) => review.toMap()).toList(),
    };
  }

  void addReview(BuildingReview review) {
    reviews.add(review);
  }
}

