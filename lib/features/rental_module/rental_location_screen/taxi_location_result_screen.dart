import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/select_vehicle_screen/select_vehicle_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/taxi_cart_screen.dart';
import 'package:sixam_mart/features/rental_module/widgets/trip_from_to_card.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/pickup_time_card.dart';
import 'package:sixam_mart/features/rental_module/widgets/trip_type_card.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class TaxiLocationResultScreen extends StatefulWidget {
  final VehicleModel? vehicle;
  final String? searchName;
  const TaxiLocationResultScreen({super.key, this.vehicle, this.searchName});

  @override
  State<TaxiLocationResultScreen> createState() => _TaxiLocationResultScreenState();
}

class _TaxiLocationResultScreenState extends State<TaxiLocationResultScreen> {

  bool showTripTypeHourly = true;
  bool showTripTypeDistance = true;
  bool showTripTypeDay = true;
  final FocusNode hourNode = FocusNode();
  final FocusNode dayNode = FocusNode();

  @override
  void initState() {
    super.initState();

    String tripType = 'distance_wise';

    if(widget.vehicle != null && !widget.vehicle!.tripDistance!) {
      tripType = 'hourly';
      Get.find<TaxiLocationController>().estimateTimeController.text = '1';
    }

    Get.find<TaxiLocationController>().selectTripType(tripType, willUpdate: false);
    Get.find<TaxiLocationController>().setTripDate(DateTime.now(), willUpdate: false);
    Get.find<TaxiLocationController>().setTripTime(DateTime.now(), willUpdate: false);
    Get.find<TaxiLocationController>().takeCurrentTime(true, willUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    double discount = 0;
    String discountType = 'percent';
    double hourlyDiscount = 0;
    double distanceWiseDiscount = 0;
    double dayWiseDiscount = 0;

    if(widget.vehicle != null) {
      showTripTypeHourly = widget.vehicle!.tripHourly!;
      showTripTypeDistance = widget.vehicle!.tripDistance!;
      showTripTypeDay = widget.vehicle!.tripDayWise!;

      discount = widget.vehicle!.discountPrice ?? 0;
      discountType = widget.vehicle!.discountType ?? 'percent';

      distanceWiseDiscount = PriceConverter.calculation(widget.vehicle!.distancePrice!, discount, discountType, 1);
      hourlyDiscount = PriceConverter.calculation(widget.vehicle!.hourlyPrice!, discount, discountType, 1);
      dayWiseDiscount = PriceConverter.calculation(widget.vehicle!.dayWisePrice!, discount, discountType, 1);
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'location'.tr),
      body: GetBuilder<TaxiLocationController>(builder: (taxiLocationController) {
        return Column(children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
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
                    // const SizedBox(height: Dimensions.paddingSizeSmall),

                    SizedBox(
                      height: 130,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Row(children: [

                          showTripTypeDistance ? TripTypeCard(
                            tripType: 'distance_wise', amount: PriceConverter.convertPrice(widget.vehicle?.distancePrice??0), discountAmount: widget.vehicle != null ? PriceConverter.convertPrice(widget.vehicle!.distancePrice! - distanceWiseDiscount) : '',
                            fareType: 'km', indicatorIcon: Icons.radio_button_off, isVehicleDetailScene: false, isClockIcon: false,
                            haveVehicle: widget.vehicle != null, distanceMinPrice: Get.find<SplashController>().configModel!.vehicleDistanceMinPrice??0,
                            discountType: discountType,
                          ) : const SizedBox(),
                          SizedBox(width: showTripTypeDistance ? Dimensions.paddingSizeDefault : 0),

                          showTripTypeHourly ? TripTypeCard(
                            tripType: 'hourly', amount: PriceConverter.convertPrice(widget.vehicle?.hourlyPrice ?? 0), discountAmount: (widget.vehicle != null ? PriceConverter.convertPrice(widget.vehicle!.hourlyPrice! - hourlyDiscount) : ''),
                            fareType: 'hr', indicatorIcon: Icons.radio_button_checked, isVehicleDetailScene: false,
                            isClockIcon: false, haveVehicle: widget.vehicle != null, hourMinPrice: Get.find<SplashController>().configModel!.vehicleHourlyMinPrice??0,
                            discountType: discountType,
                          ) : const SizedBox(),
                          SizedBox(width: showTripTypeDistance || showTripTypeDay ? Dimensions.paddingSizeDefault : 0),

                          showTripTypeDay ? TripTypeCard(
                            tripType: 'day_wise', amount: PriceConverter.convertPrice(widget.vehicle?.dayWisePrice ?? 0), discountAmount: (widget.vehicle != null ? PriceConverter.convertPrice(widget.vehicle!.dayWisePrice! - dayWiseDiscount) : ''),
                            fareType: 'day', indicatorIcon: Icons.radio_button_checked, isVehicleDetailScene: false,
                            isClockIcon: false, haveVehicle: widget.vehicle != null, dailyMinPrice: Get.find<SplashController>().configModel!.vehicleDayWiseMinPrice ?? 0,
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
                      focusNode: hourNode,
                      inputType: TextInputType.number,
                    ) : const SizedBox(),
                    SizedBox(height: taxiLocationController.tripType == 'hourly' ? Dimensions.paddingSizeExtraLarge : 0),

                    taxiLocationController.tripType == 'day_wise' ? CustomTextField(
                      controller: taxiLocationController.estimateDayController,
                      titleText: 'Ex: 2 days',
                      labelText: 'estimate_days'.tr,
                      isNumber: true,
                      focusNode: hourNode,
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
              child: GetBuilder<TaxiCartController>(
                builder: (taxiCartController) {
                  return !taxiCartController.isLoading ? CustomButton(
                    buttonText: widget.vehicle != null ? 'add_to_cart'.tr : 'confirm_and_search_vehicle'.tr,
                    onPressed: () async {
                      if(taxiLocationController.finalTripDateTime == null) {
                        showCustomSnackBar('please_select_pickup_time'.tr);
                      } else if(taxiLocationController.tripType == 'hourly' && taxiLocationController.estimateTimeController.text.isEmpty) {
                        showCustomSnackBar('please_enter_estimate_time'.tr);
                      } else if(taxiLocationController.tripType == 'hourly' && double.parse(taxiLocationController.estimateTimeController.text) <= 0) {
                        hourNode.requestFocus();
                        showCustomSnackBar('please_enter_valid_estimate_time'.tr);
                      } else if(taxiLocationController.tripType == 'day_wise' && taxiLocationController.estimateDayController.text.isEmpty) {
                        showCustomSnackBar('please_enter_estimate_days'.tr);
                      } else if(taxiLocationController.tripType == 'day_wise' && double.parse(taxiLocationController.estimateDayController.text) <= 0) {
                        dayNode.requestFocus();
                        showCustomSnackBar('please_enter_valid_estimate_days'.tr);
                      } else {
                        if(widget.vehicle != null) {
                          _addToCart(taxiLocationController, taxiCartController, widget.vehicle!);
                        } else {
                          Get.to(() => SelectVehicleScreen(fromAddress: taxiLocationController.fromAddress, toAddress: taxiLocationController.toAddress));
                        }
                      }
                    }
                  ) : const Center(child: CircularProgressIndicator());
                }
              ),
            ),
          ),
        ]);
      }),
    );
  }

  Future<void> _addToCart(TaxiLocationController locationController, TaxiCartController taxiCartController, VehicleModel vehicle) async {
    CartLocation pick = CartLocation(lat: locationController.fromAddress!.latitude, lng: locationController.fromAddress!.longitude, locationName: locationController.fromAddress!.address);
    CartLocation destination = CartLocation(lat: locationController.toAddress!.latitude, lng: locationController.toAddress!.longitude, locationName: locationController.toAddress!.address);
    double? estimatedDay = (double.tryParse(locationController.estimateDayController.text) ?? 0) * 24;

    CarCart cart = CarCart(
      vehicleId: vehicle.id, quantity: 1, pickupLocation: pick, destinationLocation: destination,
      pickupTime: DateConverter.formatDate(locationController.finalTripDateTime!),
      rentalType: locationController.tripType, estimatedHour: locationController.tripType == 'day_wise' ? estimatedDay.toStringAsFixed(0) : locationController.estimateTimeController.text,
      destinationTime: locationController.duration, distance: locationController.distance,
    );

    await taxiCartController.addToCart(cart).then((success) {
      if(success) {
        Get.back();
        Get.off(()=> const TaxiCartScreen());
      }
    });
  }
}
