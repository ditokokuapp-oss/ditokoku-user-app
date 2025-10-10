import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';

class TaxiPriceHelper {

  static double calculateTripCost(List<Carts> cartList, UserData userData) {
    double tripCost = 0;
    String rentalType = userData.rentalType!;
    double distanceOrHour = rentalType == 'hourly' ? userData.estimatedHours ?? 1 : rentalType == 'day_wise' ? (userData.estimatedHours ?? 0) / 24 : userData.distance??1;
    if(cartList.isEmpty) {
      return tripCost;
    }

    for (Carts cart in cartList) {
      double p = 0;
      if(rentalType == 'hourly') {
        p = cart.vehicle!.hourlyPrice! * cart.quantity!;
      } else if(rentalType == 'day_wise') {
        p = cart.vehicle!.dayWisePrice! * cart.quantity!;
      }else {
        p = cart.vehicle!.distancePrice! * cart.quantity!;
      }
      tripCost = tripCost + p;
    }
    tripCost = tripCost * distanceOrHour;

    return tripCost;
  }

  static double calculateDiscountCost(List<Carts> cartList, UserData userData, {required bool calculateProviderDiscount, double? tripCost}) {
    double tripDiscountCost = 0;
    double discountPrice = 0;
    String discountType = '';
    String rentalType = userData.rentalType!;
    double distanceOrHour = rentalType == 'hourly' ? userData.estimatedHours??1 : rentalType == 'day_wise' ? ((userData.estimatedHours ?? 0) / 24) : userData.distance??1;
    if(cartList.isEmpty) {
      return tripDiscountCost;
    }

    for (Carts cart in cartList) {
      double p = 0;
      if(cart.provider!.discount != null && calculateProviderDiscount && tripCost != null && cart.provider!.discount!.minPurchase! <= tripCost) {
        discountPrice = cart.provider!.discount!.discount!;
        discountType = cart.provider!.discount!.discountType!;
      } else {
        discountPrice = cart.vehicle!.discountPrice!;
        discountType = cart.vehicle!.discountType!;
      }

      if(rentalType == 'hourly') {
        p = PriceConverter.calculation(cart.vehicle!.hourlyPrice! * distanceOrHour, discountPrice, discountType, cart.quantity!);
      } else if(rentalType == 'day_wise') {
        p = PriceConverter.calculation(cart.vehicle!.dayWisePrice! * distanceOrHour, discountPrice, discountType, cart.quantity!);
      } else {
        p = PriceConverter.calculation(cart.vehicle!.distancePrice! * distanceOrHour, discountPrice, discountType, cart.quantity!);
      }

      tripDiscountCost = tripDiscountCost + p;
    }

    if(calculateProviderDiscount) {
      if (tripCost != null) {
        if (cartList[0].provider!.discount != null && cartList[0].provider!.discount!.minPurchase! <= tripCost &&
            cartList[0].provider!.discount!.maxDiscount! < tripDiscountCost) {
          tripDiscountCost = cartList[0].provider!.discount!.maxDiscount!;
        } else {
          tripDiscountCost = tripDiscountCost;
        }
      }

      else if (tripCost == null && cartList[0].provider!.discount != null &&
          cartList[0].provider!.discount!.maxDiscount! < tripDiscountCost) {
        tripDiscountCost = cartList[0].provider!.discount!.maxDiscount!;
      }
    }

    if(tripDiscountCost > 0) {
      return tripDiscountCost;
    } else {
      return 0;
    }
  }

  static double calculateDistanceWiseDiscount(VehicleModel vehicle, double discount, String discountType) {
    double distanceWiseDiscount = 0;
    double discount0 = discount;
    String discountType0 = discountType;

    distanceWiseDiscount = PriceConverter.calculation(vehicle.distancePrice!, discount0, discountType0, 1);

    if(vehicle.provider != null && vehicle.provider!.discount != null) {
      discount0 = vehicle.provider!.discount!.discount??0;
      discountType0 = vehicle.provider!.discount!.discountType ?? 'percent';

      distanceWiseDiscount = PriceConverter.calculation(vehicle.distancePrice!, discount, discountType, 1);

      if(vehicle.provider!.discount!.maxDiscount != 0 && vehicle.provider!.discount!.maxDiscount! < distanceWiseDiscount) {
        distanceWiseDiscount = vehicle.provider!.discount!.maxDiscount!;
      }
    }
    return distanceWiseDiscount;
  }

  static double calculateHourlyDiscount(VehicleModel vehicle, double discount, String discountType) {

    double hourlyDiscount = 0;
    double discount0 = discount;
    String discountType0 = discountType;

    hourlyDiscount = PriceConverter.calculation(vehicle.hourlyPrice!, discount0, discountType0, 1);

    if(vehicle.provider != null && vehicle.provider!.discount != null) {
      discount0 = vehicle.provider!.discount!.discount??0;
      discountType0 = vehicle.provider!.discount!.discountType ?? 'percent';

      hourlyDiscount = PriceConverter.calculation(vehicle.hourlyPrice!, discount0, discountType0, 1);

      if(vehicle.provider!.discount!.maxDiscount != 0 && vehicle.provider!.discount!.maxDiscount! < hourlyDiscount) {
        hourlyDiscount = vehicle.provider!.discount!.maxDiscount!;
      }
    }

    return hourlyDiscount;
  }

  static double getDiscountPrice(double providerDiscountPrice, double productDiscountPrice, double totalPrice) {
    double discountPrice = 0;
    if(providerDiscountPrice > productDiscountPrice) {
      discountPrice = providerDiscountPrice;
    } else if(productDiscountPrice > providerDiscountPrice) {
      discountPrice = productDiscountPrice;
    } else {
      discountPrice = productDiscountPrice;
    }
    return discountPrice > totalPrice ? totalPrice : discountPrice;
  }

  static double getExtraDiscountPrice(double providerDiscountPrice, double productDiscountPrice) {
    double extraDiscount = 0;
    if(providerDiscountPrice > productDiscountPrice) {
      extraDiscount = providerDiscountPrice - productDiscountPrice;
    } else if(productDiscountPrice > providerDiscountPrice) {
      extraDiscount = 0;
    } else {
      extraDiscount = 0;
    }
    return extraDiscount;
  }

}