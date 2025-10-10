import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/home/widgets/module_view.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/headers_title_widget.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/taxi_location_suggestion_screen.dart';
import 'package:sixam_mart/features/rental_module/widgets/add_address_widget_new.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class MyAddressWidget extends StatelessWidget {
  const MyAddressWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AddressController>(
      builder: (addressController) {
        List<AddressModel?> addressList = [];
        if(AuthHelper.isLoggedIn() && addressController.addressList != null) {
          addressList = [];
          addressList.addAll(addressController.addressList!);
        }

        if(!AuthHelper.isLoggedIn()) {
          return const SizedBox();
        }
        return (addressController.addressList != null) ? addressList.isNotEmpty ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: HeadersTitleWidget(
                  title: "my_address".tr,
                  onSeeAllPressed: (){
                    Get.toNamed(RouteHelper.getAddressRoute());
                  },
                ),
              ),

              SizedBox(
                height: 80,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault, top: 2),
                  scrollDirection: Axis.horizontal,
                  itemCount: addressList.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return  Container(
                      width: 250,
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      child: addressWidget(context, addressList[index]!, () {
                        Get.to(()=> TaxiLocationSuggestionScreen(fromAddress: addressList[index]));
                      }),
                    );
                  },
                ),
              )],
          ),
        ) : const AddAddressWidgetNew() : AddressShimmer(isEnabled: AuthHelper.isLoggedIn() && addressController.addressList == null);
      }
    );
  }

  Widget addressWidget(BuildContext context, AddressModel address, Function? onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        // border: Border.all(color: Theme.of(context).disabledColor, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor, blurRadius: 1)],
      ),
      child: CustomInkWell(
        onTap: onTap as void Function()?,
        radius: Dimensions.radiusDefault,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Image.asset(
              address.addressType == 'home' ? Images.taxiHomeAddressIcon : address.addressType == 'office' ? Images.taxiOfficeAddressIcon : Images.taxiOtherAddressIcon,
              color: Theme.of(context).textTheme.bodyLarge!.color, height: 20, width: 20,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  address.addressType!.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  address.address!,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}