import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_provider_review_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_banner_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_vehicle_category_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/vendor_vehicles_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/services/taxi_vendor_service_interface.dart';
import 'package:sixam_mart/helper/date_converter.dart';

class TaxiVendorController extends GetxController implements GetxService {
  final TaxiVendorServiceInterface taxiVendorServiceInterface;

  TaxiVendorController({required this.taxiVendorServiceInterface});

  TaxiVendorModel? _taxiVendor;
  TaxiVendorModel? get taxiVendor => _taxiVendor;

  VendorVehiclesModel? _taxiVendorVehicleList;
  VendorVehiclesModel? get taxiVendorVehicleList => _taxiVendorVehicleList;

  VendorVehicleCategoryModel? _vendorVehicleCategoryList;
  VendorVehicleCategoryModel? get vendorVehicleCategoryList => _vendorVehicleCategoryList;

  List<VehiclesCategory>? _categories;
  List<VehiclesCategory>? get categories => _categories;

  int? _categoryId;
  int? get categoryId => _categoryId;

  double _minPrice = 0;
  double get minPrice => _minPrice;

  double _maxPrice = 0;
  double get maxPrice => _maxPrice;

  List<String> _selectedSeatingCapacity = [];
  List<String> get selectedSeatingCapacity => _selectedSeatingCapacity;

  List<int> _selectedBrands = [];
  List<int> get selectedBrands => _selectedBrands;

  bool _airCondition = false;
  bool get airCondition => _airCondition;

  bool _nonAirCondition = false;
  bool get nonAirCondition => _nonAirCondition;

  TaxiProviderReviewModel? _providerReviewDetails;
  TaxiProviderReviewModel? get providerReviewDetails => _providerReviewDetails;

  List<Reviews>? _providerReviewList;
  List<Reviews>? get providerReviewList => _providerReviewList;

  List<VendorBannerModel>? _vendorBannerList;
  List<VendorBannerModel>? get vendorBannerList => _vendorBannerList;

  void setCategoryId(int? id, {bool canUpdate = true}) {
    _categoryId = id;
    if(canUpdate) {
      update();
    }
  }

  Future<void> getTaxiVendorDetails(int vendorId) async {
    _taxiVendor = null;
    _taxiVendor = await taxiVendorServiceInterface.getTaxiVendorDetails(id: vendorId);
    update();
  }

  Future<void> getVendorBannerList(int id) async {
    _vendorBannerList = null;
    _vendorBannerList = await taxiVendorServiceInterface.getVendorBannerList(id: id);
    update();
  }

  Future<void> getVendorVehicleList({required int offset, required int vendorId, int? categoryId, String? searchName, bool canUpdate = true, bool fromFilter = false}) async {
    _taxiVendorVehicleList = null;
    if(canUpdate) {
      update();
    }
    VendorVehiclesModel? vendorVehiclesModel = await taxiVendorServiceInterface.getVendorVehicleList(
      offset: offset, providerId: vendorId, categoryId: _categoryId, searchName:searchName,
      minPrice: _minPrice, maxPrice: _maxPrice, brandIds: _selectedBrands, seatingCapacity: _selectedSeatingCapacity,
      airCondition: _airCondition, nonAirCondition: _nonAirCondition,
    );
    if (vendorVehiclesModel != null) {
      if (offset == 1) {
        _taxiVendorVehicleList = vendorVehiclesModel;
      } else {
        _taxiVendorVehicleList!.totalSize = vendorVehiclesModel.totalSize;
        _taxiVendorVehicleList!.offset = vendorVehiclesModel.offset;
        _taxiVendorVehicleList!.vehicles!.addAll(vendorVehiclesModel.vehicles!);
      }
      if(!fromFilter) {
        _maxPrice = _taxiVendorVehicleList!.maxPrice ?? 0;
      }
    }
    update();
  }

