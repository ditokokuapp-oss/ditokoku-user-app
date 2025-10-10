import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_data_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/domain/services/taxi_location_service_interface.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/taxi_location_result_screen.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/marker_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/models/car_cart.dart';
import 'dart:math';

class TaxiLocationController extends GetxController implements GetxService {
  final TaxiLocationServiceInterface taxiLocationServiceInterface;

  TaxiLocationController({required this.taxiLocationServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isButtonClick = false;
  bool get isButtonClick => _isButtonClick;

  LatLng _initialPosition = LatLng(
    double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
    double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
  );
  LatLng get initialPosition => _initialPosition;

  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  Set<Polygon> _polygons = {};
  Set<Polygon> get polygons => _polygons;

  final Map<PolylineId, Polyline> _polyLines = {};
  Map<PolylineId, Polyline> get polyLines => _polyLines;

  AddressModel? _fromAddress;
  AddressModel? get fromAddress => _fromAddress;

  AddressModel? _toAddress;
  AddressModel? get toAddress => _toAddress;

  List<AddressModel>? _historyAddress;
  List<AddressModel>? get historyAddress => _historyAddress;

  final MarkerId fromMarkerId = const MarkerId('from_marker');
  final MarkerId toMarkerId = const MarkerId('to_marker');

  final TextEditingController _formTextEditingController = TextEditingController();
  TextEditingController get formTextEditingController => _formTextEditingController;

  final TextEditingController _toTextEditingController = TextEditingController();
  TextEditingController get toTextEditingController => _toTextEditingController;

  TextEditingController estimateTimeController = TextEditingController();
  TextEditingController estimateDayController = TextEditingController();

  double? _distance = -1;
  double? get distance => _distance;

  double? _duration = -1;
  double? get duration => _duration;

  bool _isFormSelected = true;
  bool get isFormSelected => _isFormSelected;

  bool _showFromToMarker = false;
  bool get showFromToMarker => _showFromToMarker;

  bool _updateAddAddressData = true;

  bool _isCameraMoving = false;
  bool get isCameraMoving => _isCameraMoving;

  bool _buttonDisabled = true;
  bool get buttonDisabled => _buttonDisabled;

  Uint8List? _mapScreenshot;
  Uint8List? get mapScreenshot => _mapScreenshot;

  String _tripType = 'distance_wise';
  String get tripType => _tripType;

  DateTime? _selectedTripDate;
  DateTime? get selectedTripDate => _selectedTripDate;

  DateTime? _selectedTripTime;
  DateTime? get selectedTripTime => _selectedTripTime;

  DateTime? _finalTripDateTime = DateTime.now();
  DateTime? get finalTripDateTime => _finalTripDateTime;

  bool _pickCurrentTime = true;
  bool get pickCurrentTime => _pickCurrentTime;

  int _filterBrandIndex = -1;
  int get filterBrandIndex => _filterBrandIndex;

  int _filterVehicleTypeIndex = -1;
  int get filterVehicleTypeIndex => _filterVehicleTypeIndex;

  int _filterSeatIndex = -1;
  int get filterSeatIndex => _filterSeatIndex;

  int _filterColling = -1;
  int get filterColling => _filterColling;

  List<ZoneDataModel>? _zoneList;
  List<ZoneDataModel>? get zoneList => _zoneList;

  bool _inZone = true;
  bool get inZone => _inZone;

  void takeCurrentTime(bool val, {bool willUpdate = true}) {
    _pickCurrentTime = val;
    if(willUpdate) {
      update();
    }
  }

  void buttonClicked(bool status) {
    _isButtonClick = status;
    update();
  }

  void selectLocationType({required bool isForm, bool willUpdate = true}) {
    _isFormSelected = isForm;
    if(willUpdate) {
      update();
    }
  }

  void selectTripType(String type, {bool willUpdate = true}) {
    _tripType = type;
    if(willUpdate) {
      update();
    }
  }

  void updateCameraMovingStatus(bool status){
    _isCameraMoving = status;
    update();
  }

  void setTripDate(DateTime? date, {bool willUpdate = true}) {
    _selectedTripDate = date;
    if(willUpdate) {
      update();
    }
  }

  void setTripTime(DateTime? date, {bool willUpdate = true}) {
    _selectedTripTime = date;
    if(willUpdate) {
      update();
    }
  }

  void setFinalTripDateTime(DateTime? date) {
    _finalTripDateTime = date;
    update();
  }

  void disableButton() {
    _buttonDisabled = true;
    update();
  }

  Future<void> clearAddress(bool isFrom) async{
    if(isFrom){
      _formTextEditingController.text = '';
      _fromAddress = null;
    }else{
      _toTextEditingController.text = '';
      _toAddress = null;
    }
    _showFromToMarker = false;
    _markers.clear();
    _polyLines.clear();
    update();
  }

  void initialSetup() {
    _fromAddress = null;
    _toAddress = null;
    _formTextEditingController.text = '';
    _toTextEditingController.text = '';
    estimateTimeController.text = '';
    estimateDayController.text = '';
    _finalTripDateTime = DateTime.now();
    _showFromToMarker = false;
    _markers.clear();
    _polyLines.clear();
  }

  void fromToEnable() {
    _showFromToMarker = true;
  }

  void setAddressFromUpdate(AddressModel? from, AddressModel? to) {
    _showFromToMarker = (to == null || from == null) ? false : true;
    _fromAddress = from;
    _toAddress = to;
    _formTextEditingController.text = from?.address??'';
    _toTextEditingController.text = to?.address??'';
  }

  Future<Position?> getInitialLocation(AddressModel? address, GoogleMapController? mapController) async {
    Position? position;

    try {
      if(address == null){
        await Geolocator.requestPermission();
        position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        _initialPosition = LatLng(position.latitude, position.longitude);
      }else{
        _initialPosition = LatLng(double.parse(address.latitude!), double.parse(address.longitude!));
        _formTextEditingController.text = address.address??'';
        _fromAddress = address;
      }
      if(mapController != null) {
        mapController.animateCamera(CameraUpdate.newLatLngZoom(_initialPosition, 17));
      }
      update();
    }catch(_){}
    return position;
  }

  Future<void> getCurrentLocation(GoogleMapController? mapController) async {
    AddressModel? address = await Get.find<LocationController>().getCurrentLocation(false, mapController: mapController);
    if(_isFormSelected) {
      _formTextEditingController.text = address.address!;
      setFromAddress(address, mapController);
    }else {
      _toTextEditingController.text = address.address!;
      setToAddress(address, mapController);
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> getZoneList() async {
    List<ZoneDataModel>? zones = await taxiLocationServiceInterface.getZoneList();
    if (zones != null) {
      _zoneList = [];
      _zoneList!.addAll(zones);
    }
    update();
  }

  Future<void> setLocationFromPlace(String? placeID, String? address, bool isFrom, GoogleMapController? mapController) async {
    Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);

    LatLng latLng = await taxiLocationServiceInterface.getPlaceDetails(placeID);

    AddressModel address0 = AddressModel(
      address: address, addressType: 'others', latitude: latLng.latitude.toString(),
      longitude: latLng.longitude.toString(),
      contactPersonName: AddressHelper.getUserAddressFromSharedPref()!.contactPersonName,
      contactPersonNumber: AddressHelper.getUserAddressFromSharedPref()!.contactPersonNumber,
    );
    ZoneResponseModel response0 = await Get.find<LocationController>().getZone(address0.latitude, address0.longitude, false);

    bool inZone = false;
    if(response0.zoneIds.isNotEmpty && isFrom) {
      inZone = await taxiLocationServiceInterface.checkInZone(address0.latitude.toString(), address0.longitude.toString(), response0.zoneIds[0]);
      _inZone = inZone;
    }

    ///create polygon
    await _createPolygon(isFrom ? inZone : true);

    ///Data setup
    if (response0.isSuccess && inZone && isFrom) {
      address0.zoneId =  response0.zoneIds[0];
      address0.zoneIds = [];
      address0.zoneIds!.addAll(response0.zoneIds);
      address0.zoneData = [];
      address0.zoneData!.addAll(response0.zoneData);
      _formTextEditingController.text = address0.address!;

      setFromAddress(address0, mapController);

    } else if(!isFrom) {
      _toTextEditingController.text = address0.address!;
      setToAddress(address0, mapController);

    } else {
      // showCustomSnackBar(response0.message);
    }

    Get.back();
    update();
  }

  Future<void> setFromAddress(AddressModel addressModel, GoogleMapController? mapController) async {
    _fromAddress = addressModel;
    LatLng from = LatLng(double.parse(_fromAddress!.latitude!), double.parse(_fromAddress!.longitude!));

    mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: from, zoom: 17)));

    update();
  }

