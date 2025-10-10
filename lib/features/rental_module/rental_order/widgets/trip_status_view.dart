import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/common/enums/trip_status_enum.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
class TripStatusView extends StatelessWidget {
  final TripDetailsModel tripDetailsModel;
  const TripStatusView({super.key, required this.tripDetailsModel});

  @override
  Widget build(BuildContext context) {
    return Column(spacing: tripDetailsModel.tripStatus == TripStatusEnum.canceled.name ? 0 : Dimensions.paddingSizeLarge, children: [
      const SizedBox(),

      tripDetailsModel.tripStatus == TripStatusEnum.pending.name || tripDetailsModel.tripStatus == TripStatusEnum.confirmed.name
          || tripDetailsModel.tripStatus == TripStatusEnum.ongoing.name ?
      Image.asset(Images.taxiPending, height: 80) : const SizedBox(),

      tripDetailsModel.tripStatus == TripStatusEnum.pending.name ? RichText(textAlign: TextAlign.center, text: TextSpan(children: <TextSpan>[

        TextSpan(text: 'your_booking_is'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),

        TextSpan(text: ' ${'pending'.tr},\n', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),

        TextSpan(text: 'please_wait_for_vendor_confirmation'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor))

      ])) : tripDetailsModel.tripStatus == TripStatusEnum.confirmed.name ? RichText(textAlign: TextAlign.center, text: TextSpan(children: <TextSpan>[

        TextSpan(text: 'your_booking_is'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),

        TextSpan(text: ' ${'confirmed'.tr},\n', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),

        TextSpan(text: 'driver_will_arrive_soon_to_the_pickup_location'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor))

      ])) : tripDetailsModel.tripStatus == TripStatusEnum.ongoing.name ? Column(spacing: Dimensions.paddingSizeSmall, children: [
        RichText(textAlign: TextAlign.center, text: TextSpan(children: <TextSpan>[

          TextSpan(text: 'your_trip_is'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),

          TextSpan(text: ' ${'ongoing'.tr},\n', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),

          TextSpan(text: 'you_will_be_reached_your_destination_approximately'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor))

        ])),
        // Text('you_will_be_reached_your_destination_approximately'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.grey.shade500), textAlign: TextAlign.center,),

        Text(
          tripDetailsModel.tripType == 'hourly' ?
          DateConverter.durationFromNow(tripDetailsModel.estimatedTripEndTime!) < 20
              ? DateConverter.durationFromNow(tripDetailsModel.estimatedTripEndTime!) > 0
              ? '${DateConverter.durationFromNow(tripDetailsModel.estimatedTripEndTime!) - 5} - ${DateConverter.durationFromNow(tripDetailsModel.estimatedTripEndTime!)}'
              : '1 - 5 ${'min'.tr}'
              : DateConverter.dateTimeStringToDateTime(tripDetailsModel.estimatedTripEndTime!)
          : DateConverter.dateTimeStringToDateTime(tripDetailsModel.estimatedTripEndTime!),
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),

      ]) : (tripDetailsModel.tripStatus == TripStatusEnum.completed.name && tripDetailsModel.paymentStatus != 'paid') ? Column(children: [

        RichText(textAlign: TextAlign.center, text: TextSpan(children: <TextSpan>[
          TextSpan(text: 'your_trip_has_been'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),
          TextSpan(text: ' ${'completed'.tr}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),
        ])),

        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
          child: Text('total_trip_cost'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8)),
            textAlign: TextAlign.center,
          ),
        ),

        Text(PriceConverter.convertPrice(tripDetailsModel.tripAmount), style: robotoBold.copyWith(fontSize: 26, color: Theme.of(context).primaryColor), textAlign: TextAlign.center,),

        Container(
          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
          child: Text(
            '${DateConverter.dateTimeStringToDateTime(tripDetailsModel.scheduleAt!)} - ${DateConverter.dateTimeStringToDateTime(tripDetailsModel.completed!)}',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black),
          ),
        ),

        tripDetailsModel.tripType == 'hourly' ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [

          Icon(Icons.hourglass_empty_outlined, size: Dimensions.fontSizeExtraLarge, color: Colors.grey.shade600),

          Text('total_hour'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6))),

          Text(' - ${tripDetailsModel.estimatedHours}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black))

        ]) : tripDetailsModel.tripType == 'day_wise' ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [

          Icon(Icons.calendar_view_day, size: Dimensions.fontSizeExtraLarge, color: Colors.grey.shade600),

          Text('total'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6))),

          Text(' - ${((tripDetailsModel.estimatedHours ?? 0) / 24).toStringAsFixed(0)} ${'day'.tr}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black))

        ]) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [

          Icon(Icons.social_distance, size: Dimensions.fontSizeExtraLarge, color: Colors.grey.shade600),

          Text('total_distance'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey.shade600)),

          Text(' - ${tripDetailsModel.distance?.toStringAsFixed(2)} ${'km'.tr}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black))

        ]),
      ]) : tripDetailsModel.tripStatus == TripStatusEnum.completed.name && tripDetailsModel.paymentStatus == 'paid' ?  Column(children: [
        Image.asset(Images.taxiCompletedGif, height: 150),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        RichText(textAlign: TextAlign.center, text: TextSpan(children: <TextSpan>[
          TextSpan(text: 'your_payment'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),
          TextSpan(text: ' ${'completed_successfully'.tr}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),
        ])),
      ]) : const SizedBox(),

    ]);
  }
}
