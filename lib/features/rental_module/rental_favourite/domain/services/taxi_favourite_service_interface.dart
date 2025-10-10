import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';

abstract class TaxiFavouriteServiceInterface {
  Future<ResponseModel> addVehicleFavouriteList(int id, bool isProvider);
  Future<ResponseModel> removeVehicleFavouriteList(int? id, bool isProvider);
  Future<Response> getFavouriteTaxiList();
  List<VehicleModel?> wishVehicleList(VehicleModel item);
  List<int?> wishVehicleIdList (VehicleModel item);
  List<TaxiVendorModel?> wishProviderList(dynamic provider);
  List<int?> wishProviderIdList(dynamic store);
}