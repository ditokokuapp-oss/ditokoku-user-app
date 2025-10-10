class VendorVehicleCategoryModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<VehiclesCategory>? vehicles;

  VendorVehicleCategoryModel({this.totalSize, this.limit, this.offset, this.vehicles});

  VendorVehicleCategoryModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['vehicles'] != null) {
      vehicles = <VehiclesCategory>[];
      json['vehicles'].forEach((v) {
        vehicles!.add(VehiclesCategory.fromJson(v));
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

class VehiclesCategory {
  int? id;
  String? image;
  String? name;
  String? imageFullUrl;

  VehiclesCategory({this.id, this.image, this.name, this.imageFullUrl});

  VehiclesCategory.fromJson(Map<String, dynamic> json) {
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
