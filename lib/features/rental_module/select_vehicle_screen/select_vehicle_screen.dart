import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/rant_cart_widget.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/select_vehicle_screen/search_vehicle_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/taxi_cart_screen.dart';
import 'package:sixam_mart/features/rental_module/widgets/trip_from_to_card.dart';
import 'package:sixam_mart/features/rental_module/widgets/vehicle_card.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/vehicle_filter_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SelectVehicleScreen extends StatefulWidget {
  final AddressModel? fromAddress;
  final AddressModel? toAddress;
  const SelectVehicleScreen({super.key, required this.fromAddress, required this.toAddress});

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  String searchName = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<TaxiHomeController>().initFilterSetup();
    Get.find<TaxiCartController>().getCarCartList();
    Get.find<TaxiHomeController>().getSelectedCars(offset: 1, name: null);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        title: Text('select_vehicle'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        centerTitle: true,
        actions: const [RantCartWidget(fromSelectVehicleScreen: true), SizedBox(width: Dimensions.paddingSizeSmall)],
      ),

      body: GetBuilder<TaxiHomeController>(
        builder: (taxiHomeController) {
          return Column(children: [

            Expanded(child: CustomScrollView(controller: _scrollController, slivers: [

              SliverToBoxAdapter(
                child: Container(
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: TripFromToCard(fromAddress: widget.fromAddress!, toAddress: widget.toAddress!, showTitle: true, searchName: searchName),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(
                  height: searchName.isNotEmpty ? 90 : 50,
                  child: Container(
                    width: 600, height: searchName.isNotEmpty ? 90 : 50,
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Column(
                      children: [

                        searchName.isNotEmpty ? Container(
                          margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 1))],
                          ),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                            Expanded(
                              child: RichText(maxLines: 1, overflow: TextOverflow.ellipsis, text: TextSpan(children: <TextSpan>[

                                TextSpan(text: '${taxiHomeController.selectedCarsModel?.totalSize??0} ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black)),

                                TextSpan(text: 'result_found_for'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey)),

                                TextSpan(text: ' $searchName', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black))

                              ])),
                            ),

                            InkWell(
                              onTap: () async {
                                setState(() {
                                  searchName = '';
                                });
                                await taxiHomeController.getSelectedCars(offset: 1, name: null);
                              },
                              child: Icon(Icons.close, size: Dimensions.fontSizeExtraLarge, color: Colors.grey),
                            ),
                          ]),
                        ) : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Row(children: [
                          Expanded(child: Text('vehicle_list'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault))),

                          taxiHomeController.selectedCarsModel != null ? Row(children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(()=> const SearchVehicleScreen())?.then((value) async {
                                    if(value != null) {
                                      setState(() {
                                        searchName = value;
                                      });
                                      await taxiHomeController.getSelectedCars(offset: 1, name: searchName);
                                    }
                                  });
                                },
                                child: Icon(Icons.search, size: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: InkWell(
                                onTap: () {
                                  double? maxPrice = taxiHomeController.selectedCarsModel?.maxPrice??1000;
                                  double? minPrice = taxiHomeController.selectedCarsModel?.minPrice??0;
                                  Get.bottomSheet(
                                    VehicleFilterWidget(searchCarName: searchName, minPrice: minPrice, maxPrice: maxPrice, tripType: taxiHomeController.tripType),
                                    backgroundColor: Colors.transparent, isScrollControlled: true,
                                  );
                                },
                                child: Icon(Icons.filter_list_outlined, size: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                              ),
                            )
                          ]) : const SizedBox(),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: taxiHomeController.selectedCarsModel != null ? taxiHomeController.selectedCarsModel!.vehicles!.isNotEmpty ? PaginatedListView(
                  scrollController: _scrollController,
                  totalSize: taxiHomeController.selectedCarsModel!.totalSize,
                  offset: taxiHomeController.selectedCarsModel!.offset,
                  onPaginate: (int? offset) async => await taxiHomeController.getSelectedCars(offset: offset!, name: searchName),
                  itemView: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: taxiHomeController.selectedCarsModel!.vehicles!.length,
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeLarge),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return VehicleCard(vehicle: taxiHomeController.selectedCarsModel!.vehicles![index], index: index, fromSelectVehicleScreen: true);
                    },
                  ),
                ) : NoDataScreen(text: 'no_vehicle_available'.tr) : const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: CircularProgressIndicator(),
                )),
              ),

            ])),

            GetBuilder<TaxiCartController>(
              builder: (taxiCartController) {
                return taxiCartController.cartList.isNotEmpty ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), blurRadius: 10)],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                  child: SafeArea(
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${taxiCartController.cartList.length} ${'vehicle_selected'.tr}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),

                      CustomButton(
                        buttonText: 'view_cart'.tr,
                        width: 100, height: 40,
                        onPressed: ()=> Get.to(()=> const TaxiCartScreen(fromSelectVehicleScreen: true)),
                      ),
                    ]),
                  ),
                ) : const SizedBox();
              }
            ),

          ]);
        }
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}