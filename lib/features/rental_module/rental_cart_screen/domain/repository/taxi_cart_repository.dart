import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_coupon_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/repository/taxi_cart_repository_interface.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class TaxiCartRepository implements TaxiCartRepositoryInterface<CarCart>{
  final ApiClient apiClient;
  TaxiCartRepository({required this.apiClient});

  @override
  Future add(CarCart cart) async {
    return await _addToCart(cart);
  }

  Future<CarCartModel?> _addToCart(CarCart cart) async {
    CarCartModel? cartModel;
    Response response = await apiClient.postData('${AppConstants.addToCarCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}', cart.toJson());
    if(response.statusCode == 200) {
      cartModel = CarCartModel.fromJson(response.body);
    }
    return cartModel;
  }

  @override
  Future<Response> tripBook({required double tripAmount, required String tripType, required int providerId, required String note, String? guestName, String? guestPhone, String? guestEmail, String? couponCode, required String scheduleTime, required bool isSchedule}) async {
    Map<String, dynamic> data = {
      "trip_amount": tripAmount,
      "trip_type": tripType,
      "provider_id": providerId,
      "coupon_code": couponCode ?? '',
      "latitude": AddressHelper.getUserAddressFromSharedPref()?.latitude??0,
      "longitude": AddressHelper.getUserAddressFromSharedPref()?.longitude??0,
      "additional_note": note,
      "schedule_at": scheduleTime,
      "scheduled": isSchedule ? 1 : 0,
    };
    if(!AuthHelper.isLoggedIn()) {
      data.addAll({
        "contact_person_name": guestName,
        "contact_person_number": guestPhone,
        "contact_person_email": guestEmail,
      });
    }
    Response response = await apiClient.postData('${AppConstants.tripBookingUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}', data);
    return response;
  }

  @override
  Future<Response> updateUserData({required CarCart cart, required int userId}) async {
    Response response = await apiClient.postData('${AppConstants.tripUpdateUserDataUri}/$userId${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}', cart.toJson());
    return response;
  }

  @override
  Future<bool> clearTaxiCart({int? vehicleId, int? quantity, String? pickupTime, String? rentalType}) async {
    Response response = await apiClient.deleteData('${AppConstants.removeAllCarCartUri}${vehicleId != null ? '?vehicle_id=$vehicleId&quantity=$quantity&pickup_time=$pickupTime&rental_type=$rentalType' : ''}'
        '${!AuthHelper.isLoggedIn() ? '${vehicleId != null ? '&' : '?'}guest_id=${AuthHelper.getGuestId()}' : ''}');
    return (response.statusCode == 200);
  }

  @override
  Future delete(int? id) async {
    CarCartModel? cartModel;
    Response response = await apiClient.deleteData('${AppConstants.removeCarCartUri}/$id${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}');
    if(response.statusCode == 200) {
      cartModel = CarCartModel.fromJson(response.body);
    }
    return cartModel;
  }

  @override
  Future<CarCartModel?> clearMultipleTaxiCart(List<int> ids) async {
    CarCartModel? cartModel;
    Response response = await apiClient.deleteData('${AppConstants.removeMultipleCarCartUri}?cart_ids=$ids${!AuthHelper.isLoggedIn() ? '&guest_id=${AuthHelper.getGuestId()}' : ''}');
    if(response.statusCode == 200) {
      cartModel = CarCartModel.fromJson(response.body);
    }
    return cartModel;
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    return _getCartList();
  }

  Future<CarCartModel?> _getCartList() async {
    CarCartModel? cartModel;
    Response response = await apiClient.getData('${AppConstants.getCarCartListUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}');
    if(response.statusCode == 200) {
      cartModel = CarCartModel.fromJson(response.body);
    }
    return cartModel;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) async {
    CarCartModel? cartModel;
    Response response = await apiClient.postData('${AppConstants.updateCarCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}', body);
    if(response.statusCode == 200) {
      cartModel = CarCartModel.fromJson(response.body);
    }
    return cartModel;
  }

  @override
  Future<TaxiCouponModel?> applyTaxiCoupon(String couponCode, int? providerId) async {
    TaxiCouponModel? taxiCouponModel;
    Response response = await apiClient.getData('${AppConstants.taxiCouponApplyUri}?code=$couponCode&provider_id=$providerId');
    if (response.statusCode == 200) {
      taxiCouponModel = TaxiCouponModel.fromJson(response.body);
    }
    return taxiCouponModel;
  }

  @override
  Future<Response> getTripTax({required double tripAmount, required String tripType, required int providerId, String? couponCode, required String scheduleTime, required bool isSchedule}) async {
    Map<String, dynamic> data = {
      "trip_amount": tripAmount,
      "trip_type": tripType,
      "provider_id": providerId,
      "coupon_code": couponCode ?? '',
      "latitude": AddressHelper.getUserAddressFromSharedPref()?.latitude??0,
      "longitude": AddressHelper.getUserAddressFromSharedPref()?.longitude??0,
      "schedule_at": scheduleTime,
      "scheduled": isSchedule ? 1 : 0,
    };
    Response response = await apiClient.postData('${AppConstants.getTripTaxUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}', data);
    return response;
  }
  
}