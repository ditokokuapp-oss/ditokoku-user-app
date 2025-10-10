import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/rental_module/common/enums/trip_status_enum.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/additional_note.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/deliveryman_view.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/provider_view.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/selected_vehicles_view.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/trip_calculation_view.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/trip_details_widget.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/trip_status_view.dart';
import 'package:sixam_mart/features/rental_module/widgets/booking_cancel_bottomsheet.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/taxi_payment_bottom_sheet.dart';
import 'package:sixam_mart/features/rental_module/widgets/confirm_booking_request_bottom_sheet.dart';
import 'package:sixam_mart/features/rental_module/widgets/review_bottom_sheet.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';

import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';

class TaxiOrderDetailsScreen extends StatefulWidget {
  final int tripId;
  final bool? fromCheckout;
  final String? phone;
  const TaxiOrderDetailsScreen({super.key, required this.tripId, this.fromCheckout = false, this.phone});

  @override
  State<TaxiOrderDetailsScreen> createState() => _TaxiOrderDetailsScreenState();
}

class _TaxiOrderDetailsScreenState extends State<TaxiOrderDetailsScreen> {

  @override
  void initState() {
    super.initState();

    if(widget.phone == null) {
      Get.find<TaxiOrderController>().getTripDetails(widget.tripId, willUpdate: false);
    }

    if(widget.fromCheckout!) {
      Future.delayed(const Duration(microseconds: 600), () {
        Get.bottomSheet(const ConfirmBookingRequestBottomSheet(isScheduleBooking: false, isBooking: true));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaxiOrderController>(
      builder: (taxiOrderController) {
        TripDetailsModel? tripDetailsModel = taxiOrderController.tripDetailsModel;
        bool halfCompleted = false;
        bool tripCanceled = tripDetailsModel?.tripStatus == TripStatusEnum.canceled.name;
        double discount = 0;
        double couponDiscount = 0;
        double tax = 0;
        double taxPercent = 0;
        bool taxInclude = true;
        double additionalCharge = 0;
        double tripCost = 0;
        double subTotal = 0;
        double total = 0;
        if(tripDetailsModel != null) {
          halfCompleted = tripDetailsModel.tripStatus == TripStatusEnum.completed.name && tripDetailsModel.paymentStatus != 'paid';
          discount = tripDetailsModel.discountOnTrip??0;
          couponDiscount = tripDetailsModel.couponDiscountAmount??0;
          tax = tripDetailsModel.taxAmount??0;
          taxPercent = tripDetailsModel.taxPercentage??0;
          taxInclude = tripDetailsModel.taxStatus == 'included';
          additionalCharge = tripDetailsModel.additionalCharge??0;
          total = tripDetailsModel.tripAmount??0;
          tripCost = _calculateTripCost(tripDetailsModel.tripDetails);
          subTotal = tripCost - discount - couponDiscount;
        }

        return tripDetailsModel != null ? PopScope(
          canPop: Navigator.canPop(context),
          onPopInvokedWithResult: (didPop, result) async {
            if(widget.fromCheckout!) {
              ///TODO: don't remove print..
              // print('=====here=====');
              Future.delayed(const Duration(milliseconds: 100) , () {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              });
            } else {
              return;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  if(widget.fromCheckout!) {
                    Get.offAllNamed(RouteHelper.getInitialRoute());
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Column(children: [
                Text('${'trip'.tr} # ${widget.tripId}', style: robotoMedium),
                Text(
                  tripDetailsModel.tripStatus == TripStatusEnum.completed.name
                    ? tripDetailsModel.paymentStatus != 'paid' ? 'trip_cost'.tr : tripDetailsModel.tripStatus!.tr
                    : tripDetailsModel.tripStatus!.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
                ),
              ]),
              centerTitle: true,
            ),

            body: RefreshIndicator(
              onRefresh: () async {
                await taxiOrderController.getTripDetails(widget.tripId, willUpdate: false);
              },
              child: Column(children: [
                Expanded(child: SingleChildScrollView(
                  child: Column(spacing: Dimensions.paddingSizeSmall, children: [

                    TripStatusView(tripDetailsModel: tripDetailsModel),
                    SizedBox(height: tripCanceled ? 0 : Dimensions.paddingSizeLarge),

                    if(halfCompleted)
                      TripCalculationView(
                        tripCost: tripCost, discount: discount, couponDiscount: couponDiscount,
                        subTotal: subTotal, tax: tax, total: total, isCompleted: halfCompleted,
                        serviceFee: additionalCharge, taxPercent: taxPercent, taxInclude: taxInclude,
                      ),

                    if(!halfCompleted)
                      SelectedVehiclesView(tripDetailsList: tripDetailsModel.tripDetails!),

                    if(!halfCompleted)
                      ProviderView(provider: tripDetailsModel.provider!, tripId: tripDetailsModel.id!),

                    TripDetailsWidget(tripDetailsModel: tripDetailsModel),

                    if(tripDetailsModel.tripNote != null)
                      AdditionalNote(note: tripDetailsModel.tripNote),

                    if(!halfCompleted && tripDetailsModel.vehicleIdentity != null && tripDetailsModel.vehicleIdentity!.isNotEmpty)
                      DeliverymanView(vehicleIdentity: tripDetailsModel.vehicleIdentity),

                    if(!halfCompleted)
                      TripCalculationView(
                        tripCost: tripCost, discount: discount, couponDiscount: couponDiscount,
                        subTotal: subTotal, tax: tax, total: total, serviceFee: additionalCharge,
                        taxPercent: taxPercent, taxInclude: taxInclude,
                      ),

                    tripDetailsModel.tripStatus == TripStatusEnum.pending.name ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                      child: Column(spacing: Dimensions.paddingSizeSmall, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                          RichText(text: TextSpan(children: <TextSpan>[
                            TextSpan(text: '${'estimated'.tr} ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),
                            TextSpan(text: taxInclude ? 'vat_tax_inc'.tr : '', style: robotoMedium.copyWith(fontSize: 10, color: Theme.of(context).disabledColor))
                          ])),

                          Text(PriceConverter.convertPrice(total, forTaxi: true), style: robotoBold.copyWith(fontSize: 18)),
                        ]),

                        //Cancel Booking Button
                        ElevatedButton(
                          onPressed: () {
                            Get.bottomSheet(BookingCancelBottomSheet(tripId: tripDetailsModel.id!));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                            elevation: 0,
                          ),
                          child: Text('cancel_booking'.tr, style: robotoBold.copyWith(color: Colors.grey.shade700)),
                        ),
                      ]),
                    ) : const SizedBox(),

                  ]),
                )),

                bottomView(tripDetailsModel, total, taxInclude),
              ]),
            ),

          ),
        ) : const Center(child: CircularProgressIndicator());
      }
    );
  }

  Widget bottomView(TripDetailsModel tripDetailsModel, double total, bool taxInclude) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: SafeArea(
        child: tripDetailsModel.tripStatus == TripStatusEnum.completed.name && tripDetailsModel.paymentStatus != 'paid' ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: CustomButton(
            buttonText: 'pay_now'.tr,
            onPressed: (){
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) => TaxiPaymentBottomSheet(id: tripDetailsModel.id!, totalPrice: total),
              ).then((success) {
                if(success != null && success) {
                  Get.find<TaxiOrderController>().getTripDetails(tripDetailsModel.id!, willUpdate: false);
                }
              });
            },
          ),
        ) : tripDetailsModel.tripStatus == TripStatusEnum.completed.name && tripDetailsModel.paymentStatus == 'paid' && _canReview(tripDetailsModel.vehicleIdentity??[]) && tripDetailsModel.provider!.reviewSection! && AuthHelper.isLoggedIn() ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if(tripDetailsModel.vehicleIdentity!.isNotEmpty) {
                    Get.bottomSheet(ReviewBottomSheet(vehicleList: tripDetailsModel.vehicleIdentity!), isScrollControlled: true);
                  } else {
                    showCustomSnackBar('not_found_any_assigned_vehicle'.tr);
                  }

                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(174, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: BorderSide(color: Theme.of(context).primaryColor, width: 1.0),),
                ),
                child: Text('give_review'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: 16)),
              ),
            ),
          ]),
        ) : const SizedBox(width: double.infinity),
      ),
    );
  }

  double _calculateTripCost(List<TripDetails>? tripDetails) {
    double tripCost = 0;
    if(tripDetails != null) {
      for (var trip in tripDetails) {
        tripCost += trip.calculatedPrice??0;
      }
    }
    return tripCost;
  }

  bool _canReview(List<VehicleIdentity> vehicleList) {
    if(AuthHelper.isLoggedIn()) {
      for (int i = 0; i < vehicleList.length; i++) {
        if (vehicleList[i].rating == null) {
          return true;
        }
      }
    }
    return false;
  }

}
