
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_data_model.dart';

abstract class TaxiRepositoryInterface {
  Future<Response> getPlaceDetails(String? placeID);
  Future<Response> getRouteBetweenCoordinates(LatLng origin, LatLng destination);
  Future<void> saveSearchAddress(List<AddressModel> addresses);
  Future<List<AddressModel>> getSearchAddresses();
  Future<List<ZoneDataModel>?> getZoneList();
  Future<bool> checkInZone(String? lat, String? lng, int zoneId);
  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng);
}