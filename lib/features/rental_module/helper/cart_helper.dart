import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';

class CartHelper{
  static Future<bool> checkTypeInCart(List<Carts> cartList, String rentalType) async{
    bool status = false;
    for (var cart in cartList) {
      if(rentalType == 'hourly') {
        status = cart.vehicle!.tripHourly!;
      } else if(rentalType == 'day_wise') {
        status = cart.vehicle!.tripDayWise!;
      }else {
        status = cart.vehicle!.tripDistance!;
      }
      if(!status) {
        break;
      }
    }
    return status;
  }

  static String calculateHour({required String tripType, required String time, required String day}) {
    if(time.isEmpty) {
      time = '0';
    }
    if(day.isEmpty) {
      day = '0';
    }
    if(tripType == 'hourly') {
      return time;
    } else {
      int d = int.parse(day) * 24;
      return d.toString();
    }
  }
}