import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/taxi_cart_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class RantCartWidget extends StatelessWidget {
  final bool? fromSelectVehicleScreen;
  final Function(bool)? callback;
  const RantCartWidget({super.key, this.fromSelectVehicleScreen = false, this.callback});

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: ()=> Get.to(()=> TaxiCartScreen(fromSelectVehicleScreen: fromSelectVehicleScreen))!.then((value) {
        callback!(true);
      }),
      radius: 50,
      child: GetBuilder<TaxiCartController>(
        builder: (taxiCartController) {
          return Stack(clipBehavior: Clip.none, children: [

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Icon(Icons.directions_car, size: 20, color: Theme.of(context).primaryColor),
            ),

            taxiCartController.cartList.isNotEmpty ? Positioned(
              right: -5, top: -5,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: Text("${taxiCartController.cartList.length}", style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall)),
              ),
            ) : const SizedBox(),
          ]);
        }
      ),
    );
  }
}
