import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/extra_discount_view_widget.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/pickup_rant_type_card.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/pickup_time_card.dart';
import 'package:sixam_mart/features/rental_module/helper/taxi_price_helper.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_checkout_screen/taxi_checkout_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/taxi_location_screen.dart';
import 'package:sixam_mart/features/rental_module/vendor/screens/vendor_detail_screen.dart';
import 'package:sixam_mart/features/rental_module/widgets/trip_from_to_card.dart';
import 'package:sixam_mart/features/rental_module/widgets/vehicle_card.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class TaxiCartScreen extends StatefulWidget {
  final bool? fromSelectVehicleScreen;
  const TaxiCartScreen({super.key, this.fromSelectVehicleScreen = false});

  @override
  State<TaxiCartScreen> createState() => _TaxiCartScreenState();
}

class _TaxiCartScreenState extends State<TaxiCartScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<TaxiCartController>().getCarCartList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(title: 'cart'.tr),
      body: GetBuilder<TaxiCartController>(builder: (taxiCartController) {

        double totalPrice = 0;
        double discountPrice = 0;
        double extraDiscount = 0;

        String? rentalType = taxiCartController.carCartModel?.userData?.rentalType;

        double estimatedDay = 0;
        estimatedDay = (taxiCartController.carCartModel?.userData?.estimatedHours ?? 0) / 24;

        if(taxiCartController.cartList.isNotEmpty && taxiCartController.carCartModel != null && taxiCartController.carCartModel!.userData != null) {
          totalPrice = TaxiPriceHelper.calculateTripCost(taxiCartController.cartList, taxiCartController.carCartModel!.userData!);
          double productDiscountPrice = TaxiPriceHelper.calculateDiscountCost(taxiCartController.cartList, taxiCartController.carCartModel!.userData!, calculateProviderDiscount: false);
          double providerDiscountPrice = TaxiPriceHelper.calculateDiscountCost(taxiCartController.cartList, taxiCartController.carCartModel!.userData!, calculateProviderDiscount: true);

          extraDiscount = TaxiPriceHelper.getExtraDiscountPrice(providerDiscountPrice, productDiscountPrice);
          discountPrice = TaxiPriceHelper.getDiscountPrice(providerDiscountPrice, productDiscountPrice, totalPrice);

        }
        totalPrice = totalPrice - discountPrice;

        return taxiCartController.cartList.isNotEmpty ? Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text('trip_details'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                TripFromToCard(
                  fromAddress: AddressModel(address: taxiCartController.carCartModel?.userData?.pickupLocation?.locationName??'', addressType: taxiCartController.carCartModel?.userData?.pickupLocation?.locationType),
                  toAddress: AddressModel(address: taxiCartController.carCartModel?.userData?.destinationLocation?.locationName??'', addressType:  taxiCartController.carCartModel?.userData?.destinationLocation?.locationType),
                  fromCartOnClick: () {
                    Get.to(()=> TaxiLocationScreen(
                      fromAddress: AddressModel(
                        addressType: taxiCartController.carCartModel!.userData!.pickupLocation!.locationType,
                        address: taxiCartController.carCartModel!.userData!.pickupLocation!.locationName,
                        latitude: taxiCartController.carCartModel!.userData!.pickupLocation!.lat,
                        longitude: taxiCartController.carCartModel!.userData!.pickupLocation!.lng,
                      ),
                      toAddress: AddressModel(
                        addressType: taxiCartController.carCartModel!.userData!.destinationLocation!.locationType,
                        address: taxiCartController.carCartModel!.userData!.destinationLocation!.locationName,
                        latitude: taxiCartController.carCartModel!.userData!.destinationLocation!.lat,
                        longitude: taxiCartController.carCartModel!.userData!.destinationLocation!.lng,
                      ),
                      userData: taxiCartController.carCartModel!.userData,
                    ));
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                PickupTimeCard(
                  taxiLocationController: Get.find<TaxiLocationController>(),
                  userData: taxiCartController.carCartModel?.userData,
                  fromCart: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                //Rent type
                PickupRantTypeCard(
                  taxiLocationController: Get.find<TaxiLocationController>(),
                  userData: taxiCartController.carCartModel!.userData,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Align(
                  alignment: Alignment.topLeft,
                  child: Text('selected_vehicle'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                taxiCartController.cartList.isNotEmpty ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: taxiCartController.cartList.length,
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return VehicleCard(
                      vehicle: taxiCartController.cartList[index].vehicle!,
                      index: index, carts: taxiCartController.cartList[index],
                      isCartHourly: taxiCartController.carCartModel?.userData?.rentalType == 'hourly',
                      fromSelectVehicleScreen: widget.fromSelectVehicleScreen,
                    );
                  },
                ) : Center(child: Text('cart_is_empty'.tr)),

                Center(
                  child: InkWell(
                    onTap: (){
                      if(taxiCartController.cartList.isNotEmpty) {
                        Get.to(() => VendorDetailScreen(vendorId: taxiCartController.cartList[0].vehicle!.providerId));
                      } else {
                        Get.back();
                      }
                    },
                    child: Text('add_more_vehicle'.tr, style: robotoBold.copyWith(fontSize: 14, color: Theme.of(context).primaryColor)),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ]),
            ),
          ),

          ExtraDiscountViewWidget(extraDiscount: extraDiscount),

          Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 10)],
              color: Theme.of(context).cardColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Column(children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  '${rentalType == AppConstants.dayWise ? 'duration'.tr : 'estimated'.tr} ${rentalType == AppConstants.distanceWise
                      ? taxiCartController.carCartModel?.userData?.distance?.toStringAsFixed(3) ?? 0
                      : rentalType == AppConstants.dayWise ? estimatedDay.toStringAsFixed(0)
                      : taxiCartController.carCartModel?.userData?.estimatedHours??0}'
                      ' ${rentalType == AppConstants.distanceWise ? 'km'.tr : rentalType == AppConstants.dayWise ? 'day' : 'hrs'.tr}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                Text(PriceConverter.convertPrice(totalPrice, forTaxi: true), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              SafeArea(
                child: CustomButton(
                  buttonText: 'proceed_to_checkout'.tr,
                  onPressed: () {
                    taxiCartController.updateFirstTime();
                    Get.to(()=> const TaxiCheckoutScreen());
                  },
                ),
              ),
            ]),
          ),

        ]) : Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            const CustomAssetImageWidget(Images.taxiEmptyCart, height: 80),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text('your_cart_is_empty'.tr, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomButton(
              buttonText: 'explore_more'.tr,
              width: 200, height: 40,
              onPressed: () {
                Get.toNamed(RouteHelper.getInitialRoute());
              },
            ),

          ]),
        );
      }),
    );
  }

}
