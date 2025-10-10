import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_icon_layout.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import '../../../../../../util/styles.dart';
import '../../widgets/date_time_picker_sheet.dart';

class PickupTimeCard extends StatelessWidget {
  final TaxiLocationController taxiLocationController;
  final UserData? userData;
  final bool fromCart;
  const PickupTimeCard({super.key, required this.taxiLocationController, this.userData, this.fromCart = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(children: [

        const CustomIconLayout(height: 32, width: 32, icon: Icons.date_range_outlined),
        const SizedBox(width: Dimensions.paddingSizeDefault),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              taxiLocationController.finalTripDateTime != null ?
              DateConverter.isSameDate(taxiLocationController.finalTripDateTime!) || taxiLocationController.pickCurrentTime ? 'pickup_now'.tr : 'custom'.tr
                  : 'pick_time'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              userData != null ? DateConverter.dateTimeStringToDateTime(userData!.pickupTime!)
                  : taxiLocationController.finalTripDateTime != null
                  ? DateConverter.taxiDateTimeToString(taxiLocationController.finalTripDateTime!) : 'not_set_yet'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
        ),

        CustomInkWell(
          onTap: () {
            Get.bottomSheet(
              DateTimePickerSheet(fromCart: fromCart, userData: userData),
              backgroundColor: Colors.transparent, isScrollControlled: true,
            ).then((date) {
              if(fromCart) {
                if (kDebugMode) {
                  print('======Deleted date is: $date');
                }
              }
            });
          },
          radius: Dimensions.radiusSmall,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Image.asset(Images.taxiEditIcon, height: 20, width: 20),
          ),
        ),

      ]),
    );
  }
}