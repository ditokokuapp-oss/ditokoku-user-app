class VehicleCategoryModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Vehicles>? vehicles;

  VehicleCategoryModel({this.totalSize, this.limit, this.offset, this.vehicles});

  VehicleCategoryModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'] != null ? int.parse(json['limit'].toString()) : null;
    offset = json['offset'] != null ? int.parse(json['offset'].toString()) : null;
    if (json['vehicles'] != null) {
      vehicles = <Vehicles>[];
      json['vehicles'].forEach((v) {
        vehicles!.add(Vehicles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (vehicles != null) {
      data['vehicles'] = vehicles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Vehicles {
  int? id;
  String? image;
  String? name;
  String? imageFullUrl;

  Vehicles({this.id, this.image, this.name, this.imageFullUrl});

  Vehicles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}