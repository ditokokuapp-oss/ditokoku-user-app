import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

import '../../../../../util/images.dart';
import '../../../../../util/styles.dart';

class AddAddressWidgetNew extends StatelessWidget {
  const AddAddressWidgetNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16, left: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('add_address'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: CustomInkWell(
              onTap: () {
                Get.toNamed(RouteHelper.getAddAddressRoute(false, true, 0));
              },
              radius: Dimensions.radiusDefault,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(children: [

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                  child: Icon(Icons.add, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  flex: 3,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Text('add_address'.tr, style: robotoBold.copyWith(fontSize: 12)),
                    ),

                    Text('type_or_select_from_map'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                  ]),
                ),

                Expanded(flex: 1, child: Image.asset(Images.addAddress)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
