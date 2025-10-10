import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_icon_layout.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_vertical_dotted_line.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/widgets/taxi_location_result_bottom_sheet.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class TripFromToCard extends StatelessWidget {
  final AddressModel fromAddress;
  final AddressModel toAddress;
  final bool showTitle;
  final String? searchName;
  final Function()? fromCartOnClick;
  const TripFromToCard({super.key, required this.fromAddress, required this.toAddress, this.showTitle = false, this.searchName, this.fromCartOnClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), width: 0.5),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        showTitle ? Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('trip_info'.tr, style: robotoBold),

            InkWell(
              onTap: () {
                Get.bottomSheet(
                  Container(
                    constraints: BoxConstraints(maxHeight: context.height * 0.8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge),)
                    ),
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                    child: TaxiLocationResultBottomSheet(searchName: searchName),
                  ),
                  backgroundColor: Colors.transparent, isScrollControlled: true,
                );
              },
              child: Image.asset(Images.taxiEditIcon, height: 20, width: 20),
            ),
          ]),
        ) : const SizedBox(),

        Row(children: [
          Padding(
            padding: EdgeInsets.only(right: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeSmall : 0 , left: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeSmall),
            child: const CustomIconLayout(height: 20, width: 20, icon: Icons.location_on_rounded),
          ),

          Expanded(
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  if(fromAddress.addressType != null && fromAddress.addressType!.isNotEmpty)
                    Text(fromAddress.addressType?.tr??'other'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),

                  Text(
                    fromAddress.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,/* color: Theme.of(context).disabledColor*/),
                  ),
                ]),
              ),

              fromCartOnClick != null ? Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                child: InkWell(
                  onTap: fromCartOnClick,
                  child: Image.asset(Images.taxiEditIcon, height: 20, width: 20),
                ),
              ) : const SizedBox(),

            ]),
          ),
        ]),

        Padding(
          padding: EdgeInsets.only(left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeDefault : 0, right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeDefault),
          child: const CustomVerticalDottedLine(),
        ),

        Row(children: [

          Padding(
            padding: EdgeInsets.only(right: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeSmall : 0 , left: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeSmall),
            child: const CustomIconLayout(height: 15, width: 15, iconImage: Images.navigationArrowIcon, paddingSize: 7),
          ),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              if(toAddress.addressType != null && toAddress.addressType!.isNotEmpty)
              Text(toAddress.addressType?.tr??'other'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),

              Text(
                toAddress.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall/*, color: Theme.of(context).disabledColor*/),
              ),
            ]),
          ),

          // Expanded(
          //     child: Text(toAddress.address??'', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
          // ),
        ]),

      ]),
    );
  }
}
