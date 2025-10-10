import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/widgets/trip_from_to_card.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/pickup_time_card.dart';
import 'package:sixam_mart/features/rental_module/widgets/trip_type_card.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class TaxiLocationResultBottomSheet extends StatefulWidget {
  final VehicleModel? vehicle;
  final String? searchName;
  const TaxiLocationResultBottomSheet({super.key, this.vehicle, this.searchName});

  @override
  State<TaxiLocationResultBottomSheet> createState() => _TaxiLocationResultBottomSheetState();
}

class _TaxiLocationResultBottomSheetState extends State<TaxiLocationResultBottomSheet> {

  bool showTripTypeHourly = true;
  bool showTripTypeDistance = true;
  bool showTripTypeDay = true;

  @override
  void initState() {
    super.initState();
    Get.find<TaxiLocationController>().setTripDate(DateTime.now(), willUpdate: false);
    Get.find<TaxiLocationController>().setTripTime(DateTime.now(), willUpdate: false);
    Get.find<TaxiLocationController>().takeCurrentTime(true, willUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    double discount = 0;
    String discountType = 'percent';

    if(widget.vehicle != null) {
      showTripTypeHourly = widget.vehicle!.tripHourly!;
      showTripTypeDistance = widget.vehicle!.tripDistance!;
      showTripTypeDay = widget.vehicle!.tripDayWise!;

      discount = widget.vehicle!.discountPrice ?? 0;
      discountType = widget.vehicle!.discountType ?? 'percent';

      if(widget.vehicle!.provider != null && widget.vehicle!.provider!.discount != null) {
        discount = widget.vehicle!.provider!.discount!.discount??0;
        discountType = widget.vehicle!.provider!.discount!.discountType??'percent';
      }
    }

    return GetBuilder<TaxiLocationController>(builder: (taxiLocationController) {
      return Column(
        children: [

          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const SizedBox(),
              Container(
                height: 5, width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
              ),

              InkWell(
                onTap: ()=> Get.back(),
                child: Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: Icon(Icons.clear, color: Theme.of(context).disabledColor),
                ),
              ),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    border: Border.all(color: Colors.black, width: 0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),

                    child: SizedBox(
                      height: 200, width: context.width * 0.9,
                      child: Image.memory(taxiLocationController.mapScreenshot!, scale: 1.0, fit: BoxFit.fitWidth),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                        Text('trip_location'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                        CustomInkWell(
                          onTap: () {
                            Get.back();
                            Get.back();
                            Get.back();
                          },
                          radius: Dimensions.radiusSmall,
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Image.asset(Images.taxiEditIcon, height: 20, width: 20),
                          ),
                        ),

                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    TripFromToCard(fromAddress: taxiLocationController.fromAddress!, toAddress: taxiLocationController.toAddress!),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Text("pickup_time".tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    PickupTimeCard(taxiLocationController: taxiLocationController),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Text("trip_type".tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    SizedBox(
                      height: 130,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Row(children: [

                          showTripTypeDistance ? TripTypeCard(
                            tripType: 'distance_wise', amount: PriceConverter.convertPrice(widget.vehicle?.distancePrice??0), discountAmount: PriceConverter.convertPrice(widget.vehicle?.distancePrice??0, discount: discount, discountType: discountType),
                            fareType: 'km', indicatorIcon: Icons.radio_button_off, isVehicleDetailScene: false, isClockIcon: false,
                            haveVehicle: widget.vehicle != null, distanceMinPrice: Get.find<SplashController>().configModel!.vehicleDistanceMinPrice??0,
                            discountType: discountType,
                          ) : const SizedBox(),

                          SizedBox(width: showTripTypeDistance ? Dimensions.paddingSizeDefault : 0),

                          showTripTypeHourly ? TripTypeCard(
                            tripType: 'hourly', amount: PriceConverter.convertPrice(widget.vehicle?.hourlyPrice??0), discountAmount: PriceConverter.convertPrice(widget.vehicle?.hourlyPrice??0, discountType: discountType, discount: discount),
                            fareType: 'hr', indicatorIcon: Icons.radio_button_checked, isVehicleDetailScene: false,
                            isClockIcon: false, haveVehicle: widget.vehicle != null, hourMinPrice: Get.find<SplashController>().configModel!.vehicleHourlyMinPrice??0,
                            discountType: discountType,
                          ) : const SizedBox(),

                          SizedBox(width: showTripTypeDistance || showTripTypeDistance ? Dimensions.paddingSizeDefault : 0),

                          showTripTypeDay ? TripTypeCard(
                            tripType: 'day_wise', amount: PriceConverter.convertPrice(0), discountAmount: (widget.vehicle != null ? PriceConverter.convertPrice(widget.vehicle!.hourlyPrice! - 0) : ''),
                            fareType: 'day', indicatorIcon: Icons.radio_button_checked, isVehicleDetailScene: false,
                            isClockIcon: false, haveVehicle: widget.vehicle != null, dailyMinPrice: Get.find<SplashController>().configModel!.vehicleDayWiseMinPrice??0,
                            discountType: discountType,
                          ) : const SizedBox(),
                        ]),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    taxiLocationController.tripType == 'hourly' ? CustomTextField(
                      controller: taxiLocationController.estimateTimeController,
                      titleText: 'Ex: 5',
                      labelText: '${'estimate_time'.tr}(${'hrs'.tr})',
                      isNumber: true,
                      inputType: TextInputType.number,
                    ) : const SizedBox(),

                    SizedBox(height: taxiLocationController.tripType == 'hourly' ? Dimensions.paddingSizeExtraLarge : 0),

                    taxiLocationController.tripType == 'day_wise' ? CustomTextField(
                      controller: taxiLocationController.estimateDayController,
                      titleText: 'Ex: 2 days',
                      labelText: 'estimate_days'.tr,
                      isNumber: true,
                      inputType: TextInputType.number,
                    ) : const SizedBox(),
                    SizedBox(height: taxiLocationController.tripType == 'day_wise' ? Dimensions.paddingSizeExtraLarge : 0),
                  ]),
                ),
              ]),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 10)],
              color: Theme.of(context).cardColor,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: SafeArea(
              child: GetBuilder<TaxiCartController>(builder: (taxiCartController) {
                return !taxiCartController.isLoading ? CustomButton(
                  buttonText: widget.vehicle != null ? 'add_to_cart'.tr : 'confirm_and_search_vehicle'.tr,
                  onPressed: () async {
                    if(taxiLocationController.finalTripDateTime == null) {
                      showCustomSnackBar('please_select_pickup_time'.tr, getXSnackBar: true);
                    } else if(taxiLocationController.tripType == 'hourly' && taxiLocationController.estimateTimeController.text.isEmpty) {
                      showCustomSnackBar('please_enter_estimate_time'.tr, getXSnackBar: true);
                    } else if(taxiLocationController.tripType == 'hourly' && double.parse(taxiLocationController.estimateTimeController.text) <= 0) {
                      showCustomSnackBar('please_enter_valid_estimate_time'.tr, getXSnackBar: true);
                    } else {
                      Get.find<TaxiHomeController>().getSelectedCars(offset: 1, name: widget.searchName, reload: true);
                      Get.back();
                    }
                  }
                ) : const Center(child: CircularProgressIndicator());
              }),
            ),
          ),

        ],
      );
    });
  }
}
