import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/rant_cart_widget.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/widgets/vehicle_card.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class AllVehicleScreen extends StatefulWidget {
  const AllVehicleScreen({super.key});

  @override
  State<AllVehicleScreen> createState() => _AllVehicleScreenState();
}

class _AllVehicleScreenState extends State<AllVehicleScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<TaxiHomeController>().getTopRatedCarList(1, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        title: Text('top_rated_vehicles'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        centerTitle: true,
        actions: const [RantCartWidget(), SizedBox(width: Dimensions.paddingSizeSmall)],
      ),
      body: GetBuilder<TaxiHomeController>(
          builder: (taxiHomeController) {
          return taxiHomeController.topRatedCarsModel != null && taxiHomeController.topRatedCarsModel!.vehicles != null ? taxiHomeController.topRatedCarsModel!.vehicles!.isNotEmpty
              ? SingleChildScrollView(
                controller: _scrollController,
                child: PaginatedListView(
                scrollController: _scrollController,
                totalSize: taxiHomeController.topRatedCarsModel!.totalSize,
                offset: taxiHomeController.topRatedCarsModel!.offset,
                onPaginate: (int? offset) async => await taxiHomeController.getTopRatedCarList(offset!, false),
                itemView: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: taxiHomeController.topRatedCarsModel!.vehicles!.length,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: 50),
                  itemBuilder: (context, index) {
                    return VehicleCard(vehicle: taxiHomeController.topRatedCarsModel!.vehicles![index], index: index, fromFavourite: true);
                    },
                )),
              ) : const SizedBox() : const Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
}
