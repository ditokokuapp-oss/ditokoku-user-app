import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/widgets/coupon_card.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class TaxiCouponScreen extends StatefulWidget {
  const TaxiCouponScreen({super.key});

  @override
  State<TaxiCouponScreen> createState() => _TaxiCouponScreenState();
}

class _TaxiCouponScreenState extends State<TaxiCouponScreen> {
  @override
  void initState() {
    super.initState();

    if (AuthHelper.isLoggedIn()) {
      Get.find<TaxiHomeController>().getTaxiCouponList(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'coupon'.tr),
        backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<TaxiHomeController>(
        builder: (taxiHomeController) {
          return taxiHomeController.taxiCouponList != null ? taxiHomeController.taxiCouponList!.isNotEmpty
              ? ListView.builder(
                itemCount: taxiHomeController.taxiCouponList!.length,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                itemBuilder: (context, index) {
                  return CouponCard(couponModel: taxiHomeController.taxiCouponList![index], fromCouponScreen: true);
                },
              ) : Column(children: [
            Image.asset(Images.noCoupon, height: 70),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text('no_promo_available'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          ]) : const Center(child: CircularProgressIndicator());
        },
      )
    );
  }
}
