import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_brand_model.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_model.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/popular_car_suggestion_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/selected_cars_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/taxi_banner_model.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_coupon_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/top_rated_cars_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_category_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/services/taxi_home_service_interface.dart';
import 'package:sixam_mart/helper/date_converter.dart';

class TaxiHomeController extends GetxController implements GetxService {
  final TaxiHomeServiceInterface taxiHomeServiceInterface;

  TaxiHomeController({required this.taxiHomeServiceInterface});

  TopRatedCarsModel? _topRatedCarsModel;
  TopRatedCarsModel? get topRatedCarsModel => _topRatedCarsModel;

  TaxiBannerModel? _taxiBannerModel;
  TaxiBannerModel? get taxiBannerModel => _taxiBannerModel;

  List<TaxiCouponModel>? _taxiCouponList;
  List<TaxiCouponModel>? get taxiCouponList => _taxiCouponList;

  VehicleModel? _vehicleDetailsModel;
  VehicleModel? get vehicleDetailsModel => _vehicleDetailsModel;

  SelectedCarsModel? _selectedCarsModel;
  SelectedCarsModel? get selectedCarsModel => _selectedCarsModel;

  List<String> _searchHistoryList = [];
  List<String> get searchHistoryList => _searchHistoryList;

  VehicleCategoryModel? _vehicleCategoryModel;
  VehicleCategoryModel? get vehicleCategoryModel => _vehicleCategoryModel;

  String? _tripType = 'hourly';
  String? get tripType => _tripType;

  double _minPrice = 0;
  double get minPrice => _minPrice;

  double _maxPrice = 0;
  double get maxPrice => _maxPrice;

  List<int> _brandIds = [];
  List<int> get brandIds => _brandIds;

  List<String> _selectedSeatingCapacity = [];
  List<String> get selectedSeatingCapacity => _selectedSeatingCapacity;

  List<int> _selectedCategoryIds = [];
  List<int> get selectedCategoryIds => _selectedCategoryIds;

  bool _airCondition = false;
  bool get airCondition => _airCondition;

  bool _nonAirCondition = false;
  bool get nonAirCondition => _nonAirCondition;

  TripModel? _tripHistory;
  TripModel? get tripHistory => _tripHistory;

  TaxiBrandModel? _taxiBrandModel;
  TaxiBrandModel? get taxiBrandModel => _taxiBrandModel;

  List<PopularCarSuggestionModel>? _popularCarSuggestionModelList = [];
  List<PopularCarSuggestionModel>? get popularCarSuggestionModelList => _popularCarSuggestionModelList;

  void initFilterSetup() {
    _tripType = 'hourly';
    _minPrice = 0;
    _brandIds = [];
    _selectedSeatingCapacity = [];
    _selectedCategoryIds = [];
    _airCondition = false;
    _nonAirCondition = false;
  }

  void resetFilter(double? maxPrice) {
    _minPrice = 0;
    _maxPrice = maxPrice ?? 1000;
    _brandIds = [];
    _selectedSeatingCapacity = [];
    _selectedCategoryIds = [];
    _airCondition = false;
    _nonAirCondition = false;
    update();
  }

  Future<void> getTopRatedCarList(int offset, bool reload, {DataSourceEnum source = DataSourceEnum.local}) async {
    if(reload) {
      _topRatedCarsModel = null;
      update();
    }
    TopRatedCarsModel? carsModel;
    if(source == DataSourceEnum.local && offset == 1) {
      carsModel = await taxiHomeServiceInterface.getTopRatedCarList(offset, source: DataSourceEnum.local);
      _prepareTopRatedCarModel(carsModel, offset);
      getTopRatedCarList(offset, false, source: DataSourceEnum.client);
    } else {
      carsModel = await taxiHomeServiceInterface.getTopRatedCarList(offset, source: DataSourceEnum.client);
      _prepareTopRatedCarModel(carsModel, offset);
    }
  }

