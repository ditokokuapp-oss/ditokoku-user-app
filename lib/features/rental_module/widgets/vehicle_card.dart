import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/quantity_button.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/new_tag.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/taxi_add_favourite_view.dart';
import 'package:sixam_mart/features/rental_module/helper/cart_helper.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/vehicle_details_screen/vehicle_details_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/features/rental_module/widgets/featured_item.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/string_extension.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class VehicleCard extends StatefulWidget {
  final VehicleModel vehicle;
  final Carts? carts;
  final int index;
  final bool fromFavourite;
  final bool? isCartHourly;
  final bool? fromSelectVehicleScreen;
  final bool isWished;
  const VehicleCard({super.key, required this.vehicle, this.carts, required this.index, this.fromFavourite = false, this.isCartHourly, this.fromSelectVehicleScreen = false, this.isWished = false});

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  bool isInfoExpanded = false;

  @override
  Widget build(BuildContext context) {
    double discount = widget.vehicle.discountPrice ?? 0;
    String discountType = widget.vehicle.discountType ?? 'percent';
    bool tripHourly = widget.vehicle.tripHourly ?? false;
    bool tripDayWise = widget.vehicle.tripDayWise ?? false;
    double priceWithoutDiscount = 0;
    double hourlyDiscount = PriceConverter.calculation(widget.vehicle.hourlyPrice!, discount, discountType, 1);
    double distanceWiseDiscount = PriceConverter.calculation(widget.vehicle.distancePrice!, discount, discountType, 1);
    double dayWiseDiscount = PriceConverter.calculation(widget.vehicle.dayWisePrice!, discount, discountType, 1);

    if(widget.fromSelectVehicleScreen!) {
      tripHourly = Get.find<TaxiLocationController>().tripType == 'hourly';
      tripDayWise = Get.find<TaxiLocationController>().tripType == 'day_wise';
    }

    if(widget.isCartHourly != null) {
      tripHourly = widget.isCartHourly!;
      tripDayWise = widget.isCartHourly!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), width: 0.5),
      ),
      child: CustomInkWell(
        onTap: () {
          Get.to(() => VehicleDetailsScreen(vehicleId: widget.vehicle.id!, fromSelectVehicleScreen: widget.fromSelectVehicleScreen));
        },
        radius: Dimensions.radiusDefault,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            widget.isWished ? Text(widget.vehicle.name??'', style: robotoMedium.copyWith(fontSize: 14, fontWeight: FontWeight.bold,), textAlign: TextAlign.left)
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.carts != null ? widget.carts?.provider?.name??'' : widget.vehicle.provider?.name??'', style: robotoRegular.copyWith(color: Colors.grey, fontSize: 10,), textAlign: TextAlign.left,),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(widget.vehicle.name??'', style: robotoMedium.copyWith(fontSize: 14, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                widget.vehicle.avgRating! > 0 ? FeatureItem(image: Images.taxiStarIcon, text: '${widget.vehicle.avgRating?.toStringAsFixed(1)}', iconColor: Colors.amber) : const SizedBox(),
                SizedBox(width:  widget.vehicle.avgRating! > 0 ? 16 : 0),

                FeatureItem(image: Images.taxiACIcon, text: widget.vehicle.airCondition! ? 'ac'.tr : 'non_ac'.tr, iconColor: Colors.grey),
                const SizedBox(width: 16),

                FeatureItem(image: Images.taxiAutomaticIcon, text: '${widget.vehicle.type?.toTitleCase()}', iconColor: Colors.grey),
                const SizedBox(width: 16),

                FeatureItem(image: Images.taxiSeatIcon, text: '${widget.vehicle.seatingCapacity??0} ${'seats'.tr}', iconColor: Colors.grey),
                const SizedBox(width: 16),

                FeatureItem(image: Images.taxiPetrolIcon, text: '${widget.vehicle.fuelType?.toTitleCase()}', iconColor: Colors.grey),

              ])),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Expanded(
              child: Stack(children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: CustomImage(image: widget.vehicle.thumbnailFullUrl??'', fit: BoxFit.cover, width: double.infinity,),
                ),

                DiscountTag(
                  fromTop: 0, fromTaxi: true, fontSize: Dimensions.fontSizeExtraSmall,
                  discount: discount, discountType: discountType,
                  freeDelivery: false, isFloating: false,
                ),

                Positioned(
                  left: 0, top: 25,
                  child: NewTag(isNew: widget.vehicle.newTag),
                ),

                if(widget.vehicle.vehicleIdentitiesCount != null && widget.vehicle.vehicleIdentitiesCount! > 1)
                Positioned(
                  bottom: 20, right: 5,
                  child: Row(children: [
                    AnimatedContainer(
                      width: isInfoExpanded ? 125 : 25,
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                '${widget.vehicle.vehicleIdentitiesCount??0} ${'vehicles_available'.tr}',
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                              ),
                            ),
                          ),

                          InkWell(
                            highlightColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                isInfoExpanded = !isInfoExpanded;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                              child: const Icon(Icons.info, size: 22, color: Color(0xFF8891F5)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 10),

            GetBuilder<TaxiCartController>(builder: (taxiCartController) {
              int isExistInCartPosition = taxiCartController.isExistInCart(widget.vehicle.id);
              int quantity = 1;
              int cartId = 0;
              if(isExistInCartPosition != -1) {
                quantity = taxiCartController.getCartQuantity(isExistInCartPosition);
                cartId = taxiCartController.getCartId(isExistInCartPosition)??0;
                tripHourly = taxiCartController.carCartModel?.userData?.rentalType == 'hourly';
                tripDayWise = taxiCartController.carCartModel?.userData?.rentalType == 'day_wise';
              }
              priceWithoutDiscount = (tripHourly ? widget.vehicle.hourlyPrice??0 : tripDayWise ? widget.vehicle.dayWisePrice ?? 0 : widget.vehicle.distancePrice??0);
              double totalDiscountPrice = tripHourly ? hourlyDiscount : tripDayWise ? dayWiseDiscount : distanceWiseDiscount;

              return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  discountType == 'amount' ? const SizedBox() : Text(
                    PriceConverter.convertPrice(priceWithoutDiscount, forTaxi: true),
                    style: robotoRegular.copyWith (fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough, decorationColor: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                  ),
                  SizedBox(height: discountType == 'amount' ? 0 : 2),

                  Row(children: [
                    discountType == 'amount' ? Text(
                      PriceConverter.convertPrice(priceWithoutDiscount, forTaxi: true),
                      style: robotoBold.copyWith (color: Theme.of(context).primaryColor),
                    ) : Text(
                      PriceConverter.convertPrice(priceWithoutDiscount - totalDiscountPrice, forTaxi: true),
                      style: robotoBold.copyWith (color: Theme.of(context).primaryColor),
                    ),

                    Text(tripHourly ? ' /${'hr'.tr}' : tripDayWise ? ' /${'day'.tr}' : ' /${'km'.tr}', style: robotoMedium.copyWith (fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                  ]),
                ]),

               widget.fromFavourite ? TaxiAddFavouriteView(
                 favIconSize: 25,
                 vehicle: widget.vehicle,
               ) : isExistInCartPosition == -1 ? CustomButton(
                 buttonText: 'rent_this'.tr,
                 width: 100, height: 40,
                 // isLoading: taxiCartController.isLoading,
                 onPressed: () async {

                   TaxiLocationController locationController = Get.find<TaxiLocationController>();
                   CartLocation pick = CartLocation(lat: locationController.fromAddress!.latitude, lng: locationController.fromAddress!.longitude, locationName: locationController.fromAddress!.address, locationType: locationController.fromAddress!.addressType);
                   CartLocation destination = CartLocation(lat: locationController.toAddress!.latitude, lng: locationController.toAddress!.longitude, locationName: locationController.toAddress!.address, locationType: locationController.toAddress!.addressType);

                   CarCart cart = CarCart(
                     vehicleId: widget.vehicle.id, quantity: 1, pickupLocation: pick, destinationLocation: destination,
                     pickupTime: DateConverter.formatDate(locationController.finalTripDateTime!),
                     rentalType: locationController.tripType, estimatedHour: CartHelper.calculateHour(tripType: locationController.tripType, time: locationController.estimateTimeController.text, day: locationController.estimateDayController.text) ,
                     destinationTime: locationController.duration, distance: locationController.distance,
                   );
                   if(taxiCartController.cartList.isNotEmpty) {
                     taxiCartController.decideAddToCart(taxiCartController, cart, widget.vehicle, selectedLocationRentalType: locationController.tripType);
                   } else {
                     await taxiCartController.addToCart(cart);
                   }
                 },
               ) : Padding(
                 padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault+2),
                 child: Row(children: [
                   QuantityButton(
                     onTap: taxiCartController.isLoading ? (){} : () {
                       if (quantity > 1) {
                         manageCartQuantity(false, isExistInCartPosition, stock: widget.vehicle.vehicleIdentitiesCount);
                       }else {
                         taxiCartController.removeFromCart(cartId);
                       }
                     },
                     isIncrement: false,
                     showRemoveIcon: quantity == 1,
                   ),

                   Text(
                     quantity.toString(),
                     style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                   ),

                   QuantityButton(
                     onTap: taxiCartController.isLoading ? (){} : () {
                       manageCartQuantity(true, isExistInCartPosition, stock: widget.vehicle.vehicleIdentitiesCount);
                     },
                     isIncrement: true,
                     color: taxiCartController.isLoading || quantity == widget.vehicle.vehicleIdentitiesCount ? Theme.of(context).disabledColor : null,
                   ),
                 ]),
               ),

            ]);
            }),
          ]),
        ),
      ),
    );
  }

  void manageCartQuantity(bool isIncrement, int cartIndex, {int? count, int? stock}) {
    TaxiLocationController locationController = Get.find<TaxiLocationController>();
    TaxiCartController cartController = Get.find<TaxiCartController>();
    UserData userData = cartController.carCartModel!.userData!;

    if(widget.carts == null && locationController.tripType == 'hourly' && locationController.tripType == userData.rentalType && userData.estimatedHours != double.parse(locationController.estimateTimeController.text)) {

      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: 'do_you_want_to_change_trip_duration'.tr,
        description: '${'are_you_sure_you_want_to_update_trip_duration_to'.tr} ${CartHelper.calculateHour(tripType: locationController.tripType, time: locationController.estimateTimeController.text, day: locationController.estimateDayController.text)} ${'hours'.tr}',
        onYesPressed: () async {
          Get.back();
          CarCart userInfo = CarCart(
            applyMethod: true, distance: userData.distance, destinationTime: userData.destinationTime,
            rentalType: locationController.tripType, estimatedHour: CartHelper.calculateHour(tripType: locationController.tripType, time: locationController.estimateTimeController.text, day: locationController.estimateDayController.text),
          );

          cartController.updateUserData(cart: userInfo, userId: userData.id!).then((success) async {
            if(success) {
              cartController.setQuantity(isIncrement, cartIndex, stock: widget.vehicle.vehicleIdentitiesCount);
            }
          });
        },
      ));
    }
    else if(widget.carts == null && locationController.tripType != userData.rentalType) {
      TaxiLocationController locationController = Get.find<TaxiLocationController>();
      CartLocation pick = CartLocation(lat: locationController.fromAddress!.latitude, lng: locationController.fromAddress!.longitude, locationName: locationController.fromAddress!.address, locationType: locationController.fromAddress!.addressType);
      CartLocation destination = CartLocation(lat: locationController.toAddress!.latitude, lng: locationController.toAddress!.longitude, locationName: locationController.toAddress!.address, locationType: locationController.toAddress!.addressType);

      CarCart cart = CarCart(
        vehicleId: widget.vehicle.id, quantity: 1, pickupLocation: pick, destinationLocation: destination,
        pickupTime: DateConverter.formatDate(locationController.finalTripDateTime!),
        rentalType: locationController.tripType, estimatedHour: CartHelper.calculateHour(tripType: locationController.tripType, time: locationController.estimateTimeController.text, day: locationController.estimateDayController.text),
        destinationTime: locationController.duration, distance: locationController.distance,
      );

      cartController.decideAddToCart(cartController, cart, widget.vehicle, selectedLocationRentalType: locationController.tripType, isIncrement: isIncrement, cartIndex: cartIndex);

    }
    else {
      cartController.setQuantity(isIncrement, cartIndex, stock: widget.vehicle.vehicleIdentitiesCount);
    }

  }
}