import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_brand_model.dart';
import 'package:sixam_mart/features/rental_module/helper/string_limit_helper.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/vendor/controllers/taxi_vendor_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';


class VehicleFilterWidget extends StatefulWidget {
  final String searchCarName;
  final int? vendorId;
  final double? minPrice;
  final double? maxPrice;
  final String? tripType;
  const VehicleFilterWidget({super.key, required this.searchCarName, this.vendorId, this.minPrice, this.maxPrice, this.tripType = 'hourly'});

  @override
  State<VehicleFilterWidget> createState() => _VehicleFilterWidgetState();
}

class _VehicleFilterWidgetState extends State<VehicleFilterWidget> {
  
  bool fromVendor = false;

  int digitAfterDecimal = Get.find<SplashController>().configModel!.digitAfterDecimalPoint??0;

  @override
  void initState() {
    super.initState();

    fromVendor = widget.vendorId != null;

    if(Get.find<TaxiVendorController>().maxPrice == 0 || Get.find<TaxiVendorController>().minPrice == 0) {
      Get.find<TaxiVendorController>().setMinAndMaxPrice(widget.minPrice??0, widget.maxPrice??1000 , willUpdate: false);
    }
    if(Get.find<TaxiHomeController>().maxPrice == 0 || Get.find<TaxiHomeController>().minPrice == 0) {
      Get.find<TaxiHomeController>().setMinAndMaxPrice(widget.minPrice??0, widget.maxPrice ?? 1000, willUpdate: false);
    }
    
    if(Get.find<TaxiHomeController>().vehicleCategoryModel == null) {
      Get.find<TaxiHomeController>().getVehicleCategoryList();
    }
    Get.find<TaxiHomeController>().getTaxiBrandList(1, reload: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(width: 20),

            Container(
              width: 33, height: 4.0, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(23.0)),
            ),

            Container(
              padding: const EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.close, size: 24, color: Colors.grey[300]),
              ),
            ),

          ]),

          Flexible(child: SingleChildScrollView(
            child: GetBuilder<TaxiVendorController>(
              builder: (taxiVendorController) {
                return GetBuilder<TaxiHomeController>(
                  builder: (taxiHomeController) {
                    return Column(mainAxisSize: MainAxisSize.min, children: [

                      Padding(padding: const EdgeInsets.only(bottom: 10, top: 20),
                        child: Text('filter_by'.tr, style: robotoMedium.copyWith(fontSize: 16.0, color: Theme.of(context).primaryColor)),
                      ),

                      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Text('price_range'.tr, style: robotoBold.copyWith(fontSize: 14),),
                          const SizedBox(height: 14),

                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade100, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                            child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

                              RichText(text: TextSpan(children: <TextSpan>[
                                TextSpan(text: taxiHomeController.minPrice > 100000 ? PriceConverter.convertPrice(0, formatedStringPrice: NumberFormat.compact().format(taxiHomeController.minPrice)) : PriceConverter.convertPrice(taxiHomeController.minPrice),
                                    style: robotoRegular.copyWith(color: Colors.black, fontSize: 14)),
                                TextSpan(text: '/${widget.tripType == 'hourly' ? 'hr'.tr : 'km'.tr}', style: robotoRegular.copyWith(color: Colors.grey.shade600, fontSize: 14))])
                              ),

                              Container(width: 1, height: 23, color: const Color(0xFFCFD6E4)),

                              RichText(text: TextSpan(children: <TextSpan>[
                                TextSpan(text: taxiHomeController.maxPrice > 100000 ? PriceConverter.convertPrice(0, formatedStringPrice: NumberFormat.compact().format(taxiHomeController.maxPrice)) : PriceConverter.convertPrice(taxiHomeController.maxPrice),
                                    style: robotoRegular.copyWith(color: Colors.black, fontSize: 14)),
                                TextSpan(text: '/${widget.tripType == 'hourly' ? 'hr'.tr : 'km'.tr}', style: robotoRegular.copyWith(color: Colors.grey.shade600, fontSize: 14))])
                              )],
                            ),
                          ),

                          //RangeSlider
                          // const CustomSlider(),

                          RangeSlider(
                            values: RangeValues(fromVendor ? taxiVendorController.minPrice : taxiHomeController.minPrice, fromVendor ? taxiVendorController.maxPrice : taxiHomeController.maxPrice),
                            max: widget.maxPrice!.toInt().toDouble(),
                            min: 0,
                            divisions: widget.maxPrice!.toInt(),
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            labels: RangeLabels(fromVendor ? taxiVendorController.minPrice.toStringAsFixed(digitAfterDecimal) : taxiHomeController.minPrice.toStringAsFixed(digitAfterDecimal), fromVendor ? taxiVendorController.maxPrice.toStringAsFixed(digitAfterDecimal) : taxiHomeController.maxPrice.toStringAsFixed(digitAfterDecimal)),
                            onChanged: (RangeValues rangeValues) {
                              if(fromVendor) {
                                taxiVendorController.setMinAndMaxPrice(rangeValues.start, rangeValues.end);
                              } else {
                                taxiHomeController.setMinAndMaxPrice(rangeValues.start, rangeValues.end);
                              }
                            },

                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          taxiHomeController.taxiBrandModel != null && taxiHomeController.taxiBrandModel!.brands != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('brands'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: taxiHomeController.taxiBrandModel!.brands!.length,
                                  padding: const EdgeInsets.only(bottom: 2),
                                  itemBuilder: (context, index) {
                                    Brands brand = taxiHomeController.taxiBrandModel!.brands![index];
                                    bool selected = false ;

                                    if(fromVendor) {
                                      selected = taxiVendorController.selectedBrands.contains(brand.id);
                                    } else {
                                      selected = taxiHomeController.brandIds.contains(brand.id);
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                      child: CustomInkWell(
                                        onTap: () {
                                          if(fromVendor) {
                                            taxiVendorController.addOrRemoveBrand(brand.id!);
                                          } else {
                                            taxiHomeController.addOrRemoveBrand(brand.id!);
                                          }
                                        },
                                        radius: Dimensions.radiusDefault,
                                        child: Stack(children: [
                                          SizedBox(
                                            width: 60, height: 60,
                                            child: Column(spacing: 2, children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                  child: CustomImage(image: brand.imageFullUrl??'', fit: BoxFit.fill),
                                                ),
                                              ),

                                              Text(
                                                brand.name??'', maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                              ),
                                            ]),
                                          ),

                                          if(selected)
                                            Positioned(
                                              right: 2, top: 2,
                                              child: Image.asset(Images.checkMark, height: 14, width: 14),
                                            ),
                                        ]),
                                      ),
                                    );
                                  }
                              ),
                            ),
                          ]) : const SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                        !fromVendor && taxiHomeController.vehicleCategoryModel != null && taxiHomeController.vehicleCategoryModel!.vehicles!.isNotEmpty ? Column(
                             crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text('vehicle_type'.tr, style: robotoBold.copyWith(fontSize: 14)),
                            ),

                            SizedBox(
                              height: 30,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: taxiHomeController.vehicleCategoryModel!.vehicles!.length,
                                itemBuilder: (context, index) {
                                  int id = taxiHomeController.vehicleCategoryModel!.vehicles![index].id!;
                                  bool selected = taxiHomeController.selectedCategoryIds.contains(id);
                                  String name = StringLimitHelper.limitText(taxiHomeController.vehicleCategoryModel!.vehicles![index].name??'', 20);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                    child: CustomInkWell(
                                      onTap: (){
                                        taxiHomeController.addOrRemoveCategory(id);
                                      },
                                      radius: 5,
                                      child: Stack(children: [

                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: Colors.grey.shade400, width: selected ? 0.7 : 0.2),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                          child: Text(
                                            name,
                                            style: robotoRegular.copyWith(fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                                          ),
                                        ),

                                        if (selected)
                                          Positioned(
                                            right: 0.1, top: 0.1,
                                            child: Image.asset(Images.checkMark, height: 14, width: 14),
                                          ),
                                      ]),
                                    ),
                                  );
                                },
                              ),
                            ),

                           const SizedBox(height: Dimensions.paddingSizeDefault),

                          ]) : const SizedBox(),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text('seats'.tr, style: robotoBold.copyWith(fontSize: 14)),
                          ),

                          SizedBox(
                            height: 30,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: AppConstants.seats.length,
                              itemBuilder: (context, index) {
                                bool selected = false;
                                String seat = jsonEncode(AppConstants.seats[index]);
                                if(AppConstants.seats[index] == '14+') {
                                  seat = jsonEncode('14-1000');
                                }
                                if(fromVendor) {
                                  selected = taxiVendorController.selectedSeatingCapacity.contains(seat);
                                } else {
                                  selected = taxiHomeController.selectedSeatingCapacity.contains(seat);
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  child: CustomInkWell(
                                    onTap: (){
                                      if(fromVendor) {
                                        taxiVendorController.addOrRemoveSeatingCapacity(seat);
                                      } else {
                                        taxiHomeController.addOrRemoveSeatingCapacity(seat);
                                      }
                                    },
                                    radius: 5,
                                    child: Stack(children: [

                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: Colors.grey.shade400, width: selected ? 0.7 : 0.2),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                        child: Text('${AppConstants.seats[index]} ${'seats'.tr}', style: robotoRegular.copyWith(fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                                      ),

                                      if (selected)
                                        Positioned(
                                          right: 0.1, top: 0.1,
                                          child: Image.asset(Images.checkMark, height: 14, width: 14),
                                        ),
                                    ]),
                                  ),
                                );

                              },
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text('colling'.tr, style: robotoBold.copyWith(fontSize: 14)),
                          ),

                          Row(children: [
                            Stack(children: [

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.grey.shade400, width: taxiHomeController.airCondition ? 0.7 : 0.2),
                                ),
                                child: CustomInkWell(
                                  onTap: () {
                                    if(fromVendor) {
                                      taxiVendorController.toggleAirCondition();
                                    } else {
                                      taxiHomeController.toggleAirCondition();
                                    }
                                  },
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  child: Text('air_conditioned'.tr,
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: taxiHomeController.airCondition ? FontWeight.bold : FontWeight.normal),
                                  ),
                                ),
                              ),

                              if(fromVendor ? taxiVendorController.airCondition : taxiHomeController.airCondition)
                                Positioned(
                                  right: 0.1, top: 0.1,
                                  child: Image.asset(Images.checkMark, height: 14, width: 14),
                                ),
                            ]),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Stack(children: [

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.grey.shade400, width: taxiHomeController.nonAirCondition ? 0.7 : 0.2),
                                ),
                                child: CustomInkWell(
                                  onTap: () {
                                    if(fromVendor) {
                                      taxiVendorController.toggleNonAirCondition();
                                    } else {
                                      taxiHomeController.toggleNonAirCondition();
                                    }
                                  },
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  child: Text('no_air_conditioned'.tr,
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: taxiHomeController.nonAirCondition ? FontWeight.bold : FontWeight.normal),
                                  ),
                                ),
                              ),

                              if(fromVendor ? taxiVendorController.nonAirCondition : taxiHomeController.nonAirCondition)
                                Positioned(
                                  right: 0.1, top: 0.1,
                                  child: Image.asset(Images.checkMark, height: 14, width: 14),
                                ),
                            ]),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                        ]),
                      ),
                    ]);
                  }
                );
              }
            ),
          ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), blurRadius: 10)],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
            child: SafeArea(
              child: Row(children: [

                Expanded(
                  child: CustomButton(
                    buttonText: 'clear_filter'.tr, height: 40,
                    color: Theme.of(context).disabledColor,
                    onPressed: () {
                      if(fromVendor) {
                        Get.find<TaxiVendorController>().initFilterSetup(maxPrice: widget.maxPrice);
                        Get.find<TaxiVendorController>().getVendorVehicleList(offset: 1, vendorId: widget.vendorId!, searchName: widget.searchCarName);
                      } else {
                        Get.find<TaxiHomeController>().resetFilter(widget.maxPrice);
                        Get.find<TaxiHomeController>().getSelectedCars(offset: 1, name: widget.searchCarName, reload: true);
                      }
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: CustomButton(
                    buttonText: 'apply_filter'.tr, height: 40,
                    onPressed: () {
                      if(fromVendor) {
                        Get.find<TaxiVendorController>().getVendorVehicleList(offset: 1, vendorId: widget.vendorId!, searchName: widget.searchCarName, fromFilter: true);
                      } else {
                        Get.find<TaxiHomeController>().getSelectedCars(offset: 1, name: widget.searchCarName, reload: true, fromFilter: true);
                      }
                      Get.back();
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}