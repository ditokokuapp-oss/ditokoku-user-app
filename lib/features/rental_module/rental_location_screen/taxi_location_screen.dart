import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/location/widgets/permission_dialog_widget.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_icon_layout.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/widgets/animated_map_icon_extended.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/widgets/animated_map_icon_minimized.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/widgets/rider_address_input_field.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

import '../custom/custom_floating_action_button.dart';
import '../custom/custom_vertical_dotted_line.dart';


class TaxiLocationScreen extends StatefulWidget {
  final AddressModel? fromAddress;
  final AddressModel? toAddress;
  final UserData? userData;
  final VehicleModel? vehicle;
  final GoogleMapController? mapController;
  final bool? fromSuggestionScreen;
  final bool? fromSuggestionMap;
  const TaxiLocationScreen({super.key, this.fromAddress, this.toAddress, this.userData, this.vehicle, this.mapController, this.fromSuggestionScreen = false, this.fromSuggestionMap = false});

  @override
  State<TaxiLocationScreen> createState() => _TaxiLocationScreenState();
}

class _TaxiLocationScreenState extends State<TaxiLocationScreen> {

  // bool confirmClick = false;
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  double _currentZoomLevel = 16.0;
  bool _isPicked = false;
  // bool _isButtonClicked = true;

  @override
  void initState() {
    super.initState();

    if(widget.mapController != null) {
      _mapController = widget.mapController;
    }

    if(widget.fromAddress != null && widget.toAddress != null) {
      Get.find<TaxiLocationController>().fromToEnable();
    }

    if(!widget.fromSuggestionMap!) {
      Future.delayed(const Duration(milliseconds: 200),() {
        Get.find<TaxiLocationController>().initialSetup();
      });
    }

    Future.delayed(const Duration(milliseconds: 400), (){
      Get.find<TaxiLocationController>().getZoneList();

      if(widget.toAddress == null && widget.fromAddress == null && !widget.fromSuggestionMap!) {
        Get.find<TaxiLocationController>().getInitialLocation(widget.fromAddress ?? AddressHelper.getUserAddressFromSharedPref(), _mapController);

      }
      else if(widget.fromSuggestionScreen! && widget.userData == null && widget.fromAddress == null && widget.toAddress != null) {
        Get.find<TaxiLocationController>().setAddressFromUpdate(widget.fromAddress, widget.toAddress!);

      }
      else if(widget.fromSuggestionScreen! && widget.userData == null && widget.toAddress == null && widget.fromAddress != null) {
        Get.find<TaxiLocationController>().setAddressFromUpdate(widget.fromAddress!, widget.toAddress);

      }
      else if(widget.fromSuggestionScreen! && widget.userData == null) {
        Get.find<TaxiLocationController>().setAddressFromUpdate(widget.fromAddress!, widget.toAddress!);
        Future.delayed(const Duration(milliseconds: 200) , () async {
          Get.find<TaxiLocationController>().setFromToMarker(
            _mapController,
            from: LatLng(double.parse(widget.fromAddress!.latitude!), double.parse(widget.fromAddress!.longitude!)),
            to: LatLng(double.parse(widget.toAddress!.latitude!), double.parse(widget.toAddress!.longitude!)),
            /*userData: widget.userData, canUpdateProfile: widget.userData != null,*/ clickFromButton: false,
          );
        });
      }
      else {
        Get.find<TaxiLocationController>().setAddressFromUpdate(widget.fromAddress!, widget.toAddress!);
        Future.delayed(const Duration(milliseconds: 200) , () async {
          Get.find<TaxiLocationController>().setFromToMarker(
            _mapController,
            from: LatLng(double.parse(widget.fromAddress!.latitude!), double.parse(widget.fromAddress!.longitude!)),
            to: LatLng(double.parse(widget.toAddress!.latitude!), double.parse(widget.toAddress!.longitude!)),
            userData: widget.userData, canUpdateProfile: widget.userData != null, clickFromButton: false,
          );
        });

      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaxiLocationController>(
        builder: (taxiLocationController) {
        return Scaffold(
          appBar: CustomAppBar(title: widget.fromSuggestionMap! && !_isPicked
              ? taxiLocationController.isFormSelected ? 'set_pickup_location'.tr : 'set_destination_location'.tr
              : 'location'.tr),
          body: Stack(children: [
            GoogleMap(
              mapType: MapType.normal,
              markers: taxiLocationController.markers,
              polylines: Set<Polyline>.of(taxiLocationController.polyLines.values),
              polygons: taxiLocationController.polygons,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: !taxiLocationController.isButtonClick,
              initialCameraPosition: CameraPosition(target: Get.find<TaxiLocationController>().initialPosition, zoom: _currentZoomLevel),
              onMapCreated: (controller) {
                _mapController = controller;
                if(widget.toAddress == null && widget.fromAddress == null) {
                  taxiLocationController.getInitialLocation(widget.fromAddress, _mapController);
                }
              },
              onCameraMove: (CameraPosition cameraPosition) {
                _cameraPosition = cameraPosition;
              },
              onCameraMoveStarted: () {
                taxiLocationController.updateCameraMovingStatus(true);
                taxiLocationController.disableButton();
              },
              onCameraIdle: () {
                taxiLocationController.updateCameraMovingStatus(false);
                try{
                  if(!taxiLocationController.showFromToMarker) {
                    taxiLocationController.updatePosition(_cameraPosition?.target, taxiLocationController.isFormSelected, _mapController);
                  }/* else if(widget.userData == null) {
                    taxiLocationController.setAddressFromUpdate(widget.fromAddress!, widget.toAddress!);
                  }*/
                }catch(e){
                  if (kDebugMode) {
                    print(e);
                  }
                }
              },
              style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMapTaxi,
            ),

            // !taxiLocationController.showFromToMarker ? Center(child: !taxiLocationController.isLoading ? Image.asset(Images.taxiMarker, height: 50, width: 50)
            //     : const CircularProgressIndicator()) : const SizedBox(),

            !taxiLocationController.showFromToMarker ? Center(child: Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.pickMapIconSize * 0.65),
              child: taxiLocationController.isCameraMoving ? const AnimatedMapIconExtended() : const AnimatedMapIconMinimised(),
            )) : const SizedBox(),

            Positioned(
              top: Dimensions.paddingSizeLarge,
              left: Dimensions.paddingSizeLarge,
              right: Dimensions.paddingSizeLarge,
              child: AbsorbPointer(
                absorbing: taxiLocationController.isButtonClick ? true : false,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 2, blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: widget.fromSuggestionMap! && !_isPicked ? oneLocationView(taxiLocationController) : doubleLocationView(),
                ),
              ),
            ),

            Positioned(right: 16, bottom: GetPlatform.isIOS ? 120 : 100,
              child: Column(children: [

                CustomFloatingActionButton(
                  icon: Icons.add, heroTag: 'add_button',
                  onTap: () {
                    _currentZoomLevel++;
                    _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoomLevel));
                  },
                ),

                CustomFloatingActionButton(
                  icon: Icons.remove, heroTag: 'remove_button',
                  onTap: () {
                    _currentZoomLevel--;
                    _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoomLevel));
                  },
                ),

                widget.fromSuggestionMap! && !_isPicked ? Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 4))],
                  ),
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).cardColor,
                    onPressed: () {
                      _checkPermission(() {
                        taxiLocationController.getCurrentLocation(_mapController);
                      });
                    },
                    child: Icon(Icons.my_location, size: 35, color: Theme.of(context).primaryColor),
                  ),
                ) : const SizedBox(),
              ]),
            ),

            Positioned(
              bottom: 0, right: 0, left: 0,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 10)],
                  color: Theme.of(context).cardColor,
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: SafeArea(
                  child: CustomButton(
                    buttonText: !taxiLocationController.inZone ? 'service_not_available_in_this_area'.tr : widget.fromSuggestionMap! && !_isPicked ? 'pick_address'.tr : 'confirm'.tr,
                    isLoading: taxiLocationController.isButtonClick && taxiLocationController.isLoading,
                    onPressed: taxiLocationController.isLoading || !taxiLocationController.inZone ? null : () async {
                      taxiLocationController.buttonClicked(true);

                      if(widget.fromSuggestionMap! && !_isPicked && taxiLocationController.fromAddress != null && taxiLocationController.toAddress != null) {
                        setState(() {
                          _isPicked = true;
                        });
                        Get.find<TaxiLocationController>().setFromToMarker(
                          _mapController,
                          from: LatLng(double.parse(taxiLocationController.fromAddress!.latitude!), double.parse(taxiLocationController.fromAddress!.longitude!)),
                          to: LatLng(double.parse(taxiLocationController.toAddress!.latitude!), double.parse(taxiLocationController.toAddress!.longitude!)),
                          userData: widget.userData, canUpdateProfile: widget.userData != null, clickFromButton: false,
                        );
                      } else if((taxiLocationController.fromAddress == null || taxiLocationController.toAddress == null)) {
                        Get.back();
                      } else {

                        await taxiLocationController.setFromToMarker(
                          _mapController, fromAddress: taxiLocationController.fromAddress!,
                          from: LatLng(double.parse(taxiLocationController.fromAddress!.latitude!), double.parse(taxiLocationController.fromAddress!.longitude!)),
                          to: LatLng(double.parse(taxiLocationController.toAddress!.latitude!), double.parse(taxiLocationController.toAddress!.longitude!)),
                          userData: widget.userData, canUpdateProfile: widget.toAddress != null && widget.userData != null, vehicle: widget.vehicle,
                        );
                      }

                      taxiLocationController.buttonClicked(false);

                    },
                  ),
                ),
              ),
            ),

          ]),
        );
      }
    );
  }

  Widget oneLocationView(TaxiLocationController taxiLocationController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(children: [
        CustomIconLayout(
          height: 20, width: 20, icon: taxiLocationController.isFormSelected ? Icons.location_on_rounded : null,
          iconImage: !taxiLocationController.isFormSelected ? Images.navigationArrowIcon : null, color: Theme.of(context).primaryColor,
        ),

        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Text(
              taxiLocationController.isFormSelected
                  ? taxiLocationController.formTextEditingController.text.isEmpty ? 'enter_pickup'.tr : taxiLocationController.formTextEditingController.text
                  : taxiLocationController.toTextEditingController.text.isEmpty ? 'enter_destination'.tr : taxiLocationController.toTextEditingController.text,
              style: robotoRegular.copyWith(color: taxiLocationController.isFormSelected
                  ? taxiLocationController.formTextEditingController.text.isEmpty ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color
                  : taxiLocationController.toTextEditingController.text.isEmpty ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left,
            ),
          ),
        ),

      ]),
    );
  }

  Widget doubleLocationView() {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Column(children: [

            CustomIconLayout(height: 20, width: 20, icon: Icons.location_on_rounded),

            CustomVerticalDottedLine(dotCount: 6,),

            CustomIconLayout(height: 15, width: 15, iconImage: Images.navigationArrowIcon),
          ]),
        ),

        Expanded(child: Column(children: [
          RiderAddressInputField(
            isFormAddress: true, showInMapView: true, mapController: _mapController,
            userData: widget.userData, vehicle: widget.vehicle, fromSuggestionScreen: (widget.fromSuggestionMap! || widget.fromSuggestionScreen!),
          ),

          const Divider(endIndent: 10),
          RiderAddressInputField(
            isFormAddress: false, showInMapView: true, mapController: _mapController,
            userData: widget.userData, vehicle: widget.vehicle, fromSuggestionScreen: (widget.fromSuggestionMap! || widget.fromSuggestionScreen!),
          ),
        ])),

      ],
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    }else {
      onTap();
    }
  }
}