import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/quantity_button.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/rant_cart_widget.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/taxi_location_suggestion_screen.dart';
import 'package:sixam_mart/features/rental_module/vendor/screens/vendor_detail_screen.dart';
import 'package:sixam_mart/features/rental_module/widgets/trip_type_card.dart';
import 'package:sixam_mart/features/rental_module/widgets/vehicle_details_banner.dart';
import 'package:sixam_mart/features/rental_module/widgets/vehicle_grid_item.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/string_extension.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final int? vehicleId;
  final bool? fromSelectVehicleScreen;
  const VehicleDetailsScreen({super.key, required this.vehicleId, this.fromSelectVehicleScreen = false});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {

  List<CategoryModel> _categoryList = [];
  int cartQuantity = 1;
  int isExistInCartPosition = -1;

  @override
  void initState() {
    super.initState();
    if(!widget.fromSelectVehicleScreen!) {
      Get.find<TaxiLocationController>().initialSetup();
    }
    Get.find<TaxiHomeController>().getVehicleDetails(widget.vehicleId!);
    isExistInCartPosition = Get.find<TaxiCartController>().isExistInCart(widget.vehicleId!);
    if(isExistInCartPosition != -1) {
      cartQuantity = Get.find<TaxiCartController>().getCartQuantity(isExistInCartPosition);
    }

  }

  void generateCategories(VehicleModel? vehicle) {
    _categoryList = [];
    if(vehicle != null) {
      if(vehicle.avgRating != 0) {
        _categoryList.add(CategoryModel(icon: Images.taxiStarIcon, name: vehicle.avgRating!.toStringAsFixed(2)));
      }
      if(vehicle.type != null) {
        _categoryList.add(CategoryModel(icon: Images.taxiCarSideIcon, name: vehicle.type!));
      }
      if(vehicle.seatingCapacity != null) {
        _categoryList.add(CategoryModel(icon: Images.taxiSeatIcon, name: '${vehicle.seatingCapacity!} ${'seats'.tr}'));
      }
      if(vehicle.airCondition!) {
        _categoryList.add(CategoryModel(icon: Images.taxiACIcon, name: 'ac'.tr));
      } else {
        _categoryList.add(CategoryModel(icon: Images.taxiACIcon, name: 'non_ac'.tr));
      }
      if(vehicle.transmissionType != null) {
        _categoryList.add(CategoryModel(icon: Images.taxiAutomaticIcon, name: vehicle.transmissionType!));
      }
      if(vehicle.engineCapacity != null) {
        _categoryList.add(CategoryModel(icon: Images.taxiLiterIcon, name: '${vehicle.engineCapacity!}_L'));
      }
      if(vehicle.fuelType != null) {
        _categoryList.add(CategoryModel(icon: Images.taxiPetrolIcon, name: vehicle.fuelType!));
      }

    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        title: Text('vehicle_details'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        centerTitle: true,
        actions: [RantCartWidget(callback: (value){
          if(isExistInCartPosition != -1) {
            setState(() {
              cartQuantity = Get.find<TaxiCartController>().getCartQuantity(isExistInCartPosition);
            });
          }
        }), const SizedBox(width: Dimensions.paddingSizeSmall)],
      ),
      body: GetBuilder<TaxiHomeController>(
        builder: (taxiHomeController) {
          VehicleModel? vehicle = taxiHomeController.vehicleDetailsModel;
          generateCategories(vehicle);
          double discount = 0;
          String discountType = 'percent';
          int totalVehicles = 0;
          double hourlyDiscount = 0;
          double distanceWiseDiscount = 0;
          double dayWiseDiscount = 0;

          if(vehicle != null) {
            totalVehicles = vehicle.totalVehicles != 0 ? vehicle.totalVehicles! : 0;
            discount = vehicle.discountPrice ?? 0;
            discountType = vehicle.discountType ?? 'percent';

            distanceWiseDiscount = PriceConverter.calculation(vehicle.distancePrice!, discount, discountType, 1);
            hourlyDiscount = PriceConverter.calculation(vehicle.hourlyPrice!, discount, discountType, 1);
            dayWiseDiscount = PriceConverter.calculation(vehicle.dayWisePrice!, discount, discountType, 1);
          }

          return vehicle != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  VehicleDetailsBanner(taxiHomeController: taxiHomeController, discount: discount, discountType: discountType),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), width: 0.5),
                        ),

                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                            Expanded(child: Text(vehicle.name??'', style: robotoBold, maxLines: 2, overflow: TextOverflow.ellipsis)),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                              ),
                              child: Row(children: [

                                Text('similar_vehicle'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  child: Text(
                                    '$totalVehicles',
                                    style: robotoMedium.copyWith(fontSize: 14),
                                  ),
                                ),
                              ]),
                            ),
                          ]),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            child: Text(
                              vehicle.description??'',
                              textAlign: TextAlign.start,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                            ),
                          ),

                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 3,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: _categoryList.length,
                            itemBuilder: (context, index) {
                              return VehicleGridItem(
                                label: _categoryList[index].name.toTitleCase(),
                                assetImage: _categoryList[index].icon,
                              );
                            }),
                        ]),
                      ),

                      //Trip Type
                      (vehicle.tripHourly! || vehicle.tripDistance!) ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Padding(
                            padding: const EdgeInsets.only(top: 19, bottom: 10),
                            child: Text("trip_type".tr, style: robotoBold.copyWith(fontSize: 14)),
                          ),

                          SizedBox(
                            height: 130,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                vehicle.tripDistance! ? TripTypeCard(
                                  tripType: 'distance_wise', amount: PriceConverter.convertPrice(vehicle.distancePrice ?? 0, forTaxi: true), discountAmount: PriceConverter.convertPrice(vehicle.distancePrice! - distanceWiseDiscount, forTaxi: true), fareType: 'km', indicatorIcon: Icons.radio_button_off,
                                  isVehicleDetailScene: false, isClockIcon: false, fromVehicleDetails: true, haveVehicle: true, discountType: discountType,
                                ) : const SizedBox(),
                                SizedBox(width: vehicle.tripDistance! && vehicle.tripHourly! ? Dimensions.paddingSizeDefault : 0),

                                vehicle.tripHourly! ? TripTypeCard(
                                  tripType: 'hourly', amount: PriceConverter.convertPrice(vehicle.hourlyPrice ?? 0, forTaxi: true),  discountAmount: PriceConverter.convertPrice(vehicle.hourlyPrice! - hourlyDiscount, forTaxi: true),
                                  fareType: 'hr', indicatorIcon: Icons.radio_button_checked,
                                  isVehicleDetailScene: false, isClockIcon: false, fromVehicleDetails: true, haveVehicle: true, discountType: discountType,
                                ) : const SizedBox(),
                                SizedBox(width: vehicle.tripHourly! ? Dimensions.paddingSizeDefault : 0),

                                vehicle.tripDayWise! ? TripTypeCard(
                                  tripType: 'day_wise', amount: PriceConverter.convertPrice(vehicle.dayWisePrice ?? 0), discountAmount: PriceConverter.convertPrice(vehicle.dayWisePrice! - dayWiseDiscount, forTaxi: true),
                                  fareType: 'day', indicatorIcon: Icons.radio_button_checked,
                                  isVehicleDetailScene: false, isClockIcon: false, fromVehicleDetails: true, haveVehicle: true, discountType: discountType,
                                ) : const SizedBox(),

                              ]),
                            ),
                          ),
                        ],
                      ) : const SizedBox(),

                      //provider
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 19, bottom: 10),
                          child: Text("vendor1".tr, style: robotoBold.copyWith(fontSize: 14)),
                        ),

                        vehicle.provider != null ? Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 10, )],
                            border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                          ),
                          child: CustomInkWell(
                            onTap: () {
                              if(Get.previousRoute == '/VendorDetailScreen') {
                                Get.back();
                              } else {
                                Get.to(() => VendorDetailScreen(vendorId: vehicle.providerId));
                              }
                            },
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                            radius: Dimensions.radiusDefault,
                            child: Row(children: [

                              Container(
                                height: 55, width: 55,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.grey.shade200, width: 1)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CustomImage(image: vehicle.provider!.logoFullUrl??'', width: double.infinity, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 10),

                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Text(vehicle.provider!.name??'', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

                                Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 12),
                                  Text('${vehicle.provider!.avgRating??0}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                  Text(' (${vehicle.provider!.ratingCount??0}+)', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                ]),
                              ]),
                            ]),
                          ),
                        ) : const SizedBox(),
                      ]),


                      const SizedBox(height: 15),
                    ]),
                  ),

                ]),
              ),
            ),

            GetBuilder<TaxiCartController>(builder: (taxiCartController) {
              return GetBuilder<TaxiLocationController>(builder: (locationController) {
                int isExistInCartPosition = taxiCartController.isExistInCart(vehicle.id);
                int quantity = 1;
                int cartId = 0;
                double price = 0;
                double priceWithoutDiscount = 0;
                double discountPrice = 0;
                String? rentalType = taxiCartController.carCartModel?.userData?.rentalType;

                double estimatedDay = 0;
                estimatedDay = (taxiCartController.carCartModel?.userData?.estimatedHours ?? 0) / 24;

                if(isExistInCartPosition != -1) {
                  quantity = taxiCartController.getCartQuantity(isExistInCartPosition);
                  cartId = taxiCartController.getCartId(isExistInCartPosition)??0;

                  double a = rentalType == AppConstants.hourly ? (vehicle.hourlyPrice ?? 0) : rentalType == AppConstants.dayWise ? (vehicle.dayWisePrice ?? 0) : (vehicle.distancePrice ?? 0);
                  double b = rentalType == AppConstants.hourly ? taxiCartController.carCartModel!.userData!.estimatedHours! : rentalType == AppConstants.dayWise ? estimatedDay : taxiCartController.carCartModel!.userData!.distance!;
                  priceWithoutDiscount = (a * b) * cartQuantity;

                  discountPrice = _calculateDiscount(priceWithoutDiscount, discount, discountType, vehicle);
                  price = priceWithoutDiscount - discountPrice;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), blurRadius: 10)],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                  child: Column(children: [

                    if(isExistInCartPosition != -1)
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                        Text('${rentalType == AppConstants.dayWise ? 'duration'.tr : 'estimated'.tr} (${rentalType == AppConstants.hourly ? '${taxiCartController.carCartModel?.userData?.estimatedHours}${'hr'.tr}' :
                          rentalType == AppConstants.dayWise ? '${estimatedDay.toStringAsFixed(0)} ${'day'.tr}' : '${taxiCartController.carCartModel?.userData?.distance?.toStringAsFixed(3)??0}${'km'.tr}' })',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                        ),

                        Row(spacing: Dimensions.paddingSizeExtraSmall, children: [
                          /*Text(PriceConverter.convertPrice(priceWithoutDiscount, forTaxi: true),
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough, decorationColor: Theme.of(context).disabledColor),
                          ),*/

                          Text(PriceConverter.convertPrice(price, forTaxi: true), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),

                        ])
                      ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    SafeArea(child: Row(children: [

                      isExistInCartPosition != -1 ? Expanded(flex: 2, child: Row(children: [
                        QuantityButton(
                          onTap: taxiCartController.isLoading ? null : () {
                            if (quantity > 1) {
                              setState(() {
                                if(cartQuantity > 1) {
                                  cartQuantity--;
                                }
                              });
                              taxiCartController.setQuantity(true, isExistInCartPosition, count: cartQuantity);
                            }else {
                              taxiCartController.removeFromCart(cartId);
                            }
                          },
                          isIncrement: false,
                          showRemoveIcon: quantity == 1 || cartQuantity == 1,
                        ),

                        Text(
                          cartQuantity.toString(),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                        ),

                        QuantityButton(
                          onTap: taxiCartController.isLoading ? null : () {
                            if(totalVehicles > cartQuantity) {
                              setState(() {
                                cartQuantity++;
                              });
                              taxiCartController.setQuantity(true, isExistInCartPosition, count: cartQuantity);
                            } else {
                              showCustomSnackBar('${'you_cant_add_more_than'.tr} $totalVehicles ${'quantities_of_this_vehicle'.tr}');
                            }
                          },
                          isIncrement: true,
                          color: taxiCartController.isLoading || cartQuantity == totalVehicles ? Theme.of(context).disabledColor : null,
                        ),
                      ])) : const SizedBox(),
                      SizedBox(width: isExistInCartPosition != -1 ? Dimensions.paddingSizeSmall : 0),

                      Expanded(flex: 5, child: CustomButton(
                        buttonText: isExistInCartPosition != -1 ? 'update_in_cart'.tr : 'rent_this_vehicle'.tr,
                        isLoading: taxiCartController.isLoading,
                        onPressed: () {
                          if(isExistInCartPosition != -1) {
                            taxiCartController.setQuantity(true, isExistInCartPosition, count: cartQuantity);
                          } else {
                            _addToCart(taxiCartController, vehicle);
                          }
                        },
                      )),

                    ])),

                  ]),
                );
              });
            }),

          ]) : const Center(child: CircularProgressIndicator());
        }
      ),
    );
  }

  void _addToCart(TaxiCartController taxiCartController, VehicleModel vehicle) {

    if((taxiCartController.cartList.isEmpty && Get.find<TaxiLocationController>().toAddress == null)) {
      Get.to(()=> TaxiLocationSuggestionScreen(vehicle: vehicle));
    }
    else if (taxiCartController.cartList.isNotEmpty) {

      CartLocation pick = CartLocation(lat: taxiCartController.carCartModel!.userData!.pickupLocation!.lat, lng: taxiCartController.carCartModel!.userData!.pickupLocation!.lng, locationName: taxiCartController.carCartModel!.userData!.pickupLocation!.locationName);
      CartLocation destination = CartLocation(lat: taxiCartController.carCartModel!.userData!.destinationLocation!.lat, lng: taxiCartController.carCartModel!.userData!.destinationLocation!.lng, locationName: taxiCartController.carCartModel!.userData!.destinationLocation!.locationName);
      double? estimatedDay = (taxiCartController.carCartModel!.userData!.estimatedHours ?? 0) * 24;

      CarCart cart = CarCart(
        vehicleId: vehicle.id, quantity: 1, pickupLocation: pick, destinationLocation: destination,
        pickupTime: taxiCartController.carCartModel!.userData!.pickupTime,
        rentalType: taxiCartController.carCartModel!.userData!.rentalType, estimatedHour: taxiCartController.carCartModel!.userData!.rentalType == 'day_wise' ? estimatedDay.toStringAsFixed(0) : taxiCartController.carCartModel!.userData!.estimatedHours.toString(),
        destinationTime: taxiCartController.carCartModel!.userData!.destinationTime, distance: taxiCartController.carCartModel!.userData!.distance,
      );

      taxiCartController.decideAddToCart(taxiCartController, cart, vehicle);

    }
    else {

      CartLocation pick = CartLocation(
        lat: Get.find<TaxiLocationController>().fromAddress!.latitude,
        lng: Get.find<TaxiLocationController>().fromAddress!.longitude,
        locationName: Get.find<TaxiLocationController>().fromAddress!.address,
      );
      CartLocation destination = CartLocation(
        lat: Get.find<TaxiLocationController>().toAddress!.latitude,
        lng: Get.find<TaxiLocationController>().toAddress!.longitude,
        locationName: Get.find<TaxiLocationController>().toAddress!.address,
      );

      double? estimatedDay = (double.tryParse(Get.find<TaxiLocationController>().estimateDayController.text) ?? 0) * 24;

      CarCart cart = CarCart(
        vehicleId: vehicle.id, quantity: 1, pickupLocation: pick, destinationLocation: destination,
        pickupTime: DateConverter.formatDate(Get.find<TaxiLocationController>().finalTripDateTime!),
        rentalType: Get.find<TaxiLocationController>().tripType, estimatedHour: Get.find<TaxiLocationController>().tripType == 'day_wise' ? estimatedDay.toStringAsFixed(0) : Get.find<TaxiLocationController>().estimateTimeController.text,
        destinationTime: Get.find<TaxiLocationController>().duration, distance: Get.find<TaxiLocationController>().distance,
      );

      taxiCartController.addToCart(cart);
    }
  }

  double _calculateDiscount(double priceWithoutDiscount, double discount, String discountType, VehicleModel vehicle) {
    double discountPrice = 0;
    if(discountType == 'amount') {
      discountPrice = PriceConverter.calculation(priceWithoutDiscount, discount, discountType, cartQuantity);

    } else {
      double pPrice = PriceConverter.convertWithDiscount(priceWithoutDiscount, discount, discountType)!;
      discountPrice = priceWithoutDiscount - pPrice;
    }

    return discountPrice > priceWithoutDiscount ? priceWithoutDiscount : discountPrice;
  }
}

class CategoryModel {
  String icon;
  String name;
  CategoryModel({required this.icon, required this.name});
}
