import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_icon_layout.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_vertical_dotted_line.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/widgets/map_recent_saved_address.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/widgets/rider_address_input_field.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
class TaxiLocationSuggestionScreen extends StatefulWidget {
  final GoogleMapController? mapController;
  final AddressModel? fromAddress;
  final AddressModel? toAddress;
  final UserData? userData;
  final VehicleModel? vehicle;
  final bool? isFromSelected;
  const TaxiLocationSuggestionScreen({super.key, this.mapController, this.fromAddress, this.toAddress, this.userData, this.vehicle, this.isFromSelected = false});

  @override
  State<TaxiLocationSuggestionScreen> createState() => _TaxiLocationSuggestionScreenState();
}

class _TaxiLocationSuggestionScreenState extends State<TaxiLocationSuggestionScreen> {

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

    if(widget.mapController != null) {
      _mapController = widget.mapController;
    }

    if(widget.mapController == null) {
      Get.find<TaxiLocationController>().initialSetup();
      Get.find<TaxiLocationController>().getInitialLocation(widget.fromAddress ?? AddressHelper.getUserAddressFromSharedPref(), _mapController);
    }
    Get.find<TaxiLocationController>().selectLocationType(isForm: widget.isFromSelected!, willUpdate: false);

    Get.find<TaxiLocationController>().getHistoryAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async{
        if(widget.userData == null) {
          Get.find<TaxiLocationController>().initialSetup();
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'location'.tr,
          onBackPressed: () {
            Get.find<TaxiLocationController>().initialSetup();
            Get.back();
            },
        ),
        body: Column(children: [

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), spreadRadius: 2, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Row(children: [
              GetBuilder<TaxiLocationController>(
                builder: (taxiLocationController) {
                  return Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(children: [

                      CustomIconLayout(height: 20, width: 20, icon: Icons.location_on_rounded, color: taxiLocationController.isFormSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.4)),

                      const CustomVerticalDottedLine(dotCount: 6),

                      CustomIconLayout(height: 15, width: 15, iconImage: Images.navigationArrowIcon, color: !taxiLocationController.isFormSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.4)),
                    ]),
                  );
                }
              ),

              Expanded(child: Column(children: [
                RiderAddressInputField(
                  isFormAddress: true, showInMapView: false, mapController: _mapController,
                  vehicle: widget.vehicle, userData: widget.userData,
                ),

                const Divider(endIndent: 10),
                RiderAddressInputField(
                  isFormAddress: false, showInMapView: false, mapController: _mapController,
                  vehicle: widget.vehicle, userData: widget.userData,
                ),
              ])),

            ]),
          ),

          Expanded(child: MapRecentSavedAddress(mapController: _mapController, userData: widget.userData, vehicle: widget.vehicle,)),


        ]),
      ),
    );
  }
}
