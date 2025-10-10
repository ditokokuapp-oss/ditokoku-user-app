import 'package:get/get_connect.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_coupon_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';

abstract class TaxiCartServiceInterface{
  Future<CarCartModel?> addToCart(CarCart cart);
  Future<Response> tripBook({required double tripAmount, required String tripType, required int providerId, required String note, String? guestName, String? guestPhone, String? guestEmail, String? couponCode, required String scheduleTime, required bool isSchedule});
  Future<CarCartModel?> updateToCart(int cartId, int quantity);
  Future<CarCartModel?> removeFromCart(int cartId);
  Future<bool> clearTaxiCart({int? vehicleId, int? quantity, String? pickupTime, String? rentalType});
  Future<CarCartModel?> clearMultipleTaxiCart(List<int> ids);
  Future<CarCartModel?> getCartList();
  int? getCartId(int cartIndex, List<Carts> cartList);
  Future<int> decideCarQuantity(bool isIncrement, List<Carts> cartList, int cartIndex, int? stock);
  int isExistInCart(List<Carts> cartList, int? vehicleID);
  Future<Response> updateUserData({required CarCart cart, required int userId});
  Future<TaxiCouponModel?> applyTaxiCoupon(String couponCode, int? providerId);
  Future<Response> getTripTax({required double tripAmount, required String tripType, required int providerId, String? couponCode, required String scheduleTime, required bool isSchedule});
}