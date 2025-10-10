import 'package:sixam_mart/features/rental_module/home/domain/models/vehicle_details_model.dart';

class CarCartModel {
  List<Carts>? carts;
  UserData? userData;

  CarCartModel({this.carts, this.userData});

  CarCartModel.fromJson(Map<String, dynamic> json) {
    if (json['carts'] != null) {
      carts = <Carts>[];
      json['carts'].forEach((v) {
        carts!.add(Carts.fromJson(v));
      });
    }
    userData = json['user_data'] != null && json['user_data'] != '[]' && json['user_data']?.isNotEmpty
        ? UserData.fromJson(json['user_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (carts != null) {
      data['carts'] = carts!.map((v) => v.toJson()).toList();
    }
    if (userData != null) {
      data['user_data'] = userData!.toJson();
    }
    return data;
  }
}

class Carts {
  int? id;
  int? providerId;
  int? userId;
  int? vehicleId;
  int? moduleId;
  int? quantity;
  int? isGuest;
  String? createdAt;
  String? updatedAt;
  VehicleModel? vehicle;
  Provider? provider;

  Carts(
      {this.id,
        this.providerId,
        this.userId,
        this.vehicleId,
        this.moduleId,
        this.quantity,
        this.isGuest,
        this.createdAt,
        this.updatedAt,
        this.vehicle,
        this.provider});

  Carts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    userId = json['user_id'];
    vehicleId = json['vehicle_id'];
    moduleId = json['module_id'];
    quantity = json['quantity'];
    isGuest = json['is_guest'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    vehicle = json['vehicle'] != null
        ? VehicleModel.fromJson(json['vehicle'])
        : null;
    provider = json['provider'] != null
        ? Provider.fromJson(json['provider'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['user_id'] = userId;
    data['vehicle_id'] = vehicleId;
    data['module_id'] = moduleId;
    data['quantity'] = quantity;
    data['is_guest'] = isGuest;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (vehicle != null) {
      data['vehicle'] = vehicle!.toJson();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    return data;
  }
}

class Provider {
  int? id;
  String? name;
  double? tax;
  List<int>? pickupZoneId;
  bool? gstStatus;
  String? gstCode;
  String? logoFullUrl;
  String? coverPhotoFullUrl;
  String? metaImageFullUrl;
  Discount? discount;
  List<Translations>? translations;
  List<Storage>? storage;

  Provider({
    this.id,
    this.name,
    this.tax,
    this.pickupZoneId,
    this.gstStatus,
    this.gstCode,
    this.logoFullUrl,
    this.coverPhotoFullUrl,
    this.metaImageFullUrl,
    this.discount,
    this.translations,
    this.storage,
  });

  Provider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tax = json['tax']?.toDouble();
    if(json['pickup_zone_id'] != null){
      json['pickup_zone_id'].forEach((zone) {
        pickupZoneId = [];
        pickupZoneId!.add(int.parse(zone.toString()));
      });
    }
    gstStatus = json['gst_status'];
    gstCode = json['gst_code'];
    logoFullUrl = json['logo_full_url'];
    coverPhotoFullUrl = json['cover_photo_full_url'];
    metaImageFullUrl = json['meta_image_full_url'];
    discount = json['discount'] != null
        ? Discount.fromJson(json['discount'])
        : null;
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
    if (json['storage'] != null) {
      storage = <Storage>[];
      json['storage'].forEach((v) {
        storage!.add(Storage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['tax'] = tax;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['logo_full_url'] = logoFullUrl;
    data['cover_photo_full_url'] = coverPhotoFullUrl;
    data['meta_image_full_url'] = metaImageFullUrl;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (storage != null) {
      data['storage'] = storage!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Discount {
  int? id;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  int? storeId;
  String? createdAt;
  String? updatedAt;

  Discount({
    this.id,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.minPurchase,
    this.maxDiscount,
    this.discount,
    this.discountType,
    this.storeId,
    this.createdAt,
    this.updatedAt,
  });

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    minPurchase = json['min_purchase']?.toDouble();
    maxDiscount = json['max_discount']?.toDouble();
    discount = json['discount']?.toDouble();
    discountType = json['discount_type'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['store_id'] = storeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Translations {
  int? id;
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Translations(
      {this.id,
        this.translationableType,
        this.translationableId,
        this.locale,
        this.key,
        this.value,
        this.createdAt,
        this.updatedAt});

  Translations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Storage {
  int? id;
  String? dataType;
  String? dataId;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Storage(
      {this.id,
        this.dataType,
        this.dataId,
        this.key,
        this.value,
        this.createdAt,
        this.updatedAt});

  Storage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dataType = json['data_type'];
    dataId = json['data_id'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['data_type'] = dataType;
    data['data_id'] = dataId;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class UserData {
  int? id;
  int? userId;
  PickupLocation? pickupLocation;
  PickupLocation? destinationLocation;
  String? pickupTime;
  String? rentalType;
  double? estimatedHours;
  double? distance;
  double? totalCartPrice;
  double? destinationTime;
  int? isGuest;
  String? createdAt;
  String? updatedAt;

  UserData(
      {this.id,
        this.userId,
        this.pickupLocation,
        this.destinationLocation,
        this.pickupTime,
        this.rentalType,
        this.estimatedHours,
        this.distance,
        this.totalCartPrice,
        this.destinationTime,
        this.isGuest,
        this.createdAt,
        this.updatedAt});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    pickupLocation = json['pickup_location'] != null
        ? PickupLocation.fromJson(json['pickup_location'])
        : null;
    destinationLocation = json['destination_location'] != null
        ? PickupLocation.fromJson(json['destination_location'])
        : null;
    pickupTime = json['pickup_time'];
    rentalType = json['rental_type'];
    estimatedHours = json['estimated_hours']?.toDouble();
    distance = json['distance']?.toDouble();
    totalCartPrice = json['total_cart_price']?.toDouble();
    destinationTime = json['destination_time']?.toDouble();
    isGuest = json['is_guest'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    if (pickupLocation != null) {
      data['pickup_location'] = pickupLocation!.toJson();
    }
    if (destinationLocation != null) {
      data['destination_location'] = destinationLocation!.toJson();
    }
    data['pickup_time'] = pickupTime;
    data['rental_type'] = rentalType;
    data['estimated_hours'] = estimatedHours;
    data['distance'] = distance;
    data['destination_time'] = destinationTime;
    data['is_guest'] = isGuest;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class PickupLocation {
  String? lat;
  String? lng;
  String? locationName;
  String? locationType;

  PickupLocation({this.lat, this.lng, this.locationName, this.locationType});

  PickupLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat']?.toString();
    lng = json['lng']?.toString();
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