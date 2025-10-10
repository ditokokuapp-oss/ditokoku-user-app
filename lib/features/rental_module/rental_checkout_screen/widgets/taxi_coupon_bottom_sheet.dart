import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/widgets/coupon_card.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class CheckoutCouponBottomSheet extends StatefulWidget {
  const CheckoutCouponBottomSheet({super.key});

  @override
  State<CheckoutCouponBottomSheet> createState() => _CheckoutCouponBottomSheetState();
}

class _CheckoutCouponBottomSheetState extends State<CheckoutCouponBottomSheet> {
  @override
  void initState() {
    super.initState();

    if(Get.find<TaxiHomeController>().taxiCouponList == null) {
      Get.find<TaxiHomeController>().getTaxiCouponList(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
      ),
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: Column(children: [
        Container(width: 33, height: 4.0, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(23.0))),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtremeLarge),
            child: Text('available_promo'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
          ),

          Container(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Get.back(),
              child: Icon(Icons.close, size: Dimensions.fontSizeOverLarge, color: Colors.grey[300]),
            ),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // const CouponWidget(),

        Expanded(
          child: GetBuilder<TaxiHomeController>(
            builder: (taxiHomeController) {
              return taxiHomeController.taxiCouponList != null ? taxiHomeController.taxiCouponList!.isNotEmpty
                  ? Container(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                child: ListView.builder(
                  itemCount: taxiHomeController.taxiCouponList!.length,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {

                    return CouponCard(couponModel: taxiHomeController.taxiCouponList![index], fromCouponScreen: true, fromBottomSheet: true);

                  }),
              ) : Column(children: [
                Image.asset(Images.noCoupon, height: 70),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text('no_promo_available'.tr, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ]) : const Center(child: CircularProgressIndicator());
            },
          ),
        )
      ]),
    );
  }
}