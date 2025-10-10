import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/taxi_location_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class MapRecentSavedAddress extends StatelessWidget {
  final GoogleMapController? mapController;
  final UserData? userData;
  final VehicleModel? vehicle;
  const MapRecentSavedAddress({super.key, this.mapController, this.userData, this.vehicle});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: GetBuilder<TaxiLocationController>(
        builder: (taxiLocationController) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.paddingSizeSmall, children: [

              taxiLocationController.historyAddress != null && taxiLocationController.historyAddress!.isNotEmpty ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('recent_address'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: taxiLocationController.historyAddress!.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return CustomInkWell(
                      onTap: () async {
                        if(userData != null) {
                          Get.back();
                        }
                        await taxiLocationController.setSuggestionAddress(taxiLocationController.historyAddress![index], mapController);

                        if(taxiLocationController.fromAddress != null && taxiLocationController.toAddress != null) {
                          taxiLocationController.updateCameraMovingStatus(false);
                          Get.to(()=> TaxiLocationScreen(
                            fromAddress: taxiLocationController.fromAddress, toAddress: taxiLocationController.toAddress,
                            fromSuggestionScreen: userData == null, userData: userData, vehicle: vehicle,
                          ));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Text(taxiLocationController.historyAddress![index].addressType?.tr??'other'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                          Text(
                            taxiLocationController.historyAddress![index].address??'', maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                          ),

                        ]),
                      ),
                    );
                  },
                ),
              ]) : const SizedBox(),


              GetBuilder<AddressController>(
                builder: (addressController) {
                  return addressController.addressList != null && addressController.addressList!.isNotEmpty ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('saved_address'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: addressController.addressList!.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return CustomInkWell(
                          onTap: () async {
                            if(userData != null) {
                              Get.back();
                            }
                            await taxiLocationController.setSuggestionAddress(addressController.addressList![index], mapController);

                            if(taxiLocationController.fromAddress != null && taxiLocationController.toAddress != null) {
                              taxiLocationController.updateCameraMovingStatus(false);

                              Get.to(()=> TaxiLocationScreen(
                                fromAddress: taxiLocationController.fromAddress, toAddress: taxiLocationController.toAddress,
                                fromSuggestionScreen: userData == null, userData: userData, vehicle: vehicle,
                              ));
                            }
                          },
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(children: [

                            Image.asset(
                              addressController.addressList![index].addressType == 'home' ? Images.taxiHomeAddressIcon : addressController.addressList![index].addressType == 'office' ? Images.taxiOfficeAddressIcon : Images.taxiOtherAddressIcon,
                              color: Theme.of(context).textTheme.bodyLarge!.color, height: 20, width: 20,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Text('${addressController.addressList![index].addressType?.tr}'' - ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),

                            Flexible(
                              child: Text(
                                addressController.addressList![index].address??'', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                              ),
                            ),

                          ]),
                        );
                      },
                    ),
                  ]) : const SizedBox();
                }
              ),

              const Divider(),

              CustomInkWell(
                onTap: () {
                  if(userData != null) {
                    Get.back();
                  } else {
                    Get.to(()=> TaxiLocationScreen(
                      userData: userData, vehicle: vehicle, fromSuggestionMap: true, fromSuggestionScreen: true,
                      fromAddress: taxiLocationController.isFormSelected ? null : taxiLocationController.fromAddress,
                      toAddress: taxiLocationController.isFormSelected ? taxiLocationController.toAddress : null,
                    ));
                  }
                },
                radius: Dimensions.radiusDefault,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                child: Row(children: [
                  Icon(Icons.map_rounded, color: Theme.of(context).primaryColor, size: 22),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text('select_from_map'.tr, style: robotoRegular),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

            ]),
          );
        }
      ),
    );
  }

}