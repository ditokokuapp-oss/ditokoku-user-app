import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/widgets/favourite_vendor_card.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/widgets/vehicle_shimmer.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';
import 'package:sixam_mart/features/rental_module/widgets/vehicle_card.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteTaxiView extends StatefulWidget {
  final List<VehicleModel?>? vehicles;
  final List<TaxiVendorModel?>? providers;
  final bool isProvider;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  const FavouriteTaxiView({super.key, required this.providers, required this.vehicles, required this.isProvider, this.isScrollable = false,
    this.shimmerLength = 20, this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault), this.noDataText});

  @override
  State<FavouriteTaxiView> createState() => _FavouriteTaxiViewState();
}

class _FavouriteTaxiViewState extends State<FavouriteTaxiView> {
  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if(widget.isProvider) {
      isNull = widget.providers == null;
      if(!isNull) {
        length = widget.providers!.length;
      }
    }else {
      isNull = widget.vehicles == null;
      if(!isNull) {
        length = widget.vehicles!.length;
      }
    }

    return Column(children: [

      !isNull ? length > 0 ? GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: Dimensions.paddingSizeSmall,
          mainAxisExtent: widget.isProvider ? 280 : 320,
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
        ),
        physics: widget.isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: widget.isScrollable ? false : true,
        itemCount: length,
        padding: widget.padding,
        itemBuilder: (context, index) {
          return widget.providers != null && widget.isProvider
              ? FavouriteVendorCard(provider: widget.providers![index]!)
              : VehicleCard(vehicle: widget.vehicles![index]!, index: index, fromFavourite: true, isWished: true);
        },
      ) : NoDataScreen(text: widget.noDataText ?? 'no_vehicle_available'.tr,)
          : GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : widget.providers != null ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : widget.providers != null ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
          mainAxisExtent: ResponsiveHelper.isDesktop(context) && widget.isProvider ? 220
              : ResponsiveHelper.isMobile(context) ? widget.isProvider ? 200 : 110
              : 110,
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : ResponsiveHelper.isDesktop(context) ? 3 : 3,
        ),
        physics: widget.isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: widget.isScrollable ? false : true,
        itemCount: widget.shimmerLength,
        padding: widget.padding,
        itemBuilder: (context, index) {
          return widget.isProvider ? const NewOnShimmerView()
              : VehicleShimmer(isEnabled: isNull, isProvider: widget.isProvider, hasDivider: index != widget.shimmerLength-1);
        },
      ),

    ]);
  }
}

class NewOnShimmerView extends StatelessWidget {
  const NewOnShimmerView({super.key, });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          child: Column(children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    height: double.infinity, width: double.infinity,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),

                  Positioned(
                    top: 15, right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor.withValues(alpha: 0.8)),
                      child: Icon(Icons.favorite_border, color: Theme.of(context).primaryColor, size: 20),
                    ),
                  ),
                ]),
              ),
            ),

            Expanded(
              flex: 1,
              child: Column(children: [
                Expanded(
                  flex: 2,
                  child: Padding(padding: const EdgeInsets.only(left: 95),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Container(
                          height: 5, width: 100,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: 2),

                      Row(children: [
                        const Icon(Icons.location_on_outlined, color: Colors.blue, size: 15),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Expanded(
                          child: Container(
                            height: 10, width: 100,
                            color: Theme.of(context).cardColor,
                          ),
                        ),
                      ]),
                    ]),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(
                        height: 10, width: 70,
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                      ),

                      Container(
                        height: 20, width: 65,
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),

                    ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),

        Positioned(top: 60, left: 15,
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              height: 65, width: 65,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
            ),
          ]),
        ),
      ]),
    );
  }
}

