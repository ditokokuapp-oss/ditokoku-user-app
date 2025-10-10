import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_data_model.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/domain/repository/taxi_repository_interface.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/domain/services/taxi_location_service_interface.dart';

class TaxiLocationService implements TaxiLocationServiceInterface{
  TaxiRepositoryInterface taxiRepositoryInterface;
  TaxiLocationService({required this.taxiRepositoryInterface});

  @override
  Future<LatLng> getPlaceDetails(String? placeID) async {
    LatLng latLng = const LatLng(0, 0);
    Response? response = await taxiRepositoryInterface.getPlaceDetails(placeID);
    if(response.statusCode == 200) {

      final data = response.body;
      final location = data['location'];
      final double lat = location['latitude'];
      final double lng = location['longitude'];
      latLng = LatLng(lat, lng);
    }
    return latLng;
  }

  @override
  Future<Response> getRouteBetweenCoordinates(LatLng origin, LatLng destination) async {
    return await taxiRepositoryInterface.getRouteBetweenCoordinates(origin, destination);
  }

  @override
  Future<List<AddressModel>> getSearchAddresses() {
    return taxiRepositoryInterface.getSearchAddresses();
  }

  @override
  Future<void> saveSearchAddress(List<AddressModel> addresses) async {
    await taxiRepositoryInterface.saveSearchAddress(addresses);
  }

  @override
  Future<List<ZoneDataModel>?> getZoneList() async {
    return await taxiRepositoryInterface.getZoneList();
  }

  @override
  Future<bool> checkInZone(String? lat, String? lng, int zoneId) async {
    return await taxiRepositoryInterface.checkInZone(lat, lng, zoneId);
  }

  @override
  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    return await taxiRepositoryInterface.getDistanceInMeter(originLatLng, destinationLatLng);
  }

}