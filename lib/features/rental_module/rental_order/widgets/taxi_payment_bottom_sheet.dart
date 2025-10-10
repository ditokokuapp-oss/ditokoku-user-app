import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class TaxiPaymentBottomSheet extends StatefulWidget {
  final int id;
  final double totalPrice;
  const TaxiPaymentBottomSheet({super.key, required this.totalPrice, required this.id});

  @override
  State<TaxiPaymentBottomSheet> createState() => _TaxiPaymentBottomSheetState();
}

class _TaxiPaymentBottomSheetState extends State<TaxiPaymentBottomSheet> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  bool? isCashOnDeliveryActive = Get.find<SplashController>().configModel!.cashOnDelivery;
  bool? isDigitalPaymentActive = Get.find<SplashController>().configModel!.digitalPayment;
  double walletBalance = 0;

  @override
  void initState() {
    super.initState();

    Get.find<TaxiOrderController>().setPaymentMethod(-1, isUpdate: false);
    if(Get.find<TaxiOrderController>().isPartialPay) {
      Get.find<TaxiOrderController>().changePartialPayment(isUpdate: false);
    }
    if(!AuthHelper.isGuestLoggedIn()) {
      walletBalance = Get.find<ProfileController>().userInfoModel!.walletBalance!;
      if(walletBalance < widget.totalPrice){
        canSelectWallet = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height*0.85, minHeight: 100),
      child: GetBuilder<TaxiOrderController>(
        builder: (taxiOrderController) {
          return Column(children: [

            Container(
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              width: 40, height: 4.0,
              decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(23.0)),
            ),

            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.close, size: 24, color: Theme.of(context).disabledColor),
              ),
            ),

            //title
            Text('choose_payment_method'.tr, style: robotoBold),

            Flexible(child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 17, right: 17),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [

                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, top: 13),
                        child: Text('total_trip_cost'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                      ),

                      Text(PriceConverter.convertPrice(widget.totalPrice), style: robotoMedium.copyWith(fontSize: 20, color: Theme.of(context).primaryColor)),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      //Wallet Balance
                      walletView(taxiOrderController),

                      //Cash Payment
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: CustomInkWell(
                          onTap: (){
                            taxiOrderController.setPaymentMethod(1);
                          },
                          radius: Dimensions.radiusDefault,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                            Text('cash_payment'.tr, style: robotoBold.copyWith(fontSize: 14)),

                            Icon(
                              taxiOrderController.paymentMethodIndex == 1 ? Icons.radio_button_checked : Icons.radio_button_off,
                              size: 24,
                              color: taxiOrderController.paymentMethodIndex == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                            ),
                          ]),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            child: Text('online_payment'.tr,  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          ),

                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                            itemBuilder: (context, index) {
                              bool isSelected = taxiOrderController.paymentMethodIndex == 2 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == taxiOrderController.digitalPaymentName;
                              return CustomInkWell(
                                onTap: (){
                                  taxiOrderController.setPaymentMethod(2);
                                  taxiOrderController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
                                  child: Row(children: [

                                    CustomImage(
                                      height: 20, fit: BoxFit.contain,
                                      image: Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl!,
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeDefault),

                                    Expanded(
                                      child: Text(
                                        Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                        overflow: TextOverflow.ellipsis, maxLines: 1,
                                      ),
                                    ),

                                    Icon(
                                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                      size: 24,
                                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                    ),
                                  ]),
                                ),
                              );
                            }),

                        ]),
                      ),

                    ]),
                  )
                ]),
              ),
            )),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: SafeArea(
                child: CustomButton(
                  buttonText: 'proceed'.tr,
                  isLoading: taxiOrderController.isLoading,
                  onPressed: taxiOrderController.paymentMethodIndex == -1 || (taxiOrderController.isPartialPay && taxiOrderController.paymentMethodIndex == 0) ? null : (){

                    taxiOrderController.makePayment(
                      id: widget.id,
                      paymentMethod: taxiOrderController.paymentMethodIndex == 0 && !taxiOrderController.isPartialPay ? 'wallet'
                          : taxiOrderController.isPartialPay ? 'partial_payment'
                          : taxiOrderController.paymentMethodIndex == 1 ? 'cash_payment'
                          : 'digital_payment',
                    ).then((success) {
                      if(success) {
                        Get.back(result: success);
                        taxiOrderController.getTripDetails(widget.id);
                      }
                    });
                  },
                ),
              ),
            ),

          ]);
        }
      ),
    );
  }

  Widget walletView(TaxiOrderController taxiOrderController) {
    double balance = 0;
    if(walletBalance <= 0) {
      return const SizedBox();
    }
    if(walletBalance > widget.totalPrice && taxiOrderController.paymentMethodIndex == 0) {
      balance = walletBalance - widget.totalPrice;
    }
    bool isWalletSelected = taxiOrderController.paymentMethodIndex == 0 || taxiOrderController.isPartialPay;
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(isWalletSelected ? 'wallet_remaining_balance'.tr : 'wallet_balance'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey.shade700)),

            Row(children: [
              Text(
                PriceConverter.convertPrice(isWalletSelected ? balance : walletBalance),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),

              Text(
                isWalletSelected ? ' (${'applied_wallet'.tr})' : '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
              ),
            ])
          ]),

          CustomInkWell(
            onTap: () {
              if(isWalletSelected) {
                taxiOrderController.setPaymentMethod(-1);
                if(taxiOrderController.isPartialPay) {
                  taxiOrderController.changePartialPayment();
                }
              } else {
                if(taxiOrderController.isPartialPay) {
                  taxiOrderController.changePartialPayment();
                }
                taxiOrderController.setPaymentMethod(0);
                if(walletBalance < widget.totalPrice) {
                  taxiOrderController.changePartialPayment();
                }
              }
            },
            radius: 5,
            child: isWalletSelected ? const Icon(Icons.clear, color: Colors.red) : Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: Text('apply'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).primaryColor)),
            ),
          ),
        ]),
      ),

      if(isWalletSelected && !taxiOrderController.isPartialPay)
        Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text('wallet_payment'.tr, style: robotoBold.copyWith(fontSize: 14)),
            Text(PriceConverter.convertPrice(widget.totalPrice), style: robotoMedium.copyWith(fontSize: 18))

          ]),
        ),


      if(isWalletSelected && taxiOrderController.isPartialPay)
        Column(children: [
          Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Column(children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text('wallet_payment'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                Text(PriceConverter.convertPrice(walletBalance), style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700))

              ]),
              const SizedBox(height: 5),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text('remaining_bill'.tr, style: robotoMedium.copyWith(fontSize: 14)),
                Text(PriceConverter.convertPrice(widget.totalPrice - walletBalance), style: robotoBold.copyWith(fontSize: 18)),

              ])
            ]),
          ),

          if(taxiOrderController.paymentMethodIndex == 0)
            Text('* ${'please_select_how_to_pay_remain_billing_amount'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFFE74B4B))),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]),


    ]);
  }
}
