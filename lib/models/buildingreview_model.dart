class BuildingReview {
  String? id;
  String? userId;
  String? userName;
  String? buildingId;
  String? buildingName;
  int? rating;
  String? reviewText;

  BuildingReview({
    this.id,
    required this.userId,
    required this.userName,
    required this.buildingId,
    required this.buildingName,
    required this.rating,
    required this.reviewText,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'buildingId': buildingId,
      'buildingName': buildingName,
      'rating': rating,
      'reviewText': reviewText,
    };
  }

  BuildingReview copyWith({
    String? id,
    String? userId,
    String? userName,
    String? buildingId,
    String? buildingName,
    int? rating,
    String? reviewText,
  }) {
    return BuildingReview(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      buildingId: buildingId ?? this.buildingId,
      buildingName: buildingName ?? this.buildingName,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
    );
  }

  factory BuildingReview.fromMap(Map<String, dynamic> data, String id) {
    return BuildingReview(
      id: id,
      userId: data['userId'],
      userName: data['userName'],
      buildingId: data['buildingId'],
      buildingName: data['buildingName'],
      rating: data['rating'],
      reviewText: data['reviewText'],
    );
  }
}
