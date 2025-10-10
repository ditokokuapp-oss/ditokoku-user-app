import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_provider_review_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_banner_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_vehicle_category_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_vehicles_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/repositories/taxi_vendor_repository_interface.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/services/taxi_vendor_service_interface.dart';

class TaxiVendorService implements TaxiVendorServiceInterface {
  final TaxiVendorRepositoryInterface taxiVendorRepositoryInterface;

  TaxiVendorService({required this.taxiVendorRepositoryInterface});

  @override
  Future<TaxiVendorModel?> getTaxiVendorDetails({required int id}) async{
    return await taxiVendorRepositoryInterface.getTaxiVendorDetails(id: id);

  }

  @override
  Future<List<VendorBannerModel>?> getVendorBannerList({required int id}) async{
    return await taxiVendorRepositoryInterface.getVendorBannerList(id: id);

  }

  @override
  Future<VendorVehiclesModel?> getVendorVehicleList({
    required int offset, required int providerId, int? categoryId, String? searchName,
    double? minPrice, double? maxPrice, List<int>? brandIds, List<String>? seatingCapacity,
    bool? airCondition, bool? nonAirCondition}) async{
    return await taxiVendorRepositoryInterface.getVendorVehicleList(
        offset: offset, providerId: providerId, categoryId: categoryId, searchName: searchName,
      minPrice: minPrice, maxPrice: maxPrice, brandIds: brandIds, seatingCapacity: seatingCapacity,
      airCondition: airCondition, nonAirCondition: nonAirCondition,
    );
  }

  @override
  Future<VendorVehicleCategoryModel?> getVendorVehicleCategoryList() async{
    return await taxiVendorRepositoryInterface.getVendorVehicleCategoryList();
  }

  @override
  Future<TaxiProviderReviewModel?> getTaxiProviderReviewDetails({int? offset, required int id}) async{
    return await taxiVendorRepositoryInterface.getTaxiProviderReviewDetails(id: id);
  }

  // @override
  // Future<SelectedCarsModel?> getVehicleSearchItemList({required int offset, String? searchText, required int? providerId}) async{
  //   return await taxiVendorRepositoryInterface.getVehicleSearchItemList(offset: offset, searchText: searchText, providerId: providerId);
  // }
}