  _prepareTopRatedCarModel(TopRatedCarsModel? carsModel, int offset) {
    if (carsModel != null) {
      if (offset == 1) {
        _topRatedCarsModel = carsModel;
      }else {
        _topRatedCarsModel!.totalSize = carsModel.totalSize;
        _topRatedCarsModel!.offset = carsModel.offset;
        _topRatedCarsModel!.vehicles!.addAll(carsModel.vehicles!);
      }
      update();
    }
  }

  Future<void> getTaxiBannerList(bool reload, {DataSourceEnum source = DataSourceEnum.local}) async {
    if(reload) {
      _taxiBannerModel = null;
      update();
    }
    if(source == DataSourceEnum.local) {
      _taxiBannerModel = await taxiHomeServiceInterface.getTaxiBannerList(source: DataSourceEnum.local);
      update();
      getTaxiBannerList(false, source: DataSourceEnum.client);
    } else {
      _taxiBannerModel = await taxiHomeServiceInterface.getTaxiBannerList(source: DataSourceEnum.client);
      update();
    }
  }

  Future<void> getTaxiCouponList(bool reload, {DataSourceEnum source = DataSourceEnum.local}) async {
    if(reload) {
      _taxiCouponList = null;
      update();
    }
    if(source == DataSourceEnum.local) {
      _taxiCouponList = await taxiHomeServiceInterface.getTaxiCouponList(source: DataSourceEnum.local);
      update();
      getTaxiCouponList(false, source: DataSourceEnum.client);
    } else {
      _taxiCouponList = await taxiHomeServiceInterface.getTaxiCouponList(source: DataSourceEnum.client);
      update();
    }
  }

  Future<void> getVehicleDetails(int vehicleId) async {
    _vehicleDetailsModel = null;
    _vehicleDetailsModel = await taxiHomeServiceInterface.getVehicleDetails(id: vehicleId);
    update();
  }

  Future<void> getSelectedCars({String? name, required int offset, bool reload = false, bool fromFilter = false}) async {
    if(offset == 1) {
      _selectedCarsModel = null;
    }
    if(reload) {
      update();
    }
    if(name != null && name.isNotEmpty) {
      if (!_searchHistoryList.contains(name)) {
        _searchHistoryList.insert(0, name);
      }
      _searchHistoryList = _searchHistoryList.take(5).toList();
      taxiHomeServiceInterface.saveSearchHistory(_searchHistoryList);
    }
    _tripType = Get.find<TaxiLocationController>().tripType;
    String pickupTime = DateConverter.formatDate(Get.find<TaxiLocationController>().finalTripDateTime!);
    LatLng pickupLocation = LatLng(double.parse(Get.find<TaxiLocationController>().fromAddress!.latitude!.toString()), double.parse(Get.find<TaxiLocationController>().fromAddress!.longitude!.toString()));

    SelectedCarsModel? carsModel;
    carsModel = await taxiHomeServiceInterface.getSelectedCars(
      name: name, offset: offset, tripType: _tripType, minPrice: _minPrice, maxPrice: _maxPrice,
      brandIds: _brandIds, seatingCapacity: _selectedSeatingCapacity, airCondition: _airCondition,
      nonAirCondition: _nonAirCondition, categoryIds: _selectedCategoryIds, pickupTime: pickupTime,
      pickupLocation: pickupLocation,
    );

    if (carsModel != null) {
      if (offset == 1) {
        _selectedCarsModel = carsModel;
      } else {
        _selectedCarsModel!.totalSize = carsModel.totalSize;
        _selectedCarsModel!.offset = carsModel.offset;
        _selectedCarsModel!.vehicles!.addAll(carsModel.vehicles!);
      }

      if(!fromFilter) {
        _maxPrice = _selectedCarsModel!.maxPrice ?? 0;
      }
    }
    update();
  }

  Future<List<String>?> getSearchSuggestions(String searchText) async {
    List<String>? vehicles = <String>[];
    vehicles = await taxiHomeServiceInterface.getSearchSuggestions(name: searchText);
    return vehicles;
  }

  void getSearchHistoryList() {
    _searchHistoryList = [];
    _searchHistoryList.addAll(taxiHomeServiceInterface.getSearchHistory());
  }

