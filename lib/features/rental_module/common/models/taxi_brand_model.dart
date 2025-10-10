class TaxiBrandModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Brands>? brands;

  TaxiBrandModel({this.totalSize, this.limit, this.offset, this.brands});

  TaxiBrandModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['brands'] != null) {
      brands = <Brands>[];
      json['brands'].forEach((v) {
        brands!.add(Brands.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (brands != null) {
      data['vehicles'] = brands!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Brands {
  int? id;
  String? image;
  String? name;
  String? imageFullUrl;

  Brands({this.id, this.image, this.name, this.imageFullUrl});

  Brands.fromJson(Map<String, dynamic> json) {
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