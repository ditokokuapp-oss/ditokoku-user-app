import 'dart:convert';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/api/local_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_brand_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/popular_car_suggestion_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/selected_cars_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/taxi_banner_model.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_coupon_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/top_rated_cars_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_category_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/repositories/taxi_home_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class TaxiHomeRepository implements TaxiHomeRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  TaxiHomeRepository({required this.sharedPreferences, required this.apiClient});

  @override
  Future<TopRatedCarsModel?> getTopRatedCarList(int offset, {required DataSourceEnum source}) async {
    TopRatedCarsModel? carsModel;
    String cacheId = '${AppConstants.getTopRatedCarsUri}?offset=$offset&limit=10';

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.getTopRatedCarsUri}?offset=$offset&limit=10');
        if (response.statusCode == 200) {

          carsModel = TopRatedCarsModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }

      case DataSourceEnum.local:

        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          carsModel = TopRatedCarsModel.fromJson(jsonDecode(cacheResponseData));
        }

    }
    return carsModel;
  }

  @override
  Future<TaxiBannerModel?> getTaxiBannerList({DataSourceEnum source = DataSourceEnum.local}) async {
    TaxiBannerModel? taxiBannerModel;
    String cacheId = AppConstants.getTaxiBannerUri;

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.getTaxiBannerUri);
        if (response.statusCode == 200) {

          taxiBannerModel = TaxiBannerModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }

      case DataSourceEnum.local:

        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          taxiBannerModel = TaxiBannerModel.fromJson(jsonDecode(cacheResponseData));
        }

    }
    return taxiBannerModel;
  }

  @override
  Future<List<TaxiCouponModel>?> getTaxiCouponList({DataSourceEnum source = DataSourceEnum.local}) async {
    List<TaxiCouponModel>? coupons;
    String cacheId = AppConstants.getTaxiCouponUri;

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.getTaxiCouponUri);
        if (response.statusCode == 200) {
          coupons = [];
          response.body.forEach((v) {
            coupons!.add(TaxiCouponModel.fromJson(v));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }

      case DataSourceEnum.local:

        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          coupons = [];
          jsonDecode(cacheResponseData).forEach((v) {
            coupons!.add(TaxiCouponModel.fromJson(v));
          });
        }

    }
    return coupons;
  }

  @override
  Future<VehicleModel?> getVehicleDetails({required int id}) async {
    VehicleModel? vehicleDetailsModel;

    Response response = await apiClient.getData('${AppConstants.getVehicleDetailsUri}/$id');
    if (response.statusCode == 200) {
      vehicleDetailsModel = VehicleModel.fromJson(response.body);
    }
    return vehicleDetailsModel;
  }

  @override
  Future<SelectedCarsModel?> getSelectedCars({required int offset, String? name, String? tripType,
    double? minPrice, double? maxPrice, List<int>? brandIds, List<String>? seatingCapacity,
    bool? airCondition, bool? nonAirCondition, List<int>? categoryIds, required String pickupTime,
    required LatLng pickupLocation}) async {

    SelectedCarsModel? selectedCarsModel;
    Map<String, String> pl = {
      'lat': pickupLocation.latitude.toString(),
      'lng': pickupLocation.longitude.toString(),
    };
    Response response = await apiClient.getData('${AppConstants.getSelectVehiclesUri}?name=${name??''}&offset=$offset&limit=10'
        '&trip_type=$tripType&min_price=$minPrice&max_price=$maxPrice&brand_ids=$brandIds&seating_capacity=$seatingCapacity'
        '&air_condition=${airCondition! ? 'true' : ''}&no_air_condition=${nonAirCondition! ? 'true' : ''}&category_ids=$categoryIds'
        '&date=$pickupTime&pickup_location=${jsonEncode(pl)}');
    if (response.statusCode == 200) {
      selectedCarsModel = SelectedCarsModel.fromJson(response.body);
    }
    return selectedCarsModel;
  }

  @override
  Future<List<String>?> getSearchSuggestions({required String? name}) async {
    List<String>? vehicles;

    Response response = await apiClient.getData('${AppConstants.getSearchVehicleSuggestionUri}?name=$name');
    if (response.statusCode == 200) {
      vehicles = [];
      response.body.forEach((v) {
        vehicles!.add(v);
      });
    }

    return vehicles;
  }

  @override
  Future<VehicleCategoryModel?> getVehicleCategories({required int offset}) async {
    VehicleCategoryModel? vehicleCategoryModel;

    Response response = await apiClient.getData('${AppConstants.getVehicleCategoriesUri}?offset=$offset&limit=25');
    if (response.statusCode == 200) {
      vehicleCategoryModel = VehicleCategoryModel.fromJson(response.body);
    }
    return vehicleCategoryModel;
  }

  @override
  Future<TaxiBrandModel?> getTaxiBrandList(int offset) async {
    TaxiBrandModel? taxiBrandModel;

    Response response = await apiClient.getData('${AppConstants.getTaxiBrandListUri}?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      taxiBrandModel = TaxiBrandModel.fromJson(response.body);
    }
    return taxiBrandModel;
  }

  @override
  Future<List<PopularCarSuggestionModel>?> getPopularSearchList() async {
    List<PopularCarSuggestionModel>? popularCarSearchModel;

    Response response = await apiClient.getData(AppConstants.getPopularTaxiSuggestionUri);
    if (response.statusCode == 200) {
      popularCarSearchModel = [];
      response.body.forEach((vehicle) {
        popularCarSearchModel!.add(PopularCarSuggestionModel.fromJson(vehicle));
      });
    }
    return popularCarSearchModel;
  }

  @override
  Future<bool> saveSearchHistory(List<String> searchHistories) async {
    return await sharedPreferences.setStringList(AppConstants.taxiSearchHistory, searchHistories);
  }

  @override
  List<String> getSearchHistory() {
    return sharedPreferences.getStringList(AppConstants.taxiSearchHistory) ?? [];
  }

  @override
  Future<bool> clearSearchHistory() async {
    return sharedPreferences.setStringList(AppConstants.taxiSearchHistory, []);
  }

  // @override
  // Future<TripModel?> getHistoryTripList({required int offset, required String type}) async {
  //   TripModel? tripModel;
  //
  //   Response response = await apiClient.getData('${AppConstants.tripListUri}/$type?offset=$offset&limit=10');
  //   if (response.statusCode == 200) {
  //     tripModel = TripModel.fromJson(response.body);
  //   }
  //   return tripModel;
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