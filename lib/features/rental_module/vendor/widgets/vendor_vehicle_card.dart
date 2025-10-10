import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/new_tag.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/vehicle_details_screen/vehicle_details_screen.dart';
import 'package:sixam_mart/features/rental_module/widgets/featured_item.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/string_extension.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class VendorVehicleCard extends StatefulWidget {
  final VehicleModel vehicle;

  const VendorVehicleCard({super.key, required this.vehicle});

  @override
  State<VendorVehicleCard> createState() => _VendorVehicleCardState();
}

class _VendorVehicleCardState extends State<VendorVehicleCard> {
  bool isInfoExpanded = false;
  bool showHourlyPrice = false;
  bool showDistancePrice = false;
  bool showDayWisePrice = false;

  String? getMinimumPriceType(double? hourlyPrice, bool hourlyStatus, double? distancePrice, bool distanceStatus, double? dayWisePrice, bool dayWiseStatus) {
    Map<String, double> activePrices = {};

    if (hourlyStatus && hourlyPrice != null) {
      activePrices['hourly'] = hourlyPrice;
    }

    if (distanceStatus && distancePrice != null) {
      activePrices['distance'] = distancePrice;
    }

    if (dayWiseStatus && dayWisePrice != null) {
      activePrices['day_wise'] = dayWisePrice;
    }

    if (activePrices.isEmpty) return null;

    // Find the key (type) with the minimum price
    return activePrices.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  /*bool manageMinimumPrice(double? hourlyPrice, bool hourlyStatus, double? distancePrice, bool distanceStatus, double? dayWisePrice, bool dayWiseStatus) {
    if (hourlyStatus && distanceStatus) {
      if (hourlyPrice != null && distancePrice != null) {
        return (hourlyPrice < distancePrice) ? true : false;
      } else if (hourlyPrice != null) {
        return true;
      } else if (distancePrice != null) {
        return false;
      }
    } else if (hourlyStatus && hourlyPrice != null) {
      return true;
    } else if (distanceStatus && distancePrice != null) {
      return false;
    }

    return false;
  }*/

  @override
  Widget build(BuildContext context) {
    double discount = widget.vehicle.discountPrice ?? 0;
    String discountType = widget.vehicle.discountType ?? 'percent';

    String? priceType = getMinimumPriceType(
      widget.vehicle.hourlyPrice, widget.vehicle.tripHourly ?? false,
      widget.vehicle.distancePrice, widget.vehicle.tripDistance ?? false,
      widget.vehicle.dayWisePrice, widget.vehicle.tripDayWise ?? false,
    );

    showHourlyPrice = priceType == 'hourly';
    showDistancePrice = priceType == 'distance';
    showDayWisePrice = priceType == 'day';

    return Container(
      margin: const EdgeInsets.only(top: 12, left: 20, right: 20),
      height: 270,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), width: 0.5),
      ),
      child: CustomInkWell(
        onTap: () {
          Get.to(() => VehicleDetailsScreen(vehicleId: widget.vehicle.id));
        },
        radius: Dimensions.radiusDefault,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.vehicle.name ?? '', overflow: TextOverflow.ellipsis,
                  maxLines: 1, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                  child: Text(widget.vehicle.provider?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  ),
                )],
              ),
            ),

            if (showDistancePrice)
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                discountType == 'amount' ? const SizedBox() : Text(PriceConverter.convertPrice(widget.vehicle.distancePrice, forTaxi: true), style: robotoBold.copyWith(decoration: TextDecoration.lineThrough, decorationColor: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5), color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),

                RichText(text: TextSpan(children: <TextSpan>[
                  discountType == 'amount' ? TextSpan(
                      text: PriceConverter.convertPrice(widget.vehicle.distancePrice!, forTaxi: true),
                      style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                    ) : TextSpan(
                    text: PriceConverter.convertPrice(widget.vehicle.distancePrice!, discount: discount, discountType: discountType, forTaxi: true),
                    style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  TextSpan(text: ' /${'km'.tr}', style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).primaryColor)),
                ])),

              ]),

            if (showHourlyPrice)
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                discountType == 'amount' ? const SizedBox() : Text(PriceConverter.convertPrice(widget.vehicle.hourlyPrice, forTaxi: true), style: robotoBold.copyWith(decoration: TextDecoration.lineThrough, decorationColor: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5), color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),

                RichText(text: TextSpan(children: <TextSpan>[
                  discountType == 'amount' ? TextSpan(
                    text: PriceConverter.convertPrice(widget.vehicle.hourlyPrice!, forTaxi: true),
                    style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                  ) : TextSpan(text: PriceConverter.convertPrice(widget.vehicle.hourlyPrice!, discount: discount, discountType: discountType, forTaxi: true), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                  TextSpan(text: ' /${'hr'.tr}', style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).primaryColor)),
                ])),

              ]),

            if (showDayWisePrice)
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                discountType == 'amount' ? const SizedBox() : Text(PriceConverter.convertPrice(widget.vehicle.dayWisePrice, forTaxi: true), style: robotoBold.copyWith(decoration: TextDecoration.lineThrough, decorationColor: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5), color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),

                RichText(text: TextSpan(children: <TextSpan>[
                  discountType == 'amount' ? TextSpan(
                    text: PriceConverter.convertPrice(widget.vehicle.dayWisePrice!, forTaxi: true),
                    style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                  ) : TextSpan(text: PriceConverter.convertPrice(widget.vehicle.dayWisePrice!, discount: discount, discountType: discountType, forTaxi: true), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                  TextSpan(text: ' /${'day'.tr}', style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).primaryColor)),
                ])),

              ]),

          ]),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: Stack(children: [

                  CustomImage(fit: BoxFit.cover, width: double.infinity, image: widget.vehicle.thumbnailFullUrl ?? ''),

                  DiscountTag(
                    fromTop: 0, fromTaxi: true, fontSize: Dimensions.fontSizeOverSmall,
                    discount: discount, discountType: discountType,
                    freeDelivery: false, isFloating: false,
                  ),

                  Positioned(
                    left: 0, top: 25,
                    child: NewTag(isNew: widget.vehicle.newTag),
                  ),

                  Positioned(
                    bottom: 10, right: 5,
                    child: widget.vehicle.vehicleIdentitiesCount! > 1 ? Row(children: [

                      AnimatedContainer(
                        width: isInfoExpanded ? 125 : 25,
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                        duration: const Duration(milliseconds: 600),
                        child: Row(
                          children: [

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  '${widget.vehicle.vehicleIdentitiesCount!} ${'vehicles_available'.tr}',
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                                ),
                              ),
                            ),

                            InkWell(
                              highlightColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  isInfoExpanded = !isInfoExpanded;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                                child: const Icon(Icons.info, size: 22, color: Color(0xFF8891F5)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ]) : const SizedBox(),
                  ),

                ]),
              ),

            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Features
          Container(
            height: 25,
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                widget.vehicle.avgRating! > 0 ? FeatureItem(image: Images.taxiStarIcon, text: widget.vehicle.avgRating?.toStringAsFixed(1)??'', iconColor: Colors.amber) : const SizedBox(),
                SizedBox(width: widget.vehicle.avgRating! > 0 ? 16 : 0),

                FeatureItem(image: Images.taxiACIcon, text: widget.vehicle.airCondition! ? 'ac'.tr : 'non_ac'.tr, iconColor: Colors.grey),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                FeatureItem(image: Images.taxiAutomaticIcon, text: widget.vehicle.type!.toTitleCase(), iconColor: Colors.grey),
                const SizedBox(width: 16),

                FeatureItem(image: Images.taxiSeatIcon, text: '${widget.vehicle.seatingCapacity ?? ''} ${'seats'.tr}', iconColor: Colors.grey),
                const SizedBox(width: 16),

                FeatureItem(icon: Icons.call_split_rounded, text: widget.vehicle.transmissionType?.toTitleCase() ?? '', iconColor: Colors.grey)],
              ),
            ),
          ),

        ]),
      ),
    );
  }
}