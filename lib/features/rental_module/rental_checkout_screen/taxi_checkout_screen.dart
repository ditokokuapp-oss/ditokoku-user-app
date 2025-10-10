import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/extra_discount_view_widget.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/helper/taxi_price_helper.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_checkout_screen/widgets/checkout_vehicle_card.dart';
import 'package:sixam_mart/features/rental_module/rental_checkout_screen/widgets/taxi_coupon_bottom_sheet.dart';
import 'package:sixam_mart/features/rental_module/widgets/bill_details_widget.dart';
import 'package:sixam_mart/features/rental_module/rental_checkout_screen/widgets/checkout_terms_and_condition.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class TaxiCheckoutScreen extends StatefulWidget {

  const TaxiCheckoutScreen({super.key});

  @override
  State<TaxiCheckoutScreen> createState() => _TaxiCheckoutScreenState();
}

class _TaxiCheckoutScreenState extends State<TaxiCheckoutScreen> {
  TextEditingController couponTextController = TextEditingController();
  TextEditingController noteTextController = TextEditingController();

  TextEditingController guestNameTextEditingController = TextEditingController();
  TextEditingController guestNumberTextEditingController = TextEditingController();
  TextEditingController guestEmailController = TextEditingController();
  FocusNode guestNameNode = FocusNode();
  FocusNode guestNumberNode = FocusNode();
  FocusNode guestEmailNode = FocusNode();
  String? countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode ?? Get.find<LocalizationController>().locale.countryCode;
  double? _payableAmount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'checkout'.tr),
      body: GetBuilder<TaxiCartController>(builder: (taxiCartController) {
        return GetBuilder<TaxiLocationController>(builder: (taxiLocationController) {

          String rentalType = taxiCartController.carCartModel!.userData!.rentalType!;

          double estimatedDay = 0;
          estimatedDay = (taxiCartController.carCartModel?.userData?.estimatedHours ?? 0) / 24;

          int providerId = taxiCartController.cartList[0].provider!.id!;
          String schedule = taxiCartController.carCartModel!.userData!.pickupTime!;

          DateTime selectedTime = DateConverter.dateTimeStringToDate(schedule);
          String scheduleTime = DateConverter.formatDate(selectedTime);

          if(!DateConverter.isAfterCurrentDateTime(selectedTime)) {
            selectedTime = DateTime.now();
            scheduleTime = DateConverter.formatDate(DateTime.now());
          }
          bool isScheduled = !DateConverter.isSameDate(selectedTime);

          double tripCost = TaxiPriceHelper.calculateTripCost(taxiCartController.cartList, taxiCartController.carCartModel!.userData!);

          double productDiscountPrice = TaxiPriceHelper.calculateDiscountCost(taxiCartController.cartList, taxiCartController.carCartModel!.userData!, tripCost: tripCost, calculateProviderDiscount: false);
          double providerDiscountPrice = TaxiPriceHelper.calculateDiscountCost(taxiCartController.cartList, taxiCartController.carCartModel!.userData!, tripCost: tripCost, calculateProviderDiscount: true);
          double extraDiscount = TaxiPriceHelper.getExtraDiscountPrice(providerDiscountPrice, productDiscountPrice);
          double tripDiscount = TaxiPriceHelper.getDiscountPrice(providerDiscountPrice, productDiscountPrice, tripCost);

          double couponDiscount = taxiCartController.couponDiscount;
          double subtotal = tripCost - tripDiscount - couponDiscount;

          if(taxiCartController.isFirstTime){
            taxiCartController.getTripTax(tripAmount: subtotal, tripType: rentalType, providerId: providerId, couponCode: '', scheduleTime: scheduleTime, isSchedule: isScheduled);
          }

          double serviceFee = Get.find<SplashController>().configModel!.additionCharge??0;
          double total = subtotal + ((taxiCartController.taxIncluded == 1) ? 0 : taxiCartController.tripTax!) + serviceFee;

          if(_payableAmount != total && AuthHelper.isLoggedIn()) {
            _payableAmount = total;
            showCashBackSnackBar();
          }

          return Column(children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Column(children: [

                  //Selected Vehicle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Column(children: [

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                        Text('selected_vehicle'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

                        CustomInkWell(
                          onTap: ()=> Get.back(),
                          radius: Dimensions.radiusSmall,
                          child: Image.asset(Images.taxiEditIcon, height: 20, width: 20),
                        ),
                      ]),

                      ListView.builder(
                        itemCount: taxiCartController.cartList.length,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return CheckoutVehicleCard(cart: taxiCartController.cartList[index]);
                        },
                      ),
                    ]),
                  ),

                  Container(height: Dimensions.paddingSizeExtraSmall,
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  ),

                  if(AuthHelper.isGuestLoggedIn())
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('delivery_information'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),

                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        CustomTextField(
                          labelText: 'contact_person_name'.tr,
                          titleText: 'write_name'.tr,
                          inputType: TextInputType.name,
                          controller: guestNameTextEditingController,
                          focusNode: guestNameNode,
                          nextFocus: guestNumberNode,
                          capitalization: TextCapitalization.words,
                          required: true,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        CustomTextField(
                          labelText: 'contact_person_number'.tr,
                          titleText: 'write_number'.tr,
                          controller: guestNumberTextEditingController,
                          focusNode: guestNumberNode,
                          nextFocus: guestEmailNode,
                          inputType: TextInputType.phone,
                          isPhone: true,
                          required: true,
                          onCountryChanged: (CountryCode countryCode) {
                            countryDialCode = countryCode.dialCode;
                          },
                          countryDialCode: CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code ?? Get.find<LocalizationController>().locale.countryCode,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        CustomTextField(
                          titleText: 'enter_email'.tr,
                          labelText: 'email'.tr,
                          controller: guestEmailController,
                          focusNode: guestEmailNode,
                          inputAction: TextInputAction.done,
                          inputType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail,
                          required: true,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ]),
                    ),

                  if(AuthHelper.isLoggedIn())
                    Column(children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                            Text('promo_code'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),),

                            CustomInkWell(
                              onTap: () {
                                Get.bottomSheet(
                                  const CheckoutCouponBottomSheet(),
                                  backgroundColor: Colors.transparent, isScrollControlled: true,
                                ).then((val) {
                                  if(val != null) {
                                    couponTextController.text = val;
                                  }
                                });
                              },
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Text('${'add_voucher'.tr} +', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.grey),),
                            ),
                          ]),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                            child: SizedBox(height: 46,
                              child: TextField(
                                controller: couponTextController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.discount_outlined, size: Dimensions.fontSizeLarge,),
                                  hintText: 'enter_promo_code'.tr,
                                  hintStyle: robotoRegular.copyWith (color: Colors.grey[400], fontSize: Dimensions.fontSizeDefault),
                                  filled: true,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: !taxiCartController.isCouponLoading ? taxiCartController.couponDiscount <= 0 ? ElevatedButton(
                                      onPressed: () {
                                        taxiCartController.applyTaxiCoupon(couponTextController.text, subtotal, providerId).then((value) {
                                          taxiCartController.getTripTax(tripAmount: subtotal, tripType: rentalType, providerId: providerId, couponCode: couponTextController.text, scheduleTime: scheduleTime, isSchedule: isScheduled);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'apply'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      ),
                                    ) : InkWell(
                                      onTap: () {
                                        couponTextController.text = '';
                                        taxiCartController.removeCoupon(willUpdate: true);
                                      },
                                      child: const Icon(Icons.clear, color: Colors.red),
                                    ) : const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator()),
                                    ),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    borderSide: BorderSide(color:  Colors.grey[300]!, width: 1,),
                                  ),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1,),
                                  ),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5,),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 13),
                                ),
                              ),
                            ),
                          )
                        ]),
                      ),
                    ]),

                  Container(
                    height: Dimensions.paddingSizeExtraSmall,
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  ),

                  //Additional Notes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('additional_note'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),),

                      Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: CustomTextField(
                          controller: noteTextController,
                          titleText: 'ex_please_provide_good_conditioned_vehicle'.tr,
                          showLabelText: false,
                          maxLines: 3,
                          inputType: TextInputType.multiline,
                          inputAction: TextInputAction.done,
                          capitalization: TextCapitalization.sentences,
                        ),
                      )
                    ]),
                  ),

                  Container(
                    height: Dimensions.paddingSizeExtraSmall,
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  ),

                  //Bill Details
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                    child: BillDetailsWidget(
                      tripCost: tripCost, tripDiscountCost: tripDiscount, couponDiscountCost: couponDiscount,
                      subtotal: subtotal, vat: taxiCartController.tripTax!, serviceFee: serviceFee,
                      taxInclude: (taxiCartController.taxIncluded == 1), taxPercent: taxiCartController.cartList[0].provider!.tax,
                    ),
                  ),

                  //Terms & Condition
                  Container(height: 65,
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.02),
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('*', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Text('by_placing_the_booking_you_are_agreed_to_the'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),),

                          InkWell(
                            onTap: (){
                              Get.bottomSheet(
                                const CheckoutTermsAndCondition(),
                                backgroundColor: Colors.transparent, isScrollControlled: true,
                              );
                            },
                            child: Row(children: [
                              Text('terms_and_conditions'.tr, style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                                decorationColor: Theme.of(context).primaryColor,
                                decorationThickness: 1.5, // Adjust thickness
                                height: 1.5,
                              )),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Icon(Icons.info_outline, color: Theme.of(context).primaryColor, size: Dimensions.fontSizeSmall,)
                            ]),
                          )
                        ])
                      ]),
                    ),
                  ),
                ]),
              ),
            ),

            ExtraDiscountViewWidget(extraDiscount: extraDiscount),

            Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 10)],
                color: Theme.of(context).cardColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
              child: Column(children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    '${rentalType == AppConstants.dayWise ? 'duration'.tr : 'estimated'.tr} ${rentalType == AppConstants.distanceWise
                      ? taxiCartController.carCartModel?.userData?.distance?.toStringAsFixed(3) ?? 0
                      : rentalType == AppConstants.dayWise ? estimatedDay.toStringAsFixed(0)
                      : taxiCartController.carCartModel?.userData?.estimatedHours??0}'
                      ' ${rentalType == AppConstants.distanceWise ? 'km'.tr : rentalType == AppConstants.dayWise ? 'day' : 'hrs'.tr}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),

                  Text(PriceConverter.convertPrice(total), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                SafeArea(
                  child: CustomButton(
                    buttonText: 'confirm_booking'.tr,
                    isLoading: taxiCartController.isLoading,
                    onPressed: () async {
                      String numberWithCountryCode = countryDialCode! + guestNumberTextEditingController.text;
                      PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
                      numberWithCountryCode = phoneValid.phone;

                      if(AuthHelper.isGuestLoggedIn() && guestNameTextEditingController.text.isEmpty) {
                        guestNameNode.requestFocus();
                        showCustomSnackBar('please_enter_contact_person_name'.tr);
                      } else if(AuthHelper.isGuestLoggedIn() && guestNumberTextEditingController.text.isEmpty) {
                        guestNumberNode.requestFocus();
                        showCustomSnackBar('please_enter_contact_person_number'.tr);
                      } else if(AuthHelper.isGuestLoggedIn() && !phoneValid.isValid) {
                        showCustomSnackBar('invalid_phone_number'.tr);
                      } else if (AuthHelper.isGuestLoggedIn() && guestEmailController.text.isEmpty) {
                        guestEmailNode.requestFocus();
                        showCustomSnackBar('please_enter_contact_person_email'.tr);
                      } else {
                        DateTime selectedTime = DateConverter.dateTimeStringToDate(schedule);
                        String scheduleTime = DateConverter.formatDate(selectedTime);

                        if(!DateConverter.isAfterCurrentDateTime(selectedTime)) {
                          selectedTime = DateTime.now();
                          scheduleTime = DateConverter.formatDate(DateTime.now());
                        }
                        bool isScheduled = !DateConverter.isSameDate(selectedTime);

                        taxiCartController.tripBook(
                          tripAmount: total, tripType: rentalType, providerId: providerId, note: noteTextController.text,
                          guestName: guestNameTextEditingController.text, guestPhone: numberWithCountryCode,
                          guestEmail: guestEmailController.text, couponCode: taxiCartController.couponCode,
                          scheduleTime: scheduleTime, isSchedule: isScheduled,
                        );
                      }
                    },
                  ),
                ),
              ]),
            ),

          ]);
        });
      }),
    );
  }

  Future<void> showCashBackSnackBar() async {
    await Get.find<HomeController>().getCashBackData(_payableAmount!);
    double? cashBackAmount = Get.find<HomeController>().cashBackData?.cashbackAmount ?? 0;
    String? cashBackType = Get.find<HomeController>().cashBackData?.cashbackType ?? '';
    String text = '${'you_will_get'.tr} ${cashBackType == 'amount' ? PriceConverter.convertPrice(cashBackAmount) : '${cashBackAmount.toStringAsFixed(0)}%'} ${'cash_back_after_completing_order'.tr}';
    if(cashBackAmount > 0) {
      // showCustomSnackBar(text, isError: false);
    }
  }

}
