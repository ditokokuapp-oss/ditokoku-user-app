import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/rental_module/helper/cart_helper.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/features/rental_module/widgets/trip_type_card.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/widgets/trip_vehicle_list_dialog.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class TripTypeBottomSheetWidget extends StatefulWidget {
  final UserData? userData;
  const TripTypeBottomSheetWidget({super.key, this.userData});

  @override
  State<TripTypeBottomSheetWidget> createState() => _TripTypeBottomSheetWidgetState();
}

class _TripTypeBottomSheetWidgetState extends State<TripTypeBottomSheetWidget> {
  TextEditingController estimateTimeController = TextEditingController();
  TextEditingController estimateDayController = TextEditingController();

  @override
  void initState() {
    super.initState();

    estimateTimeController.text = '${widget.userData != null && widget.userData!.estimatedHours != null && widget.userData!.estimatedHours! > 0 ? widget.userData!.estimatedHours! : ''}';
    estimateDayController.text = widget.userData != null && widget.userData!.estimatedHours != null && widget.userData!.estimatedHours! > 0 ? (widget.userData!.estimatedHours! /24).toStringAsFixed(1) : '';

    if(widget.userData != null) {
      Get.find<TaxiCartController>().selectTripType(widget.userData?.rentalType??'hourly', willUpdate: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaxiLocationController>(builder: (taxiLocationController) {
      return GetBuilder<TaxiCartController>(builder: (taxiCartController) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 33, height: 4.0,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),

            //cross icon
            Container(
              padding: const EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Icon(Icons.close, size: 24, color: Colors.grey[300]),
              ),
            ),

            Text('edit_trip_type'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            SizedBox(
              height: 135,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  TripTypeCard(
                    tripType: 'distance_wise', distanceMinPrice: Get.find<SplashController>().configModel!.vehicleDistanceMinPrice??0, amount: '', discountAmount: '',
                    fareType: 'km', indicatorIcon: Icons.radio_button_off, isVehicleDetailScene: false, isClockIcon: false,
                    fromCart: widget.userData != null,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  TripTypeCard(
                    tripType: 'hourly', hourMinPrice: Get.find<SplashController>().configModel!.vehicleHourlyMinPrice ?? 0, amount: '', discountAmount: '', fareType: 'hr',
                    indicatorIcon: Icons.radio_button_checked, isVehicleDetailScene: false, isClockIcon: false,
                    fromCart: widget.userData != null,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  TripTypeCard(
                    tripType: 'day_wise', dailyMinPrice: Get.find<SplashController>().configModel!.vehicleDayWiseMinPrice ?? 0, amount: '', discountAmount: '',
                    fareType: 'day', indicatorIcon: Icons.radio_button_checked, isVehicleDetailScene: false, isClockIcon: false,
                    fromCart: widget.userData != null,
                  ),

                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            (widget.userData != null ? taxiCartController.tripType == 'hourly' : taxiLocationController.tripType == 'hourly') ? CustomTextField(
              controller: estimateTimeController,
              titleText: 'Ex: 5',
              inputType: TextInputType.number,
              labelText: 'estimate_time'.tr,
              isNumber: true,
            ) : (widget.userData != null ? taxiCartController.tripType == 'day_wise' : taxiLocationController.tripType == 'day_wise') ? CustomTextField(
              controller: estimateDayController,
              titleText: 'Ex: 5',
              inputType: TextInputType.number,
              labelText: 'estimate_days'.tr,
              isNumber: true,
            ) : const SizedBox(),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                child: GetBuilder<TaxiCartController>(builder: (taxiCartController) {
                  return Row(children: [

                    Expanded(
                      child: CustomButton(
                        buttonText: 'cancel'.tr,
                        color: Theme.of(context).disabledColor,
                        onPressed: ()=> Get.back(),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: CustomButton(
                        buttonText: 'update'.tr,
                        isLoading: taxiCartController.isLoading,
                        onPressed: () async {
                          String tripType = widget.userData != null ? taxiCartController.tripType : taxiLocationController.tripType;

                          if(tripType == 'hourly' && (estimateTimeController.text.isEmpty || double.parse(estimateTimeController.text) == 0)) {
                            showCustomSnackBar('please_enter_estimate_time'.tr, getXSnackBar: true);
                          } else if(tripType == 'day_wise' && (estimateDayController.text.isEmpty || double.parse(estimateDayController.text) == 0)){
                            showCustomSnackBar('please_enter_estimate_days'.tr, getXSnackBar: true);
                          } else {
                            bool isCartExistType = await CartHelper.checkTypeInCart(taxiCartController.cartList, tripType);
                            double? estimatedDay = (double.tryParse(estimateDayController.text) ?? 0) * 24;

                            CarCart cart = CarCart(
                              applyMethod: true, distance: widget.userData!.distance, destinationTime: widget.userData!.destinationTime,
                              rentalType: tripType,
                              estimatedHour: tripType == 'hourly' ? estimateTimeController.text : tripType == 'day_wise' ? estimatedDay.toStringAsFixed(1) : '${widget.userData!.estimatedHours??0}',
                            );

                            if(isCartExistType) {
                              taxiCartController.updateUserData(cart: cart, userId: widget.userData!.id!).then((success) async {
                                if(success) {
                                  await taxiCartController.getCarCartList();
                                  Get.back();
                                }
                              });
                            } else {
                              Get.back();
                              Get.dialog(TripVehicleListDialog(rentalType: tripType, cart: cart, userId: widget.userData!.id!));
                            }

                          }
                        },
                      ),
                    ),

                  ]);
                }),
              ),
            ),

          ]),
        );
      });
    });
  }
}
