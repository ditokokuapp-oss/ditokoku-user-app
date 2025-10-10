class CarCart {
  int? vehicleId;
  int? quantity;
  CartLocation? pickupLocation;
  CartLocation? destinationLocation;
  String? pickupTime;
  String? rentalType;
  String? estimatedHour;
  double? destinationTime;
  double? distance;
  bool? applyMethod;

  CarCart({
    this.vehicleId,
    this.quantity,
    this.pickupLocation,
    this.destinationLocation,
    this.pickupTime,
    this.rentalType,
    this.estimatedHour,
    this.destinationTime,
    this.distance,
    this.applyMethod = false,
  });

  CarCart.fromJson(Map<String, dynamic> json) {
    vehicleId = json['vehicle_id'];
    quantity = json['quantity'];
    pickupLocation = json['pickup_location'] != null ? CartLocation.fromJson(json['pickup_location']) : null;
    destinationLocation = json['destination_location'] != null ? CartLocation.fromJson(json['destination_location']) : null;
    pickupTime = json['pickup_time'];
    rentalType = json['rental_type'];
    estimatedHour = json['estimated_hours'];
    destinationTime = json['destination_time'];
    distance = json['distance'];
    applyMethod = json['method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if(applyMethod!) {
      data['_method'] = 'PUT';
    }
    if(vehicleId != null) {
      data['vehicle_id'] = vehicleId;
    }
    if(quantity != null) {
    data['quantity'] = quantity;
    }
    if(pickupLocation != null) {
      data['pickup_location'] = pickupLocation!.toJson();
    }
    if(destinationLocation != null) {
      data['destination_location'] = destinationLocation!.toJson();
    }
    if(pickupTime != null) {
      data['pickup_time'] = pickupTime;
    }
    if(rentalType != null) {
      data['rental_type'] = rentalType;
    }
    if(estimatedHour != null) {
      data['estimated_hours'] = estimatedHour;
    }
    if(destinationTime != null) {
      data['destination_time'] = destinationTime;
    }
    if(distance != null) {
      data['distance'] = distance;
    }
    return data;
  }
}

class CartLocation {
  String? lat;
  String? lng;
  String? locationName;
  String? locationType;

  CartLocation({
    this.lat,
    this.lng,
    this.locationName,
    this.locationType,
  });

  CartLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
    locationName = json['location_name'];
    locationType = json['location_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    data['location_name'] = locationName;
    data['location_type'] = locationType;
    return data;
  }
}