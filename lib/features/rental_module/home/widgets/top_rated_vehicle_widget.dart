import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/home/screens/all_vehicle_screen.dart';
import 'package:sixam_mart/features/rental_module/home/widgets/horizontal_vehicle_card.dart';
import 'package:sixam_mart/features/rental_module/widgets/taxi_shimmer_view.dart';
import 'package:sixam_mart/util/dimensions.dart';
import '../../common/widgets/headers_title_widget.dart';

class TopRatedVehicleWidget extends StatelessWidget {
  const TopRatedVehicleWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return  GetBuilder<TaxiHomeController>(
        builder: (taxiHomeController) {
          return taxiHomeController.topRatedCarsModel != null && taxiHomeController.topRatedCarsModel!.vehicles != null
              ? taxiHomeController.topRatedCarsModel!.vehicles!.where((vehicle) => vehicle.status == 1).isNotEmpty
              ? Column(crossAxisAlignment: CrossAxisAlignment.start,  children: [

                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: HeadersTitleWidget(
                    title: 'top_rated_vehicles'.tr,
                    onSeeAllPressed: () {
                      Get.to(()=> const AllVehicleScreen());
                    }
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                SizedBox(
                  height: 210,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: taxiHomeController.topRatedCarsModel!.vehicles!.length,
                    padding: const EdgeInsets.only(left: 16),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      if(taxiHomeController.topRatedCarsModel!.vehicles![index].status != 1) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                        child: HorizontalVehicleCard(vehicleModel: taxiHomeController.topRatedCarsModel!.vehicles![index]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ]
          ): const SizedBox() : const TopRatedVehicleShimmerView();
        }
    );
  }
}