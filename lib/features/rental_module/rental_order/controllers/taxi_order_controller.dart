import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_model.dart';
import 'package:sixam_mart/features/rental_module/rental_order/domain/services/taxi_order_service_interface.dart';
import 'package:sixam_mart/features/rental_module/rental_order/screens/taxi_payment_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

class TaxiOrderController extends GetxController implements GetxService {
  final TaxiOrderServiceInterface taxiOrderServiceInterface;

  TaxiOrderController({required this.taxiOrderServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TripModel? _tripModel;
  TripModel? get tripModel => _tripModel;

  TripModel? _tripHistoryModel;
  TripModel? get tripHistoryModel => _tripHistoryModel;

  TripDetailsModel? _tripDetailsModel;
  TripDetailsModel? get tripDetailsModel => _tripDetailsModel;

  int _paymentMethodIndex = -1;
  int get paymentMethodIndex => _paymentMethodIndex;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  bool _isPartialPay = false;
  bool get isPartialPay => _isPartialPay;

  void setPaymentMethod(int index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    if(isUpdate){
      update();
    }
  }

  void changeDigitalPaymentName(String name, {bool willUpdate = true}){
    _digitalPaymentName = name;
    if(willUpdate) {
      update();
    }
  }

  void changePartialPayment({bool isUpdate = true}){
    _isPartialPay = !_isPartialPay;
    if(isUpdate) {
      update();
    }
  }

  Future<void> getTripList(int offset, {bool isUpdate = false, bool isRunning = true, bool fromHome = false}) async {
    if(offset == 1) {
      if(isRunning) {
        _tripModel = null;
      } else {
        if(!fromHome) {
          _tripHistoryModel = null;
        }
      }
      if(isUpdate) {
        update();
      }
    }
    TripModel? tripModel = await taxiOrderServiceInterface.getTripList(offset: offset, type: isRunning ? 'running' : 'completed');
    if (tripModel != null) {
      if (offset == 1) {
        if(isRunning) {
          _tripModel = tripModel;
        } else {
          _tripHistoryModel = tripModel;
        }
      }else {
        if(isRunning) {
          _tripModel!.totalSize = tripModel.totalSize;
          _tripModel!.offset = tripModel.offset;
          _tripModel!.trips!.addAll(tripModel.trips!);
        } else {
          _tripHistoryModel!.totalSize = tripModel.totalSize;
          _tripHistoryModel!.offset = tripModel.offset;
          _tripHistoryModel!.trips!.addAll(tripModel.trips!);
        }
      }
    }
    update();
  }

  Future<bool> getTripDetails(int id, {bool willUpdate = true, String? phone}) async {
    _isLoading = true;
    _tripDetailsModel = null;
    if(willUpdate) {
      update();
    }
    _tripDetailsModel = await taxiOrderServiceInterface.getTripDetails(id: id, phone: phone);

    _isLoading = false;
    update();
    return _tripDetailsModel != null;
  }

  Future<bool> cancelTrip({required int id}) async {
    _isLoading = true;
    update();
    bool success = await taxiOrderServiceInterface.cancelTrip(id: id);
    _isLoading = false;
    update();
    return success;
  }

  Future<bool> makePayment({required int id, required String paymentMethod}) async {
    _isLoading = true;
    update();

    if(isPartialPay) {
      if(_paymentMethodIndex == 1) {
        _digitalPaymentName = 'cash_payment';
      }
    }
    Response response = await taxiOrderServiceInterface.makeTripPayment(id: id, paymentMethod: paymentMethod, paymentGateWayName: _digitalPaymentName);
    if(response.statusCode == 200 && _paymentMethodIndex == 2) {
      Get.back();
      Get.to(()=> TaxiPaymentScreen(paymentUrl: response.body, orderId: id));
    }
    if(AuthHelper.isLoggedIn()) {
      Get.find<ProfileController>().getUserInfo();
    }
    _isLoading = false;
    update();
    return response.statusCode == 200 && _paymentMethodIndex != 2;
  }

  Future<bool> addVehicleReview({required int tripId, required int vehicleId, required int vehicleIdentityId, required int rating, required String comment}) async {
    _isLoading = true;
    update();
    bool success = await taxiOrderServiceInterface.addVehicleReview(tripId: tripId, vehicleId: vehicleId, vehicleIdentityId: vehicleIdentityId, rating: rating, comment: comment);
    _isLoading = false;
    update();
    return success;
  }

}