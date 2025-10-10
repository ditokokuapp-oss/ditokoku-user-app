import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/domain/services/taxi_favourite_service_interface.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';

class TaxiFavouriteController extends GetxController implements GetxService {
  final TaxiFavouriteServiceInterface taxiFavouriteServiceInterface;

  TaxiFavouriteController({required this.taxiFavouriteServiceInterface});

  List<VehicleModel?>? _wishVehicleList;
  List<VehicleModel?>? get wishVehicleList => _wishVehicleList;

  List<int?> _wishVehicleIdList = [];
  List<int?> get wishVehicleIdList => _wishVehicleIdList;

  List<TaxiVendorModel?>? _wishProviderList;
  List<TaxiVendorModel?>? get wishProviderList => _wishProviderList;

  List<int?> _wishProviderIdList = [];
  List<int?> get wishProviderIdList => _wishProviderIdList;

  bool _isRemoving = false;
  bool get isRemoving => _isRemoving;

  void addToFavouriteList({required VehicleModel? vehicle, required int? providerId, required bool isProvider, bool getXSnackBar = false}) async {
    _isRemoving = true;
    update();
    if(isProvider) {
      _wishProviderList ??= [];
      _wishProviderIdList.add(providerId);
      _wishProviderList!.add(TaxiVendorModel());
    }else{
      _wishVehicleList = [];
      _wishVehicleList!.add(vehicle);
      _wishVehicleIdList.add(vehicle!.id);
    }
    ResponseModel responseModel = await taxiFavouriteServiceInterface.addVehicleFavouriteList(isProvider ? providerId! : vehicle!.id!, isProvider);
    if (responseModel.isSuccess) {
      // showCustomSnackBar(responseModel.message, isError: false, getXSnackBar: getXSnackBar);
    } else {
      if(isProvider) {
        for (var providerId in _wishProviderIdList) {
          if (providerId == providerId) {
            _wishProviderIdList.removeAt(_wishProviderIdList.indexOf(providerId));
          }
        }
      }else{
        for (var id in _wishVehicleIdList) {
          if(id == vehicle!.id){
            _wishVehicleIdList.removeAt(_wishVehicleIdList.indexOf(id));
          }
        }
      }
      // showCustomSnackBar(responseModel.message, isError: true, getXSnackBar: getXSnackBar);
    }
    _isRemoving = false;
    update();
  }

  void removeFromFavouriteList(int? id, bool isProvider, {bool getXSnackBar = false}) async {
    _isRemoving = true;
    update();

    int idIndex = -1;
    int? providerId, vehicleId;
    TaxiVendorModel? provider;
    VehicleModel? vehicle;
    if(isProvider) {
      idIndex = _wishProviderIdList.indexOf(id);
      if(idIndex != -1) {
        providerId = id;
        _wishProviderIdList.removeAt(idIndex);
        provider = _wishProviderList![idIndex];
        _wishProviderList!.removeAt(idIndex);
      }
    }else {
      idIndex = _wishVehicleIdList.indexOf(id);
      if(idIndex != -1) {
        vehicleId = id;
        _wishVehicleIdList.removeAt(idIndex);
        vehicle = _wishVehicleList![idIndex];
        _wishVehicleList!.removeAt(idIndex);
      }
    }
    ResponseModel responseModel = await taxiFavouriteServiceInterface.removeVehicleFavouriteList(id, isProvider);
    if (responseModel.isSuccess) {
      // showCustomSnackBar(responseModel.message, isError: false, getXSnackBar: getXSnackBar);
    }
    else {
      // showCustomSnackBar(responseModel.message, isError: true, getXSnackBar: getXSnackBar);
      if(isProvider) {
        _wishProviderIdList.add(providerId);
        _wishProviderList!.add(provider);
      }else {
        _wishVehicleIdList.add(vehicleId);
        _wishVehicleList!.add(vehicle);
      }
    }
    _isRemoving = false;
    update();
  }

  Future<void> getFavouriteTaxiList() async {
    _wishVehicleList = null;
    _wishProviderList = null;
    Response response = await taxiFavouriteServiceInterface.getFavouriteTaxiList();

    if (response.statusCode == 200) {
      update();
      _wishVehicleList = [];
      _wishProviderList = [];
      _wishProviderIdList = [];
      _wishVehicleIdList = [];

      if(response.body['vehicles'] != null) {
        response.body['vehicles'].forEach((vehicles) async{
          VehicleModel vehicle = VehicleModel.fromJson(vehicles);
          _wishVehicleList!.add(vehicle);
          _wishVehicleIdList.add(vehicle.id);
        });
      }

      response.body['providers'].forEach((providers) async {
        TaxiVendorModel? provider;
        try{
          provider = TaxiVendorModel.fromJson(providers);
        }catch(e){
          debugPrint('exception create in Provider list create : $e');
        }
        if(provider != null) {
          _wishProviderList!.add(provider);
          _wishProviderIdList.add(provider.id);
        }
      });
    }
    update();
  }

  void removeFavourite() {
    _wishVehicleIdList = [];
    _wishProviderIdList = [];
  }

}