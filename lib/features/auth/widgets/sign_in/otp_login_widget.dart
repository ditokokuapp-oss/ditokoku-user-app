import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/condition_check_box_widget.dart';
import 'package:sixam_mart/features/auth/widgets/social_login_widget.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class OtpLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final bool socialEnable;
  const OtpLoginWidget({
    super.key, 
    required this.phoneController, 
    required this.phoneFocus, 
    required this.onCountryChanged, 
    required this.countryDialCode,
    required this.onClickLoginButton, 
    this.socialEnable = false
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : 0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text('Daftar/Masuk dengan No. Whatsapp', style: robotoMedium.copyWith(fontSize: 14)),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextField(
            titleText: '812xxxxxxx'.tr,
            controller: phoneController,
            focusNode: phoneFocus,
            inputAction: TextInputAction.done,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: onCountryChanged,
            countryDialCode: countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
            labelText: 'phone'.tr,
            required: true,
            validator: (value) {
              // Cek jika field kosong
              String? emptyCheck = ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr);
              if (emptyCheck != null) {
                return emptyCheck;
              }
              
              // Cek jika nomor diawali dengan 0
              if (value != null && value.trim().startsWith('0')) {
                return 'Nomor tidak boleh diawali dengan 0';
              }
              
              return null;
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => authController.toggleRememberMe(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(
                      side: BorderSide(color: Theme.of(context).hintColor),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: Theme.of(context).primaryColor,
                      value: authController.isActiveRememberMe,
                      onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text('remember_me'.tr, style: robotoRegular),
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          const ConditionCheckBoxWidget(forSignUp: true),
          
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),

          CustomButton(
            buttonText: 'login'.tr,
            radius: Dimensions.radiusDefault,
            isBold: isDesktop ? false : true,
            isLoading: authController.isLoading,
            onPressed: onClickLoginButton,
            fontSize: isDesktop ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Mode Pengunjung / Guest Mode
          InkWell(
            onTap: () async {
              if(ResponsiveHelper.isDesktop(Get.context)) {
                Get.back();
                await Get.find<AuthController>().guestLogin();
                Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
              } else {
                await Get.find<AuthController>().guestLogin();
                Get.find<LocationController>().navigateToLocationScreen('guest-login', offNamed: true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    'Mode Pengunjung',
                    style: robotoMedium.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

        ]),
      );
    });
  }
}