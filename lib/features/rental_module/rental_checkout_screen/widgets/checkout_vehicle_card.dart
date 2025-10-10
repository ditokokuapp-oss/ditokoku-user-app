import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class CheckoutVehicleCard extends StatelessWidget {
  final Carts cart;
  const CheckoutVehicleCard({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(children: [

        Expanded(
          flex: 7,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).disabledColor, width: 1),
              // boxShadow: [BoxShadow(color: Colors.grey.shade50.withValues(alpha: 1), blurRadius: 1, offset: const Offset(0.005, 0.005))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImage(image: cart.vehicle?.thumbnailFullUrl??''),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          flex: 25,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('${cart.vehicle?.name}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 1, overflow: TextOverflow.ellipsis,),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text('${cart.provider?.name}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.grey.shade700)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Row(children: [
              Text('${'quantity'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
              Text('${cart.quantity}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
