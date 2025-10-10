import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/rental_module/helper/string_limit_helper.dart';
import 'package:sixam_mart/features/rental_module/select_vehicle_screen/search_vehicle_screen.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/vehicle_filter_widget.dart';
import 'package:sixam_mart/features/rental_module/vendor/controllers/taxi_vendor_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SearchAndFilterWidget extends StatefulWidget {
  final TaxiVendorController taxiVendorController;
  final int? vendorId;
  final String? searchName;
  final Function(String?) searchCallback;
  const SearchAndFilterWidget({super.key, required this.taxiVendorController, this.vendorId, required this.searchCallback, this.searchName});

  @override
  State<SearchAndFilterWidget> createState() => _SearchAndFilterWidgetState();
}

class _SearchAndFilterWidgetState extends State<SearchAndFilterWidget> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 10))],
      ),
      width: 600,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge, top: Dimensions.paddingSizeSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text('vehicle_list'.tr, style: robotoBold),

            Row(children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                ),
                child: CustomInkWell(
                  onTap: widget.taxiVendorController.taxiVendorVehicleList == null ? null : () {
                    Get.to(()=> const SearchVehicleScreen())?.then((value) async {
                      if(value != null) {
                        widget.searchCallback(value);
                      }
                    });
                  },
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Icon(Icons.search, size: Dimensions.fontSizeOverLarge, color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                ),
                child: CustomInkWell(
                  onTap: widget.taxiVendorController.taxiVendorVehicleList == null ? null : () {
                    double? maxPrice = widget.taxiVendorController.taxiVendorVehicleList?.maxPrice??1000;
                    Get.bottomSheet(
                      VehicleFilterWidget(searchCarName: widget.searchName??'', vendorId: widget.vendorId, minPrice: widget.taxiVendorController.taxiVendorVehicleList?.minPrice??0, maxPrice: maxPrice,),
                      backgroundColor: Colors.transparent, isScrollControlled: true,
                    );
                  },
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Icon(Icons.filter_list_outlined, size: Dimensions.fontSizeOverLarge, color: Theme.of(context).primaryColor),
                ),
              )
            ]),

          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Column(children: [
          SizedBox(height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.taxiVendorController.categories?.length??0,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                bool isSelected = selectedIndex == index;
                String name = StringLimitHelper.limitText(widget.taxiVendorController.categories?[index].name??'', 20);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 0.5) : null,
                  ),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, top: 3, bottom: 3),
                  child: CustomInkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      widget.taxiVendorController.setCategoryId(widget.taxiVendorController.categories?[index].id);
                      widget.taxiVendorController.getVendorVehicleList(offset: 1, vendorId: widget.vendorId!);
                    },
                    radius: Dimensions.radiusSmall,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: Text(
                      name,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),

      ]),
    );
  }
}
