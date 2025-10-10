import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';

class SelectedCarsModel {
  int? totalSize;
  int? limit;
  int? offset;
  double? maxPrice;
  double? minPrice;
  List<VehicleModel>? vehicles;

  SelectedCarsModel({this.totalSize, this.limit, this.offset, this.maxPrice, this.minPrice, this.vehicles});

  SelectedCarsModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit']/* != null ? int.parse(json['limit'].toString()) : null*/;
    offset = json['offset']/* != null ? int.parse(json['offset'].toString()) : null*/;
    maxPrice = json['max_price']?.toDouble();
    minPrice = json['min_price']?.toDouble();
    if (json['vehicles'] != null) {
      vehicles = <VehicleModel>[];
      json['vehicles'].forEach((v) {
        vehicles!.add(VehicleModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['max_price'] = maxPrice;
    data['min_price'] = minPrice;
    if (vehicles != null) {
      data['vehicles'] = vehicles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}