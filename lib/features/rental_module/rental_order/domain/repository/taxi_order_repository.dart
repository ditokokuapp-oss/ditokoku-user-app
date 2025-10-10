
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_model.dart';
import 'package:sixam_mart/features/rental_module/rental_order/domain/repository/taxi_order_repository_interface.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class TaxiOrderRepository implements TaxiOrderRepositoryInterface {
  final ApiClient apiClient;

  TaxiOrderRepository({required this.apiClient});

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) async {
    Response response = await apiClient.putData('${AppConstants.tripCancelUri}?trip_id=$id${!AuthHelper.isLoggedIn() ? '&guest_id=${AuthHelper.getGuestId()}' : ''}', {'_method': 'put'});
    return response.statusCode == 200;
  }

  @override
  Future get(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<TripModel?> getTripList({required int offset, required String type}) async {
    TripModel? tripModel;

    Response response = await apiClient.getData('${AppConstants.tripListUri}/$type?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      tripModel = TripModel.fromJson(response.body);
    }
    return tripModel;
  }

  @override
  Future<TripDetailsModel?> getTripDetails({required int id, String? phone}) async {
    TripDetailsModel? tripDetailsModel;

    Response response = await apiClient.getData('${AppConstants.tripDetailsUri}?trip_id=$id${!AuthHelper.isLoggedIn() ? '&guest_id=${AuthHelper.getGuestId()}${phone != null ? '&contact_number=$phone' : ''}' : ''}');
    if (response.statusCode == 200) {
      tripDetailsModel = TripDetailsModel.fromJson(response.body);
    }
    return tripDetailsModel;
  }

  @override
  Future<Response> makeTripPayment({required int id, required String paymentMethod, String? paymentGateWayName}) async {
    Map<String, dynamic> body = {};
    if(paymentGateWayName == null) {
      body.addAll({"trip_id": id, "payment_method": paymentMethod});
    }else {
      body.addAll({
        "trip_id": id,
        "payment_method": paymentMethod,
        "payment_gateway": paymentGateWayName,
        "callback_url": AppConstants.baseUrl,
        "payment_platform": 'app'
      });
    }
    return await apiClient.postData('${AppConstants.tripPaymentUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}', body);
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<bool> addVehicleReview({required int tripId, required int vehicleId, required int vehicleIdentityId, required int rating, required String comment}) async {
    Map<String, dynamic> data = {
      "trip_id": tripId,
      "vehicle_id": vehicleId,
      "vehicle_identity_id": vehicleIdentityId,
      "rating": rating,
      "comment": comment,
    };
    Response response = await apiClient.postData('${AppConstants.addTaxiReviewUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}', data);
    return response.statusCode == 200;
  }
  
}