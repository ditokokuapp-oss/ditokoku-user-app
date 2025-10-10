import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/new_tag.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/taxi_add_favourite_view.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/vehicle_details_screen/vehicle_details_screen.dart';
import 'package:sixam_mart/features/rental_module/vendor/screens/vendor_detail_screen.dart';
import 'package:sixam_mart/features/rental_module/widgets/featured_item.dart';
import 'package:sixam_mart/helper/string_extension.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class HorizontalVehicleCard extends StatefulWidget {
  final VehicleModel vehicleModel;

  const HorizontalVehicleCard({super.key, required this.vehicleModel});

  @override
  State<HorizontalVehicleCard> createState() => _HorizontalVehicleCardState();
}

class _HorizontalVehicleCardState extends State<HorizontalVehicleCard> {
  bool isInfoExpanded = false;

  @override
  Widget build(BuildContext context) {

    double discount = widget.vehicleModel.discountPrice ?? 0;
    String discountType = widget.vehicleModel.discountType ?? 'percent';

    return Container(
        width: 240,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge),
            bottomLeft: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault),
          ),
          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), width: 0.5),
        ),
        child: CustomInkWell(
          onTap: ()=> Get.to(() => VehicleDetailsScreen(vehicleId: widget.vehicleModel.id,)),
          radius: Dimensions.radiusDefault,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Column(children: [

            Stack(children: [
              SizedBox(
                width: 230, height: 105,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: CustomImage(image: widget.vehicleModel.thumbnailFullUrl??''),
                ),
              ),

              Positioned(
                left: 0, top: 25,
                child: NewTag(isNew: widget.vehicleModel.newTag),
              ),

              DiscountTag(
                fromTop: 0, fromTaxi: true, fontSize: Dimensions.fontSizeOverSmall,
                discount: discount, discountType: discountType,
                freeDelivery: false, isFloating: false,
              ),

              Positioned(
                right: 8, top: 8,
                child: TaxiAddFavouriteView(
                  favIconSize: 20,
                  vehicle: widget.vehicleModel,
                ),
              ),

              Positioned(
                bottom: 5, right: 5,
                child: widget.vehicleModel.vehicleIdentitiesCount! > 1 ? Row(children: [

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
                              '${widget.vehicleModel.vehicleIdentitiesCount!} ${'vehicles_available'.tr}',
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
            const SizedBox(height: 10),

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  '${widget.vehicleModel.name}',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                  textAlign: TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),

              CustomInkWell(
                onTap: (){
                  Get.to(()=> VendorDetailScreen(vendorId: widget.vehicleModel.providerId));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '${widget.vehicleModel.provider?.name}',
                      style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5), fontSize: Dimensions.fontSizeExtraSmall),
                      textAlign: TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),

                  ),
                ),
              ),

            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  widget.vehicleModel.avgRating! > 0 ? FeatureItem(image: Images.taxiStarIcon, text: '${widget.vehicleModel.avgRating?.toStringAsFixed(1)}', iconColor: Colors.amber) : const SizedBox(),
                  SizedBox(width: widget.vehicleModel.avgRating! > 0 ? 16 : 0),

                  FeatureItem(image: Images.taxiACIcon, text: widget.vehicleModel.airCondition! ? 'ac'.tr : 'non_ac'.tr, iconColor: Colors.grey),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  FeatureItem(image: Images.taxiAutomaticIcon, text: '${widget.vehicleModel.type?.toTitleCase()}', iconColor: Colors.grey),
                  const SizedBox(width: 16),

                  FeatureItem(image: Images.taxiSeatIcon, text: '${widget.vehicleModel.seatingCapacity} ${"seats".tr}', iconColor: Colors.grey),
                ]),
              ),
            ),
          ]),
        )
    );
  }
}