  Future<void> getVendorVehicleCategoryList() async {
    VendorVehicleCategoryModel? vendorVehicleCategoryModel = await taxiVendorServiceInterface.getVendorVehicleCategoryList();
    if(vendorVehicleCategoryModel != null) {
      _vendorVehicleCategoryList = vendorVehicleCategoryModel;
      _categories = [];
      _categories!.add(VehiclesCategory(id: -1, name: 'all'.tr));
      _categories!.addAll(vendorVehicleCategoryModel.vehicles!);
    }
    update();
  }


  void initFilterSetup({bool willUpdate = true, double? maxPrice}) {
    _minPrice = 0;
    _maxPrice = maxPrice ?? 1000;
    _selectedBrands = [];
    _selectedSeatingCapacity = [];
    _airCondition = false;
    _nonAirCondition = false;
    if(willUpdate) {
      update();
    }
  }

  void setMinAndMaxPrice(double lower, double upper, {bool willUpdate = true}) {
    _minPrice = lower;
    _maxPrice = upper;
    if(willUpdate) {
      update();
    }
  }

  void addOrRemoveSeatingCapacity(String count) {
    if(_selectedSeatingCapacity.contains(count)) {
      _selectedSeatingCapacity.removeWhere((i)=> (i==count));
    } else {
      _selectedSeatingCapacity.add(count);
    }
    update();
  }

  void addOrRemoveBrand(int id) {
    if(_selectedBrands.contains(id)) {
      _selectedBrands.removeWhere((i)=> (i==id));
    } else {
      _selectedBrands.add(id);
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

  Future<void> getTaxiProviderReviewDetails(int providerId) async {
    _providerReviewDetails = null;
    _providerReviewDetails = await taxiVendorServiceInterface.getTaxiProviderReviewDetails(id: providerId);
    update();
    _providerReviewList = _providerReviewDetails!.reviews;
  }

  bool isProviderOpenNow(bool active, List<Schedules>? schedules) {
    if(isProviderClosed(true, active, schedules)) {
      return false;
    }
    int weekday = DateTime.now().weekday;
    if(weekday == 7) {
      weekday = 0;
    }
    for(int index=0; index<schedules!.length; index++) {
      if(weekday == schedules[index].day
          && DateConverter.isAvailable(schedules[index].openingTime, schedules[index].closingTime)) {
        return true;
      }
    }
    return false;
  }

  bool isProviderClosed(bool today, bool active, List<Schedules>? schedules) {
    if(!active) {
      return true;
    }
    DateTime date = DateTime.now();
    if(!today) {
      date = date.add(const Duration(days: 1));
    }
    int weekday = date.weekday;
    if(weekday == 7) {
      weekday = 0;
    }
    for(int index=0; index<schedules!.length; index++) {
      if(weekday == schedules[index].day) {
        return false;
      }
    }
    return true;
  }

  // Future<void> getVehicleSearchItemList({required String searchText, required int offset, required int? vendorId}) async {
  //   if(searchText.isEmpty) {
  //     showCustomSnackBar('write_vehicle_name'.tr);
  //   }else {
  //     _isSearching = true;
  //     _searchText = searchText;
  //     if(offset == 1 || _vehicleSearchItemModel == null) {
  //       _vehicleSearchItemModel = null;
  //       update();
  //     }
  //     SelectedCarsModel? vehicleSearchItemModel = await taxiVendorServiceInterface.getVehicleSearchItemList(offset: offset, searchText: searchText, providerId: vendorId);
  //
  //     if (vehicleSearchItemModel != null) {
  //       if (offset == 1) {
  //         _vehicleSearchItemModel = vehicleSearchItemModel;
  //       }else {
  //         _vehicleSearchItemModel!.vehicles!.addAll(vehicleSearchItemModel.vehicles!);
  //         _vehicleSearchItemModel!.totalSize = vehicleSearchItemModel.totalSize;
  //         _vehicleSearchItemModel!.offset = vehicleSearchItemModel.offset;
  //       }
  //     }
  //     update();
  //   }
  // }

}