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

abstract class TaxiHomeServiceInterface {
  Future<TopRatedCarsModel?> getTopRatedCarList(int offset, {required DataSourceEnum source});
  Future<TaxiBannerModel?> getTaxiBannerList({DataSourceEnum source = DataSourceEnum.local});
  Future<List<TaxiCouponModel>?> getTaxiCouponList({DataSourceEnum source = DataSourceEnum.local});
  Future<VehicleModel?> getVehicleDetails({required int id});
  Future<VehicleCategoryModel?> getVehicleCategories({required int offset});
  Future<SelectedCarsModel?> getSelectedCars({required int offset, String? name, String? tripType,
    double? minPrice, double? maxPrice, List<int>? brandIds, List<String>? seatingCapacity,
    bool? airCondition, bool? nonAirCondition, List<int>? categoryIds, required String pickupTime, required LatLng pickupLocation});
  Future<List<String>?> getSearchSuggestions({required String name});
  Future<bool> saveSearchHistory(List<String> searchHistories);
  List<String> getSearchHistory();
  Future<bool> clearSearchHistory();
  Future<TaxiBrandModel?> getTaxiBrandList(int offset);
  Future<List<PopularCarSuggestionModel>?> getPopularSearchList();
  // Future<TripModel?> getHistoryTripList({required int offset, required String type});
}