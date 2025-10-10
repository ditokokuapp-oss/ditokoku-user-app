import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_provider_review_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_banner_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_vehicle_category_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_vehicles_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/repositories/taxi_vendor_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class TaxiVendorRepository implements TaxiVendorRepositoryInterface {
  final ApiClient apiClient;

  TaxiVendorRepository({required this.apiClient});

  @override
  Future<TaxiVendorModel?> getTaxiVendorDetails({required int id}) async{
    TaxiVendorModel? taxiVendorModel;
    Response response = await apiClient.getData('${AppConstants.getProviderDetailsUri}/$id');
    if (response.statusCode == 200) {
      taxiVendorModel = TaxiVendorModel.fromJson(response.body);
    }
    return taxiVendorModel;
  }

  @override
  Future<List<VendorBannerModel>?> getVendorBannerList({required int id}) async{
    List<VendorBannerModel>? taxiBannerModel;
    Response response = await apiClient.getData('${AppConstants.getProviderBannerUri}/$id');
    if (response.statusCode == 200 && response.body != null && response.body.isNotEmpty) {
      taxiBannerModel = [];
      response.body.forEach((banner) {
        taxiBannerModel!.add(VendorBannerModel.fromJson(banner));
      });
    }
    return taxiBannerModel;
  }

  @override
  Future<VendorVehiclesModel?> getVendorVehicleList({required int offset, required int providerId, int? categoryId,
    String? searchName, double? minPrice, double? maxPrice, List<int>? brandIds, List<String>? seatingCapacity,
    bool? airCondition, bool? nonAirCondition}) async{

    VendorVehiclesModel? vendorVehiclesModel;

    Response response = await apiClient.getData('${AppConstants.getProviderVehicleListUri}?offset=$offset&limit=25&provider_id=$providerId${(categoryId == -1 || categoryId == null) ? '' : '&category_ids=[$categoryId]'}&name=${searchName??''}'
        '&min_price=$minPrice&max_price=$maxPrice&brand_ids=$brandIds&seating_capacity=$seatingCapacity&air_condition=${airCondition! ? 'true' : ''}&no_air_condition=${nonAirCondition! ? 'true' : ''}');
    if (response.statusCode == 200) {
      vendorVehiclesModel = VendorVehiclesModel.fromJson(response.body);
    }
    return vendorVehiclesModel;
  }

  @override
  Future<VendorVehicleCategoryModel?> getVendorVehicleCategoryList() async{
    VendorVehicleCategoryModel? vendorVehicleCategoryModel;

    Response response = await apiClient.getData(AppConstants.getProviderVehicleCategoryListUri);
    if (response.statusCode == 200) {
      vendorVehicleCategoryModel = VendorVehicleCategoryModel.fromJson(response.body);
    }
    return vendorVehicleCategoryModel;
  }

  @override
  Future<TaxiProviderReviewModel?> getTaxiProviderReviewDetails({int? offset, required int id}) async{
    TaxiProviderReviewModel? providerReviewDetails;
    Response response = await apiClient.getData('${AppConstants.getTaxiProviderReviewUri}/$id');
    if (response.statusCode == 200) {
      providerReviewDetails = TaxiProviderReviewModel.fromJson(response.body);
    }
    return providerReviewDetails;
  }

  // @override
  // Future<SelectedCarsModel?> getVehicleSearchItemList({required int offset, String? searchText, int? providerId}) async{
  //   SelectedCarsModel? selectedVendorVehicleModel;
  //
  //   Response response = await apiClient.getData('${AppConstants.getSelectVehiclesUri}?name=$searchText&provider_id=$providerId&offset=$offset&limit=10');
  //   if (response.statusCode == 200) {
  //     selectedVendorVehicleModel = SelectedCarsModel.fromJson(response.body);
  //   }
  //   return selectedVendorVehicleModel;
  // }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    // TODO: implement update
    throw UnimplementedError();
  }


}