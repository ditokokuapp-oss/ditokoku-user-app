import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';

class VehicleShimmer extends StatelessWidget {
  final bool isEnabled;
  final bool isProvider;
  final bool hasDivider;
  const VehicleShimmer({super.key, required this.isEnabled, required this.hasDivider, this.isProvider = false});

  @override
  Widget build(BuildContext context) {
    bool desktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
              child: Row(children: [

                Container(
                  height: desktop ? 120 : 80, width: desktop ? 120 : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).shadowColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                    Container(height: desktop ? 20 : 10, width: double.maxFinite, color: Theme.of(context).shadowColor),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: desktop ? 15 : 10, width: double.maxFinite, color: Theme.of(context).shadowColor,
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                    ),
                    SizedBox(height: isProvider ? Dimensions.paddingSizeSmall : 0),

                    !isProvider ? Row(
                      children: List.generate(5, (index) {
                        return Icon(Icons.star, color: Theme.of(context).shadowColor, size: 12);
                      }),
                    ) : const SizedBox(),
                    isProvider ? Row(
                      children: List.generate(5, (index) {
                        return Icon(Icons.star, color: Theme.of(context).shadowColor, size: 12);
                      }),
                    ) : Row(children: [
                      Container(height: desktop ? 20 : 15, width: 30, color: Theme.of(context).shadowColor),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Container(height: desktop ? 15 : 10, width: 20, color: Theme.of(context).shadowColor),
                    ]),

                  ]),
                ),

                Column(mainAxisAlignment: isProvider ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween, children: [
                  const SizedBox(),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: desktop ? Dimensions.paddingSizeSmall : 0),
                    child: Icon(
                      Icons.favorite_border,  size: desktop ? 30 : 25,
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                ]),

              ]),
            ),
          ),
          desktop ? const SizedBox() : Padding(
            padding: EdgeInsets.only(left: desktop ? 130 : 90),
            child: Divider(color: hasDivider ? Theme.of(context).shadowColor : Colors.transparent),
          ),
        ],
      ),
    );
  }
}
