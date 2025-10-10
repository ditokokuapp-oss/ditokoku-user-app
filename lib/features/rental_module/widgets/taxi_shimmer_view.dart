import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/headers_title_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';

class TopRatedVehicleShimmerView extends StatelessWidget {

  const TopRatedVehicleShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
              child: Shimmer(
                duration: const Duration(seconds: 2),
                enabled: true,
                child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    width: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), width: 0.5),
                    ),
                    child: Column(children: [

                      Container(
                        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        width: double.infinity, height: 105,
                        decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),

                      Container(
                        width: double.infinity, height: 15,
                        decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),

                      Container(
                        margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, bottom: Dimensions.paddingSizeExtraSmall),
                        width: double.infinity, height: 13,
                        decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),

                      Container(
                        width: double.infinity, height: 20,
                        decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),

                    ])
                ),
              )
          );
        },
      ),
    );
  }
}

class TopHistoryWidgetShimmerView extends StatelessWidget {

  const TopHistoryWidgetShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: HeadersTitleWidget(title: 'trip_history'.tr,),
      ),
      const SizedBox(height: 10),

      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              height: 85,
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: 18, left: 18),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
              child: Row(children: [
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Container(
                  height: 70, width: 70,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Container(
                        width: double.infinity, height: Dimensions.paddingSizeDefault,
                        decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        width: double.infinity, height: 13,
                        decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),

                      Container(
                        width: double.infinity, height: 15,
                        decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),

                    ]),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),],
              ),
            ),
          );
        },
      )]
    ) ;
  }
}

class CouponsWidgetShimmerView extends StatelessWidget {

  const CouponsWidgetShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HeadersTitleWidget(title: 'coupons'.tr, onSeeAllPressed: (){}),
        ),

        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            padding: const EdgeInsets.only(bottom: 15, left: 16),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Shimmer(
                duration: const Duration(seconds: 2),
                enabled: true,
                child: Container(
                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                  width: 250,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(children: [

                    Expanded(flex: 12, child: Container(
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                            width: double.infinity, height: 13,
                            decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                            width: double.infinity, height: 13,
                            decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                          ),
                        ]),
                      )),

                      Expanded(flex: 4,
                        child: Container(
                          height: 25,
                          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                          decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                          ),
                      ),
                  ]),
                ),
              );
            },
          ),
        ),

        ]),
      );
  }
}