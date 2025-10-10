class PopularCarSuggestionModel {
  int? id;
  String? name;
  String? vehiclesSumTotalTrip;
  String? imageFullUrl;

  PopularCarSuggestionModel(
      {this.id,
        this.name,
        this.vehiclesSumTotalTrip,
        this.imageFullUrl,
      });

  PopularCarSuggestionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    vehiclesSumTotalTrip = json['vehicles_sum_total_trip'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['vehicles_sum_total_trip'] = vehiclesSumTotalTrip;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}