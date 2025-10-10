import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../../util/images.dart';

class ReferAndEarnCard extends StatelessWidget {
  const ReferAndEarnCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
      ),
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('refer_and_earn'.tr, style: robotoBold.copyWith(fontSize: 14),),
            const SizedBox(height: 5),

            Text('invite_friends_and_family_to_get'.tr, style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            GetBuilder<ProfileController>(
              builder: (profileController) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall),
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Theme.of(context).disabledColor, width: 0.2),
                    )
                  ),
                  onPressed: () {
                    if(AuthHelper.isLoggedIn()) {
                      Share.share(
                        Get.find<SplashController>().configModel?.appUrlAndroid != null ? '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
                            : '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode}',
                      );
                    }else {
                      showCustomSnackBar('you_are_not_logged_in_to_explore_feature'.tr);
                    }
                  },
                  child: Text('invite'.tr, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                );
              }
            )],
          ),
        ),

        Column(children: [
          Padding(padding: const EdgeInsets.all(8.0),
            child: Image.asset(Images.referIconNew, height: 80, width: 80,
            ),
          )],
        )],
      ),
    );
  }
}


