import 'package:get/get_connect/connect.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_model.dart';

abstract class TaxiOrderServiceInterface {
  Future<TripModel?> getTripList({required int offset, required String type});
  Future<TripDetailsModel?> getTripDetails({required int id, String? phone});
  Future<bool> cancelTrip({required int id});
  Future<Response> makeTripPayment({required int id, required String paymentMethod, String? paymentGateWayName});
  Future<bool> addVehicleReview({required int tripId, required int vehicleId, required int vehicleIdentityId, required int rating, required String comment});
}