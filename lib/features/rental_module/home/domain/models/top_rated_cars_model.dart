import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';

class TopRatedCarsModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<VehicleModel>? vehicles;

  TopRatedCarsModel({this.totalSize, this.limit, this.offset, this.vehicles});

  TopRatedCarsModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'] != null ? int.parse(json['limit'].toString()) : null;
    offset = json['offset'] != null ? int.parse(json['offset'].toString()) : null;
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
    if (vehicles != null) {
      data['vehicles'] = vehicles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}