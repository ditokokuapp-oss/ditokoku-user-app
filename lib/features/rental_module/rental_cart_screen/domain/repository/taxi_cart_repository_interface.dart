import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_coupon_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class TaxiCartRepositoryInterface<CarCart> implements RepositoryInterface<CarCart>{
  Future<Response> tripBook({required double tripAmount, required String tripType, required int providerId, required String note, String? guestName, String? guestPhone, String? guestEmail, String? couponCode, required String scheduleTime, required bool isSchedule});
  Future<Response> updateUserData({required CarCart cart, required int userId});
  Future<bool> clearTaxiCart({int? vehicleId, int? quantity, String? pickupTime, String? rentalType});
  Future<CarCartModel?> clearMultipleTaxiCart(List<int> ids);
  Future<TaxiCouponModel?> applyTaxiCoupon(String couponCode, int? providerId);
  Future<Response> getTripTax({required double tripAmount, required String tripType, required int providerId, String? couponCode, required String scheduleTime, required bool isSchedule});
}