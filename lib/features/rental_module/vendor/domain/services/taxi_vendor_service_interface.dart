import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_provider_review_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_banner_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_vehicle_category_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_vehicles_model.dart';

abstract class TaxiVendorServiceInterface {
  Future<TaxiVendorModel?> getTaxiVendorDetails({required int id});
  Future<List<VendorBannerModel>?> getVendorBannerList({required int id});
  Future<VendorVehiclesModel?> getVendorVehicleList({required int offset, required int providerId, int? categoryId, String? searchName, double? minPrice, double? maxPrice, List<int>? brandIds, List<String>? seatingCapacity,
    bool? airCondition, bool? nonAirCondition});
  Future<VendorVehicleCategoryModel?> getVendorVehicleCategoryList();
  Future<TaxiProviderReviewModel?> getTaxiProviderReviewDetails({int? offset, required int id});
// Future<SelectedCarsModel?> getVehicleSearchItemList({required int offset, String? searchText, required int? providerId});
}