  Future<void> setToAddress(AddressModel addressModel, GoogleMapController? mapController) async {
    _toAddress = addressModel;
    LatLng to = LatLng(double.parse(_toAddress!.latitude!), double.parse(_toAddress!.longitude!));
    mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: to, zoom: 17)));

    update();
  }

  Future<void> getHistoryAddresses() async {
    _historyAddress = await taxiLocationServiceInterface.getSearchAddresses();

    update();
  }

  Future<void> setSuggestionAddress(AddressModel address, GoogleMapController? mapController) async{
    if(_isFormSelected) {
      _formTextEditingController.text = address.address!;
      setFromAddress(address, mapController);
    }else {
      _toTextEditingController.text = address.address!;
      setToAddress(address, mapController);
    }
  }

  Future<void> setFromToMarker(GoogleMapController? mapController, {required LatLng from, required LatLng to, bool canUpdateProfile = false, UserData? userData, clickFromButton = true, VehicleModel? vehicle, AddressModel? fromAddress}) async {
    // _markers[_myMarkerId] = Marker(markerId: _myMarkerId, visible: false, position: from);
    _isLoading = true;
    if(clickFromButton) {
      update();
    }
    // final Uint8List fromMarkerIcon = await getBytesFromAsset(Images.taxiPickup, 40);
    // final Uint8List toMarkerIcon = await getBytesFromAsset(Images.taxiDestination, 40);
    final BitmapDescriptor fromMarkerIcon = await MarkerHelper.convertAssetToBitmapDescriptor(imagePath: Images.taxiPickup, height: clickFromButton ? 30 : 40);
    final BitmapDescriptor toMarkerIcon = await MarkerHelper.convertAssetToBitmapDescriptor(imagePath: Images.taxiDestination, height: clickFromButton ? 30 : 40);


    _showFromToMarker = true;

    _markers = {};
    Marker fromMarker = Marker(
      markerId: fromMarkerId, position: from,
      infoWindow: InfoWindow(
        title: 'pickup'.tr,
        onTap: () {
          if (kDebugMode) {
            print("Tapped on info window of pickup");
          }
        },
      ),
      icon: fromMarkerIcon,
      // icon: BitmapDescriptor.bytes(fromMarkerIcon),
    );
    _markers.add(fromMarker);
    Marker toMarker = Marker(
      markerId: toMarkerId, position: to,
      infoWindow: InfoWindow(
        title: 'destination'.tr,
        onTap: () {
          if (kDebugMode) {
            print("Tapped on info window of destination");
          }
        },
      ),
      icon: toMarkerIcon,
      // icon: BitmapDescriptor.bytes(toMarkerIcon),
    );
    _markers.add(toMarker);


    if(!clickFromButton) {
      await mapController?.animateCamera(CameraUpdate.newLatLngBounds(_boundsFromLatLngList([from, to]), 150));

    } else {
      try {
        await _placePositionForScreenshot(from: from, to: to, mapController: mapController);
      }catch(e) {
        debugPrint('bound: $e');
      }
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      // mapController?.showMarkerInfoWindow(toMarkerId);
      mapController?.showMarkerInfoWindow(fromMarkerId);
    });

    try{
      await generatePolyLines(from: from, to: to);
    }catch(e) {
      await generatePolyLines(from: from, to: to);
    }


    _distance = -1;
    _duration = -1;
    if(clickFromButton) {
      try {
        _duration = await _getDistanceInKM(from, to, isDuration: true);
        _distance = await _getDistanceInKM(from, to);
      } catch(_) {
        _duration = await _getDistanceInKM(from, to, isDuration: true);
        _distance = await _getDistanceInKM(from, to);
      }

      if(fromAddress != null) {
        _showCartWarning(fromAddress);
      }

    }
    if (kDebugMode) {
      print('--------------distance------ : $_distance');
    }

    // update();

    // return;
    /// Normal flow for address select.
    if(!canUpdateProfile && clickFromButton) {

      if(_distance != null && _distance! > 0) {
        await Future.delayed(const Duration(milliseconds: 600)).then((value) async{
          Uint8List? mapImage = await mapController!.takeSnapshot();
          if(mapImage!= null) {
            _mapScreenshot = mapImage;
            await _setAddressesInSharedPref(_toAddress!);
            if(Get.previousRoute == '/TaxiLocationSuggestionScreen') {
              Get.off(()=> TaxiLocationResultScreen(vehicle: vehicle));
            } else {
              Get.to(() => TaxiLocationResultScreen(vehicle: vehicle));
            }
          }
        });
      } else {
        showCustomSnackBar('locations_can_not_be_same'.tr);
      }


    } else if(userData != null && clickFromButton) { /// User details update..
      CartLocation pick = CartLocation(lat: _fromAddress!.latitude, lng: _fromAddress!.longitude, locationName: _fromAddress!.address, locationType: _fromAddress!.addressType);
      CartLocation destination = CartLocation(lat: _toAddress!.latitude, lng: _toAddress!.longitude, locationName: _toAddress!.address, locationType: _toAddress!.addressType);
      CarCart cart = CarCart(
        applyMethod: true, distance: _distance, destinationTime: userData.destinationTime,
        rentalType: userData.rentalType, estimatedHour: '${userData.estimatedHours??0}',
        pickupLocation: pick, destinationLocation: destination,
      );
      await Get.find<TaxiCartController>().updateUserData(cart: cart, userId: userData.id!).then((success) {
        if(success) {
          initialSetup();
          Get.back();
          Get.find<TaxiCartController>().getCarCartList();
        }
      });
    }
    _isLoading = false;
    update();
  }

  Future<void> _showCartWarning(AddressModel address) async{
    if(address.zoneIds != null && Get.find<TaxiCartController>().cartList.isNotEmpty) {
      List<int>? providerZones = Get.find<TaxiCartController>().cartList[0].provider!.pickupZoneId??[];

      if(!_hasIntersection(providerZones, address.zoneIds!)) {
        showCustomSnackBar('your_cart_has_been_cleared_as_the_selected_zone_does_not_support_the_previous_pickup_point'.tr, showDuration: 10);
      }
    }
  }

  bool _hasIntersection(List<int> list1, List<int> list2) {
    return list1.toSet().intersection(list2.toSet()).isNotEmpty;
  }

  double _getBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dLon = lon2 - lon1;

    if (dLon <= 0 && dLon >= -0.0005) {
      return 90; // If longitude is same, force horizontal direction
    }

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = atan2(y, x);
    return (bearing * 90 / pi + 180) % 180; // Convert to degrees (0-360)
  }

  Future<void> _setAddressesInSharedPref(AddressModel address) async {
    _historyAddress ??= [];

    // Prevent duplicate entries
    _historyAddress!.removeWhere((item) => item.address == address.address);

    // Insert at the beginning
    _historyAddress!.insert(0, address);

    // Keep only the last 5 addresses
    _historyAddress = _historyAddress!.take(5).toList();

    // Save to shared preferences
    await taxiLocationServiceInterface.saveSearchAddress(_historyAddress!);
  }

  Future<List<LatLng>> generatePolyLines({required LatLng from, required LatLng to}) async {
    List<LatLng> polylineCoordinates = [];
    List<LatLng> results = await _getRouteBetweenCoordinates(from, to);
    if (results.isNotEmpty) {
      polylineCoordinates.addAll(results);
    } else {
      showCustomSnackBar('route_not_found'.tr);
    }
    PolylineId polyId = const PolylineId('my_polyline');
    Polyline polyline = Polyline(
      polylineId: polyId,
      points: polylineCoordinates,
      width: 3,
      color: Get.isDarkMode ? Theme.of(Get.context!).primaryColor : Colors.black,
    );
    _polyLines[polyId] = polyline;
    update();
    return polylineCoordinates;
  }

  Future<void> _placePositionForScreenshot({required LatLng from, required LatLng to, GoogleMapController? mapController}) async {
    LatLngBounds? bounds;
    if(mapController != null) {
      bounds = _boundWithMaximumLatLngPoint([from, to]);
    }
    LatLng centerBounds = LatLng(
      (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
      (bounds.northeast.longitude + bounds.southwest.longitude)/2,
    );
    double bearing = _getBearing(from, to);
    mapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      bearing: bearing, target: centerBounds, zoom: 14,
    )));
    _zoomToFit(mapController, bounds, centerBounds, bearing, padding: 2 /*bearing == 90 ? 2 : 1.5*/);
  }

  LatLngBounds _boundWithMaximumLatLngPoint(List<LatLng> list) {
    assert(list.isNotEmpty);
    var firstLatLng = list.first;
    var s = firstLatLng.latitude,
        n = firstLatLng.latitude,
        w = firstLatLng.longitude,
        e = firstLatLng.longitude;
    for (var i = 1; i < list.length; i++) {
      var latlng = list[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }

  Future<void> _zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, double bearing, {double padding = 0.5}) async {
    bool keepZoomingOut = true;
    while(keepZoomingOut) {

      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(_fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
          bearing: bearing,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool _fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > (x1 ?? 0)) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > (y1 ?? 0)) y1 = latLng.longitude;
        if (latLng.longitude < (y0 ?? 0)) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  Future<List<LatLng>> _getRouteBetweenCoordinates(LatLng origin, LatLng destination) async {
    List<LatLng> coordinates = [];
    Response response = await taxiLocationServiceInterface.getRouteBetweenCoordinates(origin, destination);
    if (response.statusCode == 200 && response.body["routes"] != null && response.body["routes"].isNotEmpty) {
      String encodedPolyline = response.body['routes'][0]['polyline']['encodedPolyline'];

      coordinates.addAll(_decodeEncodedPolyline(encodedPolyline));
    }
    return coordinates;
  }

  void updatePosition(LatLng? positionLatLng, bool fromAddress, GoogleMapController? mapController) async {
    if(_updateAddAddressData && positionLatLng != null) {
      _isLoading = true;
      update();

      ZoneResponseModel response0 = await Get.find<LocationController>().getZone(
          positionLatLng.latitude.toString(), positionLatLng.longitude.toString(), false);

      String addressFromGeocode = await Get.find<LocationController>().getAddressFromGeocode(
          LatLng(positionLatLng.latitude, positionLatLng.longitude));

      AddressModel address0 = AddressModel(
        address: addressFromGeocode,
        addressType: 'other',
        latitude: positionLatLng.latitude.toString(),
        longitude: positionLatLng.longitude.toString(),
        contactPersonName: AddressHelper.getUserAddressFromSharedPref()!.contactPersonName,
        contactPersonNumber: AddressHelper.getUserAddressFromSharedPref()!.contactPersonNumber,
      );

      bool inZone = false;
      if(fromAddress) {
        _inZone = false;
      }

      if(response0.zoneIds.isNotEmpty && fromAddress) {
        inZone = await taxiLocationServiceInterface.checkInZone(address0.latitude.toString(), address0.longitude.toString(), response0.zoneIds[0]);
        _inZone = inZone;
      }

      ///create polygon
      await _createPolygon(fromAddress ? inZone : true);

      ///Data setup
      if (response0.isSuccess && inZone && fromAddress) {
        address0.zoneId = response0.zoneIds[0];
        address0.zoneIds = [];
        address0.zoneIds!.addAll(response0.zoneIds);
        address0.zoneData = [];
        address0.zoneData!.addAll(response0.zoneData);
        _formTextEditingController.text = address0.address!;
        _fromAddress = address0;

      } else if(!fromAddress) {
        _toTextEditingController.text = address0.address!;
        _toAddress = address0;

      } else {
        // showCustomSnackBar(response0.message);
      }
    } else {
      _updateAddAddressData = true;
    }

    _buttonDisabled = false;
    _isLoading = false;
    update();
  }

  _createPolygon(bool inZone) async{
    if(inZone) {
      _polygons = {};
      update();
    } else {
      List<Polygon> polygonList = [];
      List<List<LatLng>> zoneLatLongList = [];

      for (var zoneModel in _zoneList!) {
        zoneLatLongList.add([]);
        zoneModel.formatedCoordinates?.forEach((coordinate) {
          zoneLatLongList[_zoneList!.indexOf(zoneModel)].add(LatLng(coordinate.lat!, coordinate.lng!));
        });
      }

      for (var zonesLatLng in zoneLatLongList) {
        polygonList.add(
          Polygon(
            polygonId: PolygonId('${zoneLatLongList.indexOf(zonesLatLng)}'),
            points: zonesLatLng,
            strokeWidth: 2,
            strokeColor: Get.theme.colorScheme.primary,
            fillColor: Get.theme.colorScheme.primary.withValues(alpha: .2),
          ),
        );
      }

      _polygons = HashSet<Polygon>.of(polygonList);
      update();
    }

  }

  List<LatLng> _decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  void selectFilterBrand(int index) {
    _filterBrandIndex = index;
    update();
  }

  void selectVehicleType(int index) {
    _filterVehicleTypeIndex = index;
    update();
  }

  void selectSeat(int index) {
    _filterSeatIndex = index;
    update();
  }

  void selectColling(int index) {
    _filterColling = index;
    update();
  }

  Future<double?> _getDistanceInKM(LatLng originLatLng, LatLng destinationLatLng, {bool isDuration = false}) async {
    _distance = -1;
    Response response = await taxiLocationServiceInterface.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.statusCode == 200 && response.statusText == 'OK') {
        if(isDuration){
          final String duration = response.body['duration'] as String;
          double parsedDuration = parseDuration(duration);
          _distance = parsedDuration / 3600;
        }else{
          final double distanceMater = response.body['distanceMeters']?.toDouble();
          _distance = distanceMater / 1000;
        }
      } else {
        if(!isDuration) {
          _distance = Geolocator.distanceBetween(originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude) / 1000;
        }
      }
    } catch (e) {
      if(!isDuration) {
        _distance = Geolocator.distanceBetween(originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude) / 1000;
      }
    }
    update();
    return _distance;
  }

  double parseDuration(String duration) {
    return double.tryParse(duration.replaceAll('s', '')) ?? 0.0;
  }

}