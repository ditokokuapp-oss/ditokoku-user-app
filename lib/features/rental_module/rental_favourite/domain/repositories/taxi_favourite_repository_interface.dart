import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class TaxiFavouriteRepositoryInterface extends RepositoryInterface {
  @override
  Future<ResponseModel> delete(int? id, {bool isProvider = false});
  Future<ResponseModel> addVehicleFavouriteList(int id, bool isProvider);
}