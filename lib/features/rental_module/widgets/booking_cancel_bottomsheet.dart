import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

import '../../../util/images.dart';
import '../../../util/styles.dart';

class BookingCancelBottomSheet extends StatelessWidget {
  final int tripId;
  const BookingCancelBottomSheet({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(width: 33, height: 4.0,
          margin: const EdgeInsets.only(top: 17),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(23.0),),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Icon(Icons.close, size: 24, color: Colors.grey[300],),
              ),
            ),

            Image.asset(Images.cancellationIcon, width: 55, height: 55,),

            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 10, right: 30, left: 30),
              child: Text('are_you_sure_want_to_cancel_the_booking'.tr, style: robotoBold.copyWith(fontSize: 16), textAlign: TextAlign.center),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text('once_you_cancel_the_booking_vendor_will_no_longer_get_the_booking_request_for_this_trip'.tr,
                style: robotoRegular.copyWith(fontSize: 12), textAlign: TextAlign.center,
              ),
            ),

            //Button
            Padding(
              padding: const EdgeInsets.only(bottom: 21, top: 30),

              child: SafeArea(
                child: GetBuilder<TaxiOrderController>(
                  builder: (taxiOrderController) {
                    return !taxiOrderController.isLoading ? Row(spacing: Dimensions.paddingSizeLarge, children: [

                      Expanded(
                        child: CustomButton(
                          buttonText: 'yes_cancel'.tr,
                          height: 40,
                          radius: Dimensions.radiusSmall,
                          onPressed: (){
                            taxiOrderController.cancelTrip(id: tripId).then((success) {
                              if(success) {
                                Get.back();
                                Get.back();
                                if(AuthHelper.isLoggedIn()) {
                                  taxiOrderController.getTripList(1);
                                }
                              }
                            });
                          },
                        ),
                      ),
                      // TaxiCommonButton(label: 'Yes, Cancel', color: Theme.of(context).primaryColor, onPressed: (){}, minHeight: 40, minWidth: 175),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade50,
                            minimumSize: const Size(175, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: BorderSide(color: Colors.grey.shade50, width: 1)),
                          ),
                          child: Text('not_now'.tr, style: robotoBold.copyWith(color: Colors.grey.shade700, fontSize: 14)),
                        ),
                      ),
                    ]) : const Center(child: CircularProgressIndicator());
                  }
                ),
              ),
            )
          ]),
        ),
      ]),
    );
  }
}
