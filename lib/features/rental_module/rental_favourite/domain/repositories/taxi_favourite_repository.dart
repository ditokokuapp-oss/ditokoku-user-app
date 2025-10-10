import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/domain/repositories/taxi_favourite_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class TaxiFavouriteRepository implements TaxiFavouriteRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  TaxiFavouriteRepository({required this.sharedPreferences, required this.apiClient});
  

  @override
  Future<ResponseModel> addVehicleFavouriteList(int id, bool isProvider) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData('${AppConstants.addTaxiWishListUri}?${isProvider ? 'provider_id=' : 'vehicle_id='}$id', null, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> delete(int? id, {bool isProvider = false}) async {
    ResponseModel responseModel;
    Response response = await apiClient.deleteData('${AppConstants.removeTaxiWishListUri}?${isProvider ? 'provider_id=' : 'vehicle_id='}$id', handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<Response> getList({int? offset}) async {
    return await apiClient.getData(AppConstants.getTaxiWishListUri);
  }

  @override
  Future get(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }
}