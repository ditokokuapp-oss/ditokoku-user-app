import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SelectedVehiclesView extends StatefulWidget {
  final List<TripDetails> tripDetailsList;
  const SelectedVehiclesView({super.key, required this.tripDetailsList});

  @override
  State<SelectedVehiclesView> createState() => _SelectedVehiclesViewState();
}

class _SelectedVehiclesViewState extends State<SelectedVehiclesView> {
  bool showCarList = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
      child: Column(spacing: Dimensions.paddingSizeSmall, children: [

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          Text('selected_vehicle'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

          widget.tripDetailsList.length > 2 ? CustomInkWell(
            onTap: () {
              setState(() {
                showCarList = !showCarList;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Theme.of(context).primaryColor),
              child: Icon(showCarList ? Icons.keyboard_arrow_up_sharp : Icons.keyboard_arrow_down, size: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
            ),
          ) : const SizedBox(),
        ]),

        if(widget.tripDetailsList.length > 2 && !showCarList)
          showMultipleView(context, widget.tripDetailsList),

        if(showCarList || widget.tripDetailsList.length <= 2)
        ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: widget.tripDetailsList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return TripVehicleCard(tripDetails: widget.tripDetailsList[index]);
          },
        ),

      ]),
    );
  }

  Widget showMultipleView(BuildContext context, List<TripDetails> tripDetailsList) {
    return Row(children: [

      Stack(clipBehavior: Clip.none, children: [
        Container(
          height: 75, width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).cardColor, width: 3),
            boxShadow: [BoxShadow(color: Colors.grey.shade50.withValues(alpha: 1), blurRadius: 1, offset: const Offset(0.005, 0.005))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImage(image: tripDetailsList[0].vehicleDetails!.thumbnailFullUrl??''),
          ),
        ),

        Positioned(
          left: 40, top: 0, bottom: 0,
          child: Container(
            height: 75, width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).cardColor, width: 3),
              boxShadow: [BoxShadow(color: Colors.grey.shade50.withValues(alpha: 1), blurRadius: 1, offset: const Offset(0.005, 0.005))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImage(image: tripDetailsList[1].vehicleDetails!.thumbnailFullUrl??''),
            ),
          ),
        ),

        Positioned(
          left: 80, top: 0, bottom: 0,
          child: Container(
            height: 75, width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).cardColor, width: 3),
              boxShadow: [BoxShadow(color: Colors.grey.shade50.withValues(alpha: 1), blurRadius: 1, offset: const Offset(0.005, 0.005))],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: CustomImage(
                    image: tripDetailsList[2].vehicleDetails!.thumbnailFullUrl??'',
                    fit: BoxFit.cover, height: 75, width: 80,
                  ),
                ),

                if(tripDetailsList.length > 3)
                  Positioned(
                    top: 0, right: 0, left: 0, bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Center(child: Text('${tripDetailsList.length - 3}+', style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge),)),
                    ),
                  )
              ],
            ),
          ),
        ),
      ]),
      const Spacer(),

      Text(
        '${'total'.tr} ${tripDetailsList.length} ${'vehicle_selected'.tr}',
        style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8)),
      ),
    ]);
  }
}

class TripVehicleCard extends StatefulWidget {
  final TripDetails tripDetails;
  const TripVehicleCard({super.key, required this.tripDetails});

  @override
  State<TripVehicleCard> createState() => _TripVehicleCardState();
}

class _TripVehicleCardState extends State<TripVehicleCard> {
  bool showLicense = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Column(children: [
        Row(children: [

          Container(
            height: 75, width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).cardColor, width: 2),
              boxShadow: [BoxShadow(color: Colors.grey.shade50.withValues(alpha: 1), blurRadius: 1, offset: const Offset(0.005, 0.005))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImage(image: widget.tripDetails.vehicleDetails!.thumbnailFullUrl??''),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${widget.tripDetails.vehicleDetails!.name}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 1, overflow: TextOverflow.ellipsis,),
              ),

              RichText(text: TextSpan(children: <TextSpan>[

                TextSpan(text: '${'quantity'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),

                TextSpan(text: '${widget.tripDetails.quantity}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor))
              ]))

            ]),
          ),
        ]),

        if(widget.tripDetails.licensePlateNumber != null && widget.tripDetails.licensePlateNumber!.isNotEmpty)
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'vehicle_license_number'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              CustomInkWell(
                onTap: () {
                  setState(() {
                    showLicense = !showLicense;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    !showLicense ? Icons.arrow_forward_ios_rounded : Icons.keyboard_arrow_down_outlined,
                    size: !showLicense ? 14 : 18, color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ]),

            Visibility(
              visible: showLicense,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                child: Wrap(
                    alignment: WrapAlignment.start,
                    children: widget.tripDetails.licensePlateNumber!.map((number) {
                      return Text(
                        ' $number ${widget.tripDetails.licensePlateNumber!.indexOf(number) == widget.tripDetails.licensePlateNumber!.length-1 ? '' : ','}',
                        style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                      );
                    }).toList()),
              ),
            ),

          ]),
        ),

      ]),
    );
  }
}

