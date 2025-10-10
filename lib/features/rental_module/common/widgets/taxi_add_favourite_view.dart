import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/controllers/taxi_favourite_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class TaxiAddFavouriteView extends StatelessWidget {
  final VehicleModel? vehicle;
  final int? providerId;
  final int? favIconSize;
  const TaxiAddFavouriteView({super.key, this.providerId, this.vehicle, this.favIconSize});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaxiFavouriteController>(builder: (taxiFavouriteController) {
      bool isWished = false;
      if(providerId != null) {
        isWished = taxiFavouriteController.wishProviderIdList.contains(providerId);
      } else if(vehicle != null){
        isWished = taxiFavouriteController.wishVehicleIdList.contains(vehicle!.id);
      }

      return InkWell(
        onTap: () {
          if(AuthHelper.isLoggedIn()) {
            if(providerId != null) {
              isWished ? taxiFavouriteController.removeFromFavouriteList(providerId, true)
                  : taxiFavouriteController.addToFavouriteList(vehicle: null, providerId: providerId, isProvider: true);
            } else {
              isWished ? taxiFavouriteController.removeFromFavouriteList(vehicle!.id, false)
                  : taxiFavouriteController.addToFavouriteList(vehicle: vehicle, providerId: null, isProvider: false);
            }
          }else {
            showCustomSnackBar('you_are_not_logged_in'.tr);
          }
        },
        child: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).primaryColor, size: favIconSize?.toDouble()),
      );
    });
  }
}