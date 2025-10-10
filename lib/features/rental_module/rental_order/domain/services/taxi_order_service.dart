import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_model.dart';
import 'package:sixam_mart/features/rental_module/rental_order/domain/repository/taxi_order_repository_interface.dart';
import 'package:sixam_mart/features/rental_module/rental_order/domain/services/taxi_order_service_interface.dart';

class TaxiOrderService implements TaxiOrderServiceInterface {
  final TaxiOrderRepositoryInterface taxiOrderRepositoryInterface;

  TaxiOrderService({required this.taxiOrderRepositoryInterface});

  @override
  Future<TripModel?> getTripList({required int offset, required String type}) async {
    return await taxiOrderRepositoryInterface.getTripList(offset: offset, type: type);
  }

  @override
  Future<TripDetailsModel?> getTripDetails({required int id, String? phone}) async {
    return await taxiOrderRepositoryInterface.getTripDetails(id: id, phone: phone);
  }

  @override
  Future<bool> cancelTrip({required int id}) async {
    return await taxiOrderRepositoryInterface.delete(id);
  }

  @override
  Future<Response> makeTripPayment({required int id, required String paymentMethod, String? paymentGateWayName}) async {
    return await taxiOrderRepositoryInterface.makeTripPayment(id: id, paymentMethod: paymentMethod, paymentGateWayName: paymentGateWayName);
  }

  @override
  Future<bool> addVehicleReview({required int tripId, required int vehicleId, required int vehicleIdentityId, required int rating, required String comment}) async {
    return await taxiOrderRepositoryInterface.addVehicleReview(tripId: tripId, vehicleId: vehicleId, vehicleIdentityId: vehicleIdentityId, rating: rating, comment: comment);
  }


}