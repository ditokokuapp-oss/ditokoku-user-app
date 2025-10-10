import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:sixam_mart/features/rental_module/home/domain/services/taxi_home_service_interface.dart';

class TaxiHomeService implements TaxiHomeServiceInterface {
  final TaxiHomeRepositoryInterface taxiHomeRepositoryInterface;
  TaxiHomeService({required this.taxiHomeRepositoryInterface});

  @override
  Future<TopRatedCarsModel?> getTopRatedCarList(int offset, {required DataSourceEnum source}) async {
    return await taxiHomeRepositoryInterface.getTopRatedCarList(offset, source: source);
  }

  @override
  Future<TaxiBannerModel?> getTaxiBannerList({DataSourceEnum source = DataSourceEnum.local}) async {
    return await taxiHomeRepositoryInterface.getTaxiBannerList(source: source);
  }

  @override
  Future<List<TaxiCouponModel>?> getTaxiCouponList({DataSourceEnum source = DataSourceEnum.local}) async {
    return await taxiHomeRepositoryInterface.getTaxiCouponList(source: source);
  }

  @override
  Future<VehicleModel?> getVehicleDetails({required int id}) async {
    return await taxiHomeRepositoryInterface.getVehicleDetails(id: id);
  }

  @override
  Future<VehicleCategoryModel?> getVehicleCategories({required int offset}) async {
    return await taxiHomeRepositoryInterface.getVehicleCategories(offset: offset);
  }

  @override
  Future<SelectedCarsModel?> getSelectedCars({required int offset, String? name, String? tripType,
    double? minPrice, double? maxPrice, List<int>? brandIds, List<String>? seatingCapacity,
    bool? airCondition, bool? nonAirCondition, List<int>? categoryIds, required String pickupTime, required LatLng pickupLocation}) async {

    return await taxiHomeRepositoryInterface.getSelectedCars(name: name, offset: offset, tripType: tripType,
    minPrice: minPrice, maxPrice: maxPrice, brandIds: brandIds, seatingCapacity: seatingCapacity,
    airCondition: airCondition, nonAirCondition: nonAirCondition, categoryIds: categoryIds, pickupTime: pickupTime, pickupLocation: pickupLocation);
  }

  @override
  Future<List<String>?> getSearchSuggestions({required String? name}) async {
    return await taxiHomeRepositoryInterface.getSearchSuggestions(name: name);
  }

  @override
  Future<bool> saveSearchHistory(List<String> searchHistories) async {
    return await taxiHomeRepositoryInterface.saveSearchHistory(searchHistories);
  }

  @override
  List<String> getSearchHistory() {
    return taxiHomeRepositoryInterface.getSearchHistory();
  }

  @override
  Future<bool> clearSearchHistory() async {
    return await taxiHomeRepositoryInterface.clearSearchHistory();
  }

  @override
  Future<TaxiBrandModel?> getTaxiBrandList(int offset) async {
    return await taxiHomeRepositoryInterface.getTaxiBrandList(offset);
  }

  @override
  Future<List<PopularCarSuggestionModel>?> getPopularSearchList() async {
    return await taxiHomeRepositoryInterface.getPopularSearchList();
  }

  // @override
  // Future<TripModel?> getHistoryTripList({required int offset, required String type}) async {
  //   return await taxiHomeRepositoryInterface.getHistoryTripList(offset: offset, type: type);
  // }
}