  void removeSearchHistory(int index) {
    _searchHistoryList.removeAt(index);
    taxiHomeServiceInterface.saveSearchHistory(_searchHistoryList);
    update();
  }

  void clearSearchHistory() async {
    taxiHomeServiceInterface.clearSearchHistory();
    _searchHistoryList = [];
    update();
  }

  //Filter

  Future<void> getVehicleCategoryList() async {
    VehicleCategoryModel? categoryModel;
    categoryModel = await taxiHomeServiceInterface.getVehicleCategories(offset: 1);
    if(categoryModel != null) {
      _vehicleCategoryModel = categoryModel;
    }
    update();
  }

  Future<void> getTaxiBrandList(int offset, {bool reload = true}) async {
    if(reload) {
      _taxiBrandModel = null;
      update();
    }
    TaxiBrandModel? brand;
    brand = await taxiHomeServiceInterface.getTaxiBrandList(offset);
    if (brand != null) {
      if (offset == 1) {
        _taxiBrandModel = brand;
      }else {
        _taxiBrandModel!.totalSize = brand.totalSize;
        _taxiBrandModel!.offset = brand.offset;
        _taxiBrandModel!.brands!.addAll(brand.brands!);
      }
      update();
    }

  }

  void selectTripFilter(String type) {
    _tripType = type;
    update();
  }

  void setMinAndMaxPrice(double lower, double upper, {bool willUpdate = true}) {
    _minPrice = lower;
    _maxPrice = upper;
    if(willUpdate) {
      update();
    }
  }

  void addOrRemoveBrand(int id, {bool isRemove = false}) {
    if(_brandIds.contains(id)) {
      _brandIds.removeWhere((i)=> (i==id));
    } else {
      _brandIds.add(id);
    }
    update();
  }

  void addOrRemoveSeatingCapacity(String count) {
    if(_selectedSeatingCapacity.contains(count)) {
      _selectedSeatingCapacity.removeWhere((i)=> (i==count));
    } else {
      _selectedSeatingCapacity.add(count);
    }
    update();
  }

  void addOrRemoveCategory(int id) {
    if(_selectedCategoryIds.contains(id)) {
      _selectedCategoryIds.removeWhere((i)=> (i==id));
    } else {
      _selectedCategoryIds.add(id);
    }
    update();
  }

  void toggleAirCondition() {
    _airCondition = !_airCondition;
    update();
  }

  void toggleNonAirCondition() {
    _nonAirCondition = !_nonAirCondition;
    update();
  }

  Future<void> getPopularSearchList() async {
    _popularCarSuggestionModelList = [];
    List<PopularCarSuggestionModel>? list = await taxiHomeServiceInterface.getPopularSearchList();
    if(list != null) {
      for (int i=0; i<(list.length>10 ? 10 : list.length); i++) {
        _popularCarSuggestionModelList!.add(list[i]);
      }
    }
    update();

  }

  // Future<void> getHistoryTripList(int offset, bool reload) async {
  //   if(reload) {
  //     _tripHistory = null;
  //     update();
  //   }
  //   TripModel? tripModel;
  //   // if(source == DataSourceEnum.local && offset == 1) {
  //   //   tripModel = await taxiHomeServiceInterface.getHistoryTripList(offset: offset, type: , source: DataSourceEnum.local);
  //   //   _prepareStoreModel(storeModel, offset);
  //   //   getHistoryTripList(offset, false, source: DataSourceEnum.client);
  //   // } else {
  //     tripModel = await taxiHomeServiceInterface.getHistoryTripList(offset: offset, type: 'completed');
  //   _prepareTripModel(tripModel, offset);
  //   // }
  // }
  // _prepareTripModel(TripModel? tripModel, int offset) {
  //   if (tripModel != null) {
  //     if (offset == 1) {
  //       _tripHistory = tripModel;
  //     }else {
  //       _tripHistory!.totalSize = tripModel.totalSize;
  //       _tripHistory!.offset = tripModel.offset;
  //       _tripHistory!.trips!.addAll(tripModel.trips!);
  //     }
  //     update();
  //   }
  // }

}