import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_time_picker.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateTimePickerSheet extends StatefulWidget {
  final bool fromCart;
  final UserData? userData;
  const DateTimePickerSheet({super.key, required this.fromCart, this.userData});

  @override
  State<DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<DateTimePickerSheet> {

  DateTime? selectTripDate;
  DateTime? selectTripTime;
  bool canUpdate = true;

  @override
  void initState() {
    super.initState();

    selectTripDate = widget.userData != null ? DateConverter.dateTimeStringToDate(widget.userData!.pickupTime!) : Get.find<TaxiLocationController>().selectedTripDate;
    selectTripTime = widget.userData != null ? DateConverter.dateTimeStringToDate(widget.userData!.pickupTime!) :Get.find<TaxiLocationController>().selectedTripTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
              child: Icon(Icons.close, size: 24, color: Colors.grey[300],),
            )
        ),

        //heading
        Text('set_date_and_time'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),),
        const SizedBox(height: 16),

        //calender
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey.shade100, width: 1)),
          height: 250,
          padding: const EdgeInsets.only(top: 15, right: 15, left: 15),
          child: SfDateRangePicker(
            backgroundColor: Theme.of(context).cardColor,
            headerStyle: DateRangePickerHeaderStyle(
              backgroundColor: Colors.transparent,
              textAlign: TextAlign.center,
              textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              DateTime selectedDate = DateConverter.dateTimeStringToDate(args.value.toString());
              setState(() {
                selectTripDate = selectedDate;
              });
            },
            selectionMode: DateRangePickerSelectionMode.single,
            initialSelectedDate: selectTripDate ?? DateTime.now(),
            selectableDayPredicate: (DateTime val) {
              return val.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day-1));
            }
          ),
        ),


        //TimePicker
        Container(
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          alignment: Alignment.center,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

            Text('time'.tr, style: robotoMedium),

            CustomTimePicker(
              selectTripTime: selectTripTime,
              callback: (DateTime time) {
                setState(() {
                  selectTripTime = time;
                });
              },
              scrollOff: (status) {
                setState(() {
                  canUpdate = status;
                });
              },
            ),

          ]),
        ),
        const SizedBox(height: 20,),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
            child: GetBuilder<TaxiCartController>(
              builder: (taxiCartController) {
                return !taxiCartController.isLoading ? Row(children: [
                  TextButton(
                    onPressed: () {
                      Get.find<TaxiLocationController>().setTripTime(DateTime.now());
                      Get.find<TaxiLocationController>().setTripDate(DateTime.now());
                      Get.find<TaxiLocationController>().setFinalTripDateTime(DateTime.now());

                      Get.find<TaxiLocationController>().takeCurrentTime(true);
                      if(widget.fromCart) {
                        _updateUserData(Get.find<TaxiLocationController>().finalTripDateTime!);
                      } else {
                        Get.back();
                      }
                    },
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: Text(
                      'pickup_now'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                  ),
                  const Spacer(),

                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('cancel'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),),
                  ),
                  const SizedBox(width: 9),

                  CustomButton(
                    buttonText: 'okay'.tr,
                    height: 35, width: 80,
                    onPressed: canUpdate ? (){
                      Get.find<TaxiLocationController>().setTripDate(selectTripDate);
                      Get.find<TaxiLocationController>().setTripTime(selectTripTime);
                      DateTime date = DateConverter.formattingTripDateTime(Get.find<TaxiLocationController>().selectedTripTime!, Get.find<TaxiLocationController>().selectedTripDate!);

                      if(DateConverter.isAfterCurrentDateTime(date)) {
                        Get.find<TaxiLocationController>().takeCurrentTime(DateConverter.isSameDate(date));
                        if(widget.fromCart && widget.userData != null) {
                          _updateUserData(date);
                        } else {
                          Get.find<TaxiLocationController>().setFinalTripDateTime(date);
                          Get.back();
                        }
                      } else {
                        showCustomSnackBar('you_cannot_select_before_current_time'.tr, getXSnackBar: true);
                      }
                      date = date;

                    } : null,
                  ),

                ])  : const Center(child: CircularProgressIndicator(strokeWidth: 3));
              }
            ),
          ),
        ),

      ]),
    );
  }

  void _updateUserData(DateTime date) {
    CartLocation pick = CartLocation(lat: widget.userData!.pickupLocation!.lat, lng: widget.userData!.pickupLocation!.lng, locationName: widget.userData!.pickupLocation!.locationName);
    CartLocation destination = CartLocation(lat: widget.userData!.destinationLocation!.lat, lng: widget.userData!.destinationLocation!.lng, locationName: widget.userData!.destinationLocation!.locationName);
    CarCart cart = CarCart(
      applyMethod: true, distance: widget.userData!.distance, destinationTime: widget.userData!.destinationTime,
      rentalType: widget.userData!.rentalType, estimatedHour: '${widget.userData!.estimatedHours??0}',
      pickupLocation: pick, destinationLocation: destination, pickupTime: DateConverter.formatDate(date),
    );
    Get.find<TaxiCartController>().updateUserData(cart: cart, userId: widget.userData!.id!).then((success) {
      if(success) {
        Get.back();
        Get.find<TaxiCartController>().getCarCartList();
      }
    });
  }
}