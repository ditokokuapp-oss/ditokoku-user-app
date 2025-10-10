import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import '../../../../../util/styles.dart';
import '../../../util/dimensions.dart';

class TripTypeCard extends StatelessWidget {
  final String tripType;
  final String amount;
  final String discountAmount;
  final String fareType;
  final IconData indicatorIcon;
  final bool isVehicleDetailScene;
  final bool isClockIcon;
  final bool fromVehicleDetails;
  final bool? haveVehicle;
  final double? distanceMinPrice;
  final double? hourMinPrice;
  final double? dailyMinPrice;
  final bool? fromCart;
  final String? discountType;

  const TripTypeCard({
    super.key, required this.tripType, required this.amount, required this.discountAmount, required this.fareType, required this.indicatorIcon,
    required this.isVehicleDetailScene, required this.isClockIcon, this.fromVehicleDetails = false, this.haveVehicle = false, this.distanceMinPrice, this.hourMinPrice,
    this.fromCart = false, this.dailyMinPrice, this.discountType,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaxiCartController>(builder: (taxiCartController) {
      return GetBuilder<TaxiLocationController>(builder: (taxiController) {
        
        bool isSelected = fromCart! ? taxiCartController.tripType == tripType : taxiController.tripType == tripType;

        return Container(
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), width: 1),
            boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 10)] : null,
          ),
          child: CustomInkWell(
            radius: Dimensions.radiusDefault,
            onTap: fromVehicleDetails ? null : () => fromCart! ? taxiCartController.selectTripType(tripType) : taxiController.selectTripType(tripType),
            child: Column(children: [

              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), width: 1),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Text(tripType.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),

                  fromVehicleDetails ? const SizedBox() : Icon(isSelected ? Icons.radio_button_on : Icons.radio_button_off_outlined,
                    size: 22, color: isSelected ? Theme.of(context).primaryColor: Theme.of(context).disabledColor,
                  ),

                ]),
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                alignment: Alignment.centerLeft,
                child: haveVehicle! ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  RichText(text: TextSpan(children: <TextSpan>[
                    TextSpan(text: '${'start_from'.tr} ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color)),

                    discountType == 'amount' ? const TextSpan() :
                    TextSpan(text: discountAmount == amount ? '' : amount, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough)),
                  ])),

                  RichText(text: TextSpan(children: <TextSpan>[
                    TextSpan(text: ' ${discountType == 'amount' ? amount : discountAmount}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),

                    TextSpan(text: ' /${fareType.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color)),
                  ])),
                ]) : RichText(text: TextSpan(children: <TextSpan>[
                  TextSpan(text: '${'start_from'.tr} \n', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color)),

                  TextSpan(text: PriceConverter.convertPrice(dailyMinPrice ?? distanceMinPrice ?? hourMinPrice), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),

                  TextSpan(text: ' /${fareType.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color)),
                ])),
              )
            ]),
          ),
        );
      });
    });
  }
}