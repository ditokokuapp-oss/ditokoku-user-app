import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';
class DeliverymanView extends StatelessWidget {
  final List<VehicleIdentity>? vehicleIdentity;
  const DeliverymanView({super.key, required this.vehicleIdentity});

  @override
  Widget build(BuildContext context) {
    List<DriverData> dm = [];
    if(vehicleIdentity != null) {
      for (var d in vehicleIdentity!) {
        if(d.driverData != null) {
          dm.add(d.driverData!);
        }
      }
    }
    return dm.isNotEmpty ? Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('assigned_driver'.tr, style: robotoBold.copyWith(fontSize: 14)),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: dm.length,
              itemBuilder: (context, index) {
            return deliverymanCard(context, dm[index]);
          }),
        ],
      ),
    ) : const SizedBox();
  }

  Widget deliverymanCard(BuildContext context, DriverData data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(spacing: Dimensions.paddingSizeSmall, children: [

        SizedBox(
          height: 60, width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CustomImage(image: data.imageFullUrl??''),
          ),
        ),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.paddingSizeExtraSmall, children: [

            Text('${data.firstName} ${data.lastName}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 1, overflow: TextOverflow.ellipsis,),

            Text(data.phone??'', style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),

          ]),
        ),

        CustomInkWell(
          onTap: () async {
            if(await canLaunchUrlString('tel:${data.phone}')) {
              launchUrlString('tel:${data.phone}', mode: LaunchMode.externalApplication);
            }else {
              showCustomSnackBar('${'can_not_launch'.tr} ${data.phone}');
            }
          },
          child: Image.asset(Images.phoneOrderDetails, height: 30, width: 30),
        ),
      ]),
    );
  }
}

class DmData{
  String name;
  String phoneNumber;
  DmData(this.name, this.phoneNumber);
}