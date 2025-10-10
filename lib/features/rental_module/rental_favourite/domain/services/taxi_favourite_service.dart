import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/domain/repositories/taxi_favourite_repository_interface.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/domain/services/taxi_favourite_service_interface.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';

class TaxiFavouriteService implements TaxiFavouriteServiceInterface {
  final TaxiFavouriteRepositoryInterface taxiFavouriteRepositoryInterface;
  TaxiFavouriteService({required this.taxiFavouriteRepositoryInterface});

  @override
  Future<ResponseModel> addVehicleFavouriteList(int id, bool isProvider) async{
    return await taxiFavouriteRepositoryInterface.addVehicleFavouriteList(id, isProvider);
  }

  @override
  Future<ResponseModel> removeVehicleFavouriteList(int? id, bool isProvider) async{
    return await taxiFavouriteRepositoryInterface.delete(id, isProvider: isProvider);
  }

  @override
  Future<Response> getFavouriteTaxiList() async {
    return await taxiFavouriteRepositoryInterface.getList();
  }

  @override
  List<int?> wishProviderIdList(store) {
    List<int?> wishStoreIdList = [];
    wishStoreIdList.add(TaxiVendorModel.fromJson(store).id);

    // for (var zone in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
    //   for (var module in zone.modules!) {
    //     if(module.id == Store.fromJson(store).moduleId){
    //       if(module.pivot!.zoneId == Store.fromJson(store).zoneId){
    //         wishStoreIdList.add(Store.fromJson(store).id);
    //       }
    //     }
    //   }
    // }
    return wishStoreIdList;
  }

  @override
  List<TaxiVendorModel?> wishProviderList(provider) {
    List<TaxiVendorModel?> wishStoreList = [];
    wishStoreList.add(TaxiVendorModel.fromJson(provider));

    // for (var zone in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
    //   for (var module in zone.modules!) {
    //     if(module.id == Store.fromJson(store).moduleId){
    //       if(module.pivot!.zoneId == Store.fromJson(store).zoneId){
    //         wishStoreList.add(Store.fromJson(store));
    //       }
    //     }
    //   }
    // }
    return wishStoreList;
  }

  @override
  List<int?> wishVehicleIdList(VehicleModel vehicle) {
    List<int?> wishVehicleIdList = [];
    wishVehicleIdList.add(vehicle.id);

    // for (var zone in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
    //   for (var module in zone.modules!) {
    //     if(module.id == item.moduleId){
    //       if(module.pivot!.zoneId == item.zoneId){
    //         wishItemIdList.add(item.id);
    //       }
    //     }
    //   }
    // }
    return wishVehicleIdList;
  }

  @override
  List<VehicleModel?> wishVehicleList(VehicleModel vehicle) {
    List<VehicleModel?> wishVehicleList = [];
    wishVehicleList.add(vehicle);

    // for (var zone in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
    //   for (var module in zone.modules!) {
    //     if(module.id == item.moduleId){
    //       if(module.pivot!.zoneId == item.zoneId){
    //         wishVehicleList.add(item);
    //       }
    //     }
    //   }
    // }
    return wishVehicleList;
  }
}