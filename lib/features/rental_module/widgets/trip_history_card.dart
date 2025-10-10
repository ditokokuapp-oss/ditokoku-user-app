import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/taxi_location_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_order/screens/taxi_order_details_screen.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class TripHistoryCard extends StatelessWidget {
  final TripDetailsModel trip;
  const TripHistoryCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      margin: const EdgeInsets.only(bottom: 10, right: 18, left: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: CustomInkWell(
        onTap: () {
          Get.to(()=> TaxiOrderDetailsScreen(tripId: trip.id!));
        },
        radius: Dimensions.radiusLarge,
        padding: EdgeInsets.only(right: Get.find<LocalizationController>().isLtr ? 15 : 0, top: 9, bottom: 9),
        child: Row(children: [
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Container(
            height: 80, width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).cardColor, width: 2),
              boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 5, offset: const Offset(0.005, 0.005))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomImage(image: trip.provider?.logoFullUrl??''),
              // child: Image.asset(trip.provider!.logoFullUrl??'', fit: BoxFit.cover,),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.destinationLocation?.locationName??'',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text(DateConverter.containTAndZToUTCFormat(trip.updatedAt!), style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey.shade700),),
                    Text('${PriceConverter.convertPrice(trip.tripAmount??0)} | ${trip.estimatedHours!>0 ? '${trip.estimatedHours?.toStringAsFixed(3)} ${'hrs'.tr}' : '${trip.distance?.toStringAsFixed(3)} ${'km'.tr}'}',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 1,overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: Get.find<LocalizationController>().isLtr ? 1 : 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: CustomInkWell(
                  onTap: () {
                    AddressModel from = AddressModel(address: trip.pickupLocation!.locationName, latitude: trip.pickupLocation!.lat.toString(), longitude: trip.pickupLocation!.lng.toString());
                    AddressModel to = AddressModel(address: trip.destinationLocation!.locationName, latitude: trip.destinationLocation!.lat.toString(), longitude: trip.destinationLocation!.lng.toString());
                    Get.to(()=> TaxiLocationScreen(fromAddress: from, toAddress: to));
                  },
                  child: Image.asset(Images.undoIcon, height: 20, width: 20),
                ),
              ),
            )],
        ),
      ),
    );
  }
}
