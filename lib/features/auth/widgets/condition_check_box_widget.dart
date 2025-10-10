import 'package:flutter/gestures.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConditionCheckBoxWidget extends StatelessWidget {
  final bool forDeliveryMan;
  final bool forSignUp;
  const ConditionCheckBoxWidget({super.key, this.forDeliveryMan = false, this.forSignUp = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

      forDeliveryMan ? GetBuilder<DeliverymanRegistrationController>(builder: (dmRegController) {
        return GetBuilder<AuthController>(builder: (authController) {
          return Checkbox(
            activeColor: Theme.of(context).primaryColor,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            value: forSignUp ? authController.acceptTerms : dmRegController.acceptTerms,
            onChanged: (bool? isChecked) => forSignUp ? authController.toggleTerms() : dmRegController.toggleTerms(),
          );
        });
      }) : const SizedBox(),

      // Tanda * - font Poppins600, warna black, fontSize 13
      forDeliveryMan ? const SizedBox() : Text(
        '* ', 
        style: robotoMedium.copyWith(
          color: Colors.black,
          fontSize: 13,
        ),
      ),

      Flexible(
        child: RichText(
          text: TextSpan(children: [
            // Text 'i_agree_with_all_the' - font Poppins600, warna black, fontSize 13
            TextSpan(
              text: 'i_agree_with_all_the'.tr,
              style: robotoMedium.copyWith(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
              text: 'terms_conditions'.tr,
              style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
            ),
          ]),
        ),
      ),

    ]);
  }
}