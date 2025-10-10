import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/util/dimensions.dart';

import '../../../util/images.dart';
import '../../../util/styles.dart';

class ConfirmBookingRequestBottomSheet extends StatelessWidget {

  final bool isScheduleBooking;
  final bool isBooking;

  const ConfirmBookingRequestBottomSheet({super.key, required this.isScheduleBooking, required this.isBooking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      padding: const EdgeInsets.only(top: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(width: 33, height: 4.0,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(23.0)),
        ),

        Container(padding: const EdgeInsets.only(right: 10, bottom: 15),
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {Get.back();},
            child: Icon(Icons.close, size: 24, color: Colors.grey[300]),
          ),
        ),

        Image.asset(Images.success, height: 60, width: 60),

        Padding(
          padding: const EdgeInsets.only(bottom: 17, top: 30),
          child: Text(isBooking ? 'booking_request_successful'.tr : 'schedule_booking_request_successful'.tr, style: robotoBold),
        ),

        Padding(padding: const EdgeInsets.symmetric(horizontal: 45,vertical: 10),
          child:
          isBooking? Text('${'your_vehicle_will_arrive_soon'.tr}\n${'to_know_other_info'.tr}',
            style: robotoRegular.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ) : Text('Your request has been submitted successfully. your preferable Vehicle will be arrived on time after confirmation.\n\n'
              'To know others information you may contact with provider from order details',
            style: robotoRegular.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: GetPlatform.isAndroid ? Dimensions.paddingSizeSmall : 0),
            child: CustomButton(
              buttonText: 'okay'.tr,
              width: 150, height: 40,
              onPressed: () => Get.back(),
            ),
          ),
        ),

      ]),
    );
  }
}
