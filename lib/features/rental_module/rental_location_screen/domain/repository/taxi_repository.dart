import 'dart:convert';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_data_model.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/domain/repository/taxi_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class TaxiRepository implements TaxiRepositoryInterface{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  TaxiRepository({required this.sharedPreferences, required this.apiClient});

  @override
  Future<Response> getPlaceDetails(String? placeID) async {
    return await apiClient.getData('${AppConstants.placeDetailsUri}?placeid=$placeID');
  }

  @override
  Future<Response> getRouteBetweenCoordinates(LatLng origin, LatLng destination) async {
    return await apiClient.getData('${AppConstants.directionUri}'
        '?origin_lat=${origin.latitude}&origin_lng=${origin.longitude}'
        '&destination_lat=${destination.latitude}&destination_lng=${destination.longitude}');
  }

  @override
  Future<void> saveSearchAddress(List<AddressModel> addresses) async {
    final String encodedData = jsonEncode(
      addresses.map((address) => address.toJson()).toList(),
    );
    await sharedPreferences.setString(AppConstants.taxiSearchAddressHistory, encodedData);
  }

  @override
  Future<List<AddressModel>> getSearchAddresses() async {
    final String? encodedData = sharedPreferences.getString(AppConstants.taxiSearchAddressHistory);

    if (encodedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((json) => AddressModel.fromJson(json)).toList();
  }

  @override
  Future<List<ZoneDataModel>?> getZoneList() async {
    List<ZoneDataModel>? zoneList;
    Response response = await apiClient.getData(AppConstants.zoneListUri);
    if (response.statusCode == 200) {
      zoneList = [];
      response.body.forEach((zone) => zoneList!.add(ZoneDataModel.fromJson(zone)));
    }
    return zoneList;
  }

  @override
  Future<bool> checkInZone(String? lat, String? lng, int zoneId) async {
    Response response = await apiClient.getData('${AppConstants.checkZoneUri}?lat=$lat&lng=$lng&zone_id=$zoneId');
    if(response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  @override
  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    return await apiClient.getData(
      '${AppConstants.distanceMatrixUri}?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
          '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}&mode=DRIVE',
      handleError: false,
    );
  }
}