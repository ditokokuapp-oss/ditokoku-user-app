class VehicleModelRemove {
  final String? image;
  final int? quantity;
  final String? carName;
  final String? companyName;
  final double? rating;
  final String? hasAC;
  final String? carType;
  final int? seats;
  final double? discountPercentage;

  VehicleModelRemove({
    required this.image,
    required this.quantity,
    required this.carName,
    required this.companyName,
    required this.rating,
    required this.hasAC,
    required this.carType,
    required this.seats,
    required this.discountPercentage,
  });
}

class TripVehicleDialogModel {
  final String? image;
  final String? carName;
  final String? rentType;
  final double? previousPrice;
  final double? currentPrice;
  final String? distance;
  final String? iconLogo;

  TripVehicleDialogModel({
    required this.image,
    required this.carName,
    required this.rentType,
    required this.currentPrice,
    required this.previousPrice,
    required this.distance,
    required this.iconLogo,
  });
}

class VehicleDetailsModel {
  final String? image;
  final String? featureName;

  VehicleDetailsModel({
    required this.image,
    required this.featureName,
  });
}


