import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_model.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class TaxiOrderRepositoryInterface extends RepositoryInterface {
  Future<TripModel?> getTripList({required int offset, required String type});
  Future<TripDetailsModel?> getTripDetails({required int id, String? phone});
  Future<Response> makeTripPayment({required int id, required String paymentMethod, String? paymentGateWayName});
  Future<bool> addVehicleReview({required int tripId, required int vehicleId, required int vehicleIdentityId, required int rating, required String comment});
}