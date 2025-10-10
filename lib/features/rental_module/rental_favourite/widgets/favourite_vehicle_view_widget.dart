import 'package:sixam_mart/features/rental_module/rental_favourite/controllers/taxi_favourite_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/widgets/favourite_taxi_view.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteVehicleViewWidget extends StatelessWidget {
  final bool isProvider;
  final bool isSearch;
  const FavouriteVehicleViewWidget({super.key, required this.isProvider, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<TaxiFavouriteController>(builder: (taxiFavouriteController) {
        return RefreshIndicator(
          onRefresh: () async {
            await taxiFavouriteController.getFavouriteTaxiList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 0 : 80.0),
              child: FavouriteTaxiView(
                isProvider: isProvider,
                vehicles: taxiFavouriteController.wishVehicleList,
                providers: taxiFavouriteController.wishProviderList,
                noDataText: 'no_wish_data_found'.tr,
              ),
            ),
          ),
        );
      }),
    );
  }
}
