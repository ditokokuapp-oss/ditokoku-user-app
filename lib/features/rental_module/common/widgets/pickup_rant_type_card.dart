import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_icon_layout.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/widgets/trip_type_bottom_sheet_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
class PickupRantTypeCard extends StatelessWidget {
  final TaxiLocationController taxiLocationController;
  final UserData? userData;
  const PickupRantTypeCard({super.key, required this.taxiLocationController, this.userData});

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

        const CustomIconLayout(height: 32, width: 32, icon: Icons.hourglass_empty_outlined),
        const SizedBox(width: Dimensions.paddingSizeDefault),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('rant_type'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              '${userData != null ? userData!.rentalType!.tr
                  : taxiLocationController.tripType.tr} '
                  '${(userData!.estimatedHours! > 0 && userData!.rentalType == 'hourly') ? '(${'estimated'.tr} ${userData?.estimatedHours} ${'hour'.tr})' : ''}',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
        ),

        CustomInkWell(
          onTap: () {
            Get.bottomSheet(
              TripTypeBottomSheetWidget(userData: userData),
              backgroundColor: Colors.transparent, isScrollControlled: true,
            );
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
