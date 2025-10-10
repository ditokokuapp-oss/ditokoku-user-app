import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_coupon_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/repository/taxi_cart_repository_interface.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/services/taxi_cart_service_interface.dart';

class TaxiCartService implements TaxiCartServiceInterface {
  TaxiCartRepositoryInterface taxiCartRepositoryInterface;

  TaxiCartService({required this.taxiCartRepositoryInterface});

  @override
  Future<CarCartModel?> addToCart(CarCart cart) async {
    return await taxiCartRepositoryInterface.add(cart);
  }

  @override
  Future<Response> tripBook({required double tripAmount, required String tripType, required int providerId, required String note, String? guestName, String? guestPhone, String? guestEmail, String? couponCode, required String scheduleTime, required bool isSchedule}) async {
    return await taxiCartRepositoryInterface.tripBook(tripAmount: tripAmount, tripType: tripType, providerId: providerId, note: note, guestName: guestName, guestPhone: guestPhone, guestEmail: guestEmail, couponCode: couponCode, scheduleTime: scheduleTime, isSchedule: isSchedule);
  }

  @override
  Future<CarCartModel?> updateToCart(int cartId, int quantity) async {
    return await taxiCartRepositoryInterface.update({"cart_id": cartId, "quantity": quantity, "_method": 'put'}, null);
  }

  @override
  Future<CarCartModel?> removeFromCart(int cartId) async {
    return await taxiCartRepositoryInterface.delete(cartId);
  }

  @override
  Future<CarCartModel?> getCartList() async {
    return await taxiCartRepositoryInterface.getList();
  }

  @override
  Future<bool> clearTaxiCart({int? vehicleId, int? quantity, String? pickupTime, String? rentalType}) async {
    return await taxiCartRepositoryInterface.clearTaxiCart(vehicleId: vehicleId, quantity: quantity, pickupTime: pickupTime, rentalType: rentalType);
  }

  @override
  Future<CarCartModel?> clearMultipleTaxiCart(List<int> ids) async {
    return await taxiCartRepositoryInterface.clearMultipleTaxiCart(ids);
  }

  @override
  int? getCartId(int cartIndex, List<Carts> cartList) {
    if(cartIndex != -1) {
      return cartList.isNotEmpty ? cartList[cartIndex].id : null;
    } else {
      return null;
    }
  }

  @override
  int isExistInCart(List<Carts> cartList, int? vehicleID) {
    for(int index=0; index<cartList.length; index++) {
      if(cartList[index].vehicle!.id == vehicleID ) {
        return index;
      }
    }
    return -1;
  }


  @override
  Future<int> decideCarQuantity(bool isIncrement, List<Carts> cartList, int cartIndex, int? stock) async{
    int quantity = cartList[cartIndex].quantity!;
    if (isIncrement) {
      if(stock != null && cartList[cartIndex].quantity! >= stock) {
        showCustomSnackBar('${'you_cant_add_more_than'.tr} $stock ${'quantities_of_this_vehicle'.tr}');
      }else {
        quantity = quantity + 1;
      }
    } else {
      quantity = quantity - 1;
    }
    return quantity;
  }

  @override
  Future<Response> updateUserData({required CarCart cart, required int userId}) async {
    return await taxiCartRepositoryInterface.updateUserData(cart: cart, userId: userId);
  }

  @override
  Future<TaxiCouponModel?> applyTaxiCoupon(String couponCode, int? providerId) async {
    return await taxiCartRepositoryInterface.applyTaxiCoupon(couponCode, providerId);
  }

  @override
  Future<Response> getTripTax({required double tripAmount, required String tripType, required int providerId, String? couponCode, required String scheduleTime, required bool isSchedule}) async {
    return await taxiCartRepositoryInterface.getTripTax(tripAmount: tripAmount, tripType: tripType, providerId: providerId, couponCode: couponCode, scheduleTime: scheduleTime, isSchedule: isSchedule);
  }

}