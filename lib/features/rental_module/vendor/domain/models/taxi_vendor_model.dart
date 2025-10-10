class TaxiVendorModel {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? logo;
  String? latitude;
  String? longitude;
  String? address;
  int? minimumOrder;
  bool? scheduleOrder;
  int? status;
  int? vendorId;
  String? createdAt;
  String? updatedAt;
  bool? freeDelivery;
  String? coverPhoto;
  bool? delivery;
  bool? takeAway;
  bool? itemSection;
  double? tax;
  int? zoneId;
  bool? reviewsSection;
  bool? active;
  String? offDay;
  int? selfDeliverySystem;
  bool? posSystem;
  int? minimumShippingCharge;
  String? deliveryTime;
  int? veg;
  int? nonVeg;
  int? orderCount;
  int? totalOrder;
  int? moduleId;
  int? orderPlaceToScheduleInterval;
  int? featured;
  int? perKmShippingCharge;
  bool? prescriptionOrder;
  String? slug;
  // Null? maximumShippingCharge;
  // bool? cutlery;
  // Null? metaTitle;
  // Null? metaDescription;
  // Null? metaImage;
  int? announcement;
  String? announcementMessage;
  String? storeBusinessModel;
  // Null? packageId;
  // Null? pickupZoneId;
  // Null? comment;
  bool? isRecommended;
  int? minimumStockForWarning;
  bool? halalTagStatus;
  // Null? extraPackagingStatus;
  int? extraPackagingAmount;
  List<int>? ratings;
  double? avgRating;
  int? ratingCount;
  double? positiveRating;
  // Null? totalItems;
  // Null? totalCampaigns;
  String? currentOpeningTime;
  bool? gstStatus;
  String? gstCode;
  String? logoFullUrl;
  String? coverPhotoFullUrl;
  // Null? metaImageFullUrl;
  Discount? discount;
  List<Translations>? translations;
  List<Storage>? storage;
  Module? module;
  List<Schedules>? schedules;

  TaxiVendorModel(
      {this.id,
        this.name,
        this.phone,
        this.email,
        this.logo,
        this.latitude,
        this.longitude,
        this.address,
        this.minimumOrder,
        this.scheduleOrder,
        this.status,
        this.vendorId,
        this.createdAt,
        this.updatedAt,
        this.freeDelivery,
        this.coverPhoto,
        this.delivery,
        this.takeAway,
        this.itemSection,
        this.tax,
        this.zoneId,
        this.reviewsSection,
        this.active,
        this.offDay,
        this.selfDeliverySystem,
        this.posSystem,
        this.minimumShippingCharge,
        this.deliveryTime,
        this.veg,
        this.nonVeg,
        this.orderCount,
        this.totalOrder,
        this.moduleId,
        this.orderPlaceToScheduleInterval,
        this.featured,
        this.perKmShippingCharge,
        this.prescriptionOrder,
        this.slug,
        // this.maximumShippingCharge,
        // this.cutlery,
        // this.metaTitle,
        // this.metaDescription,
        // this.metaImage,
        this.announcement,
        this.announcementMessage,
        this.storeBusinessModel,
        // this.packageId,
        // this.pickupZoneId,
        // this.comment,
        this.isRecommended,
        this.minimumStockForWarning,
        this.halalTagStatus,
        // this.extraPackagingStatus,
        this.extraPackagingAmount,
        this.ratings,
        this.avgRating,
        this.ratingCount,
        this.positiveRating,
        // this.totalItems,
        // this.totalCampaigns,
        this.currentOpeningTime,
        this.gstStatus,
        this.gstCode,
        this.logoFullUrl,
        this.coverPhotoFullUrl,
        // this.metaImageFullUrl,
        this.discount,
        this.translations,
        this.storage,
        this.module,
        this.schedules});

  TaxiVendorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    logo = json['logo'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    // footerText = json['footer_text'];
    minimumOrder = json['minimum_order'];
    // comission = json['comission'];
    scheduleOrder = json['schedule_order'];
    status = json['status'];
    vendorId = json['vendor_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    freeDelivery = json['free_delivery'];
    coverPhoto = json['cover_photo'];
    delivery = json['delivery'];
    takeAway = json['take_away'];
    itemSection = json['item_section'];
    tax = json['tax']?.toDouble();
    zoneId = json['zone_id'];
    reviewsSection = json['reviews_section'];
    active = json['active'];
    offDay = json['off_day'];
    selfDeliverySystem = json['self_delivery_system'];
    posSystem = json['pos_system'];
    minimumShippingCharge = json['minimum_shipping_charge'];
    deliveryTime = json['delivery_time'];
    veg = json['veg'];
    nonVeg = json['non_veg'];
    orderCount = json['order_count'];
    totalOrder = json['total_order'];
    moduleId = json['module_id'];
    orderPlaceToScheduleInterval = json['order_place_to_schedule_interval'];
    featured = json['featured'];
    perKmShippingCharge = json['per_km_shipping_charge'];
    prescriptionOrder = json['prescription_order'];
    slug = json['slug'];
    // maximumShippingCharge = json['maximum_shipping_charge'];
    // cutlery = json['cutlery'];
    // metaTitle = json['meta_title'];
    // metaDescription = json['meta_description'];
    // metaImage = json['meta_image'];
    announcement = json['announcement'];
    announcementMessage = json['announcement_message'];
    storeBusinessModel = json['store_business_model'];
    // packageId = json['package_id'];
    // pickupZoneId = json['pickup_zone_id'];
    // comment = json['comment'];
    isRecommended = json['is_recommended'];
    minimumStockForWarning = json['minimum_stock_for_warning'];
    halalTagStatus = json['halal_tag_status'];
    // extraPackagingStatus = json['extra_packaging_status'];
    extraPackagingAmount = json['extra_packaging_amount'];
    ratings = json['ratings'].cast<int>();
    avgRating = json['avg_rating']?.toDouble();
    ratingCount = json['rating_count'];
    positiveRating = json['positive_rating']?.toDouble();
    // totalItems = json['total_items'];
    // totalCampaigns = json['total_campaigns'];
    currentOpeningTime = json['current_opening_time'];
    gstStatus = json['gst_status'];
    gstCode = json['gst_code'];
    logoFullUrl = json['logo_full_url'];
    coverPhotoFullUrl = json['cover_photo_full_url'];
    // metaImageFullUrl = json['meta_image_full_url'];
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
    module = json['module'] != null ? Module.fromJson(json['module']) : null;
    if (json['schedules'] != null) {
      schedules = <Schedules>[];
      json['schedules'].forEach((v) {
        schedules!.add(Schedules.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['logo'] = logo;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    // data['footer_text'] = this.footerText;
    data['minimum_order'] = minimumOrder;
    // data['comission'] = this.comission;
    data['schedule_order'] = scheduleOrder;
    data['status'] = status;
    data['vendor_id'] = vendorId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['free_delivery'] = freeDelivery;
    data['cover_photo'] = coverPhoto;
    data['delivery'] = delivery;
    data['take_away'] = takeAway;
    data['item_section'] = itemSection;
    data['tax'] = tax;
    data['zone_id'] = zoneId;
    data['reviews_section'] = reviewsSection;
    data['active'] = active;
    data['off_day'] = offDay;
    data['self_delivery_system'] = selfDeliverySystem;
    data['pos_system'] = posSystem;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['delivery_time'] = deliveryTime;
    data['veg'] = veg;
    data['non_veg'] = nonVeg;
    data['order_count'] = orderCount;
    data['total_order'] = totalOrder;
    data['module_id'] = moduleId;
    data['order_place_to_schedule_interval'] =
        orderPlaceToScheduleInterval;
    data['featured'] = featured;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['prescription_order'] = prescriptionOrder;
    data['slug'] = slug;
    // data['maximum_shipping_charge'] = this.maximumShippingCharge;
    // data['cutlery'] = this.cutlery;
    // data['meta_title'] = this.metaTitle;
    // data['meta_description'] = this.metaDescription;
    // data['meta_image'] = this.metaImage;
    data['announcement'] = announcement;
    data['announcement_message'] = announcementMessage;
    data['store_business_model'] = storeBusinessModel;
    // data['package_id'] = this.packageId;
    // data['pickup_zone_id'] = this.pickupZoneId;
    // data['comment'] = this.comment;
    data['is_recommended'] = isRecommended;
    data['minimum_stock_for_warning'] = minimumStockForWarning;
    data['halal_tag_status'] = halalTagStatus;
    // data['extra_packaging_status'] = this.extraPackagingStatus;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['ratings'] = ratings;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['positive_rating'] = positiveRating;
    // data['total_items'] = this.totalItems;
    // data['total_campaigns'] = this.totalCampaigns;
    data['current_opening_time'] = currentOpeningTime;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['logo_full_url'] = logoFullUrl;
    data['cover_photo_full_url'] = coverPhotoFullUrl;
    // data['meta_image_full_url'] = this.metaImageFullUrl;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (storage != null) {
      data['storage'] = storage!.map((v) => v.toJson()).toList();
    }
    if (module != null) {
      data['module'] = module!.toJson();
    }
    if (schedules != null) {
      data['schedules'] = schedules!.map((v) => v.toJson()).toList();
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

  Discount(
      {this.id,
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
        this.updatedAt});

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

class Schedules {
  int? id;
  int? storeId;
  int? day;
  String? openingTime;
  String? closingTime;
  String? createdAt;
  String? updatedAt;

  Schedules(
      {this.id,
        this.storeId,
        this.day,
        this.openingTime,
        this.closingTime,
        this.createdAt,
        this.updatedAt});

  Schedules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    day = json['day'];
    openingTime = json['opening_time'];
    closingTime = json['closing_time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_id'] = storeId;
    data['day'] = day;
    data['opening_time'] = openingTime;
    data['closing_time'] = closingTime;
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
  // Null? createdAt;
  // Null? updatedAt;

  Translations(
      {this.id,
        this.translationableType,
        this.translationableId,
        this.locale,
        this.key,
        this.value,
        // this.createdAt,
        // this.updatedAt
      });

  Translations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    // createdAt = json['created_at'];
    // updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    // data['created_at'] = createdAt;
    // data['updated_at'] = updatedAt;
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

class Module {
  int? id;
  String? moduleName;
  String? moduleType;
  String? thumbnail;
  String? status;
  int? storesCount;
  String? createdAt;
  String? updatedAt;
  String? icon;
  int? themeId;
  String? description;
  int? allZoneService;
  String? iconFullUrl;
  String? thumbnailFullUrl;
  List<Null>? storage;
  List<Translations>? translations;

  Module(
      {this.id,
        this.moduleName,
        this.moduleType,
        this.thumbnail,
        this.status,
        this.storesCount,
        this.createdAt,
        this.updatedAt,
        this.icon,
        this.themeId,
        this.description,
        this.allZoneService,
        this.iconFullUrl,
        this.thumbnailFullUrl,
        this.storage,
        this.translations});

  Module.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleName = json['module_name'];
    moduleType = json['module_type'];
    thumbnail = json['thumbnail'];
    status = json['status'];
    storesCount = json['stores_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    icon = json['icon'];
    themeId = json['theme_id'];
    description = json['description'];
    allZoneService = json['all_zone_service'];
    iconFullUrl = json['icon_full_url'];
    thumbnailFullUrl = json['thumbnail_full_url'];
    // if (json['storage'] != null) {
    //   storage = <Null>[];
    //   json['storage'].forEach((v) {
    //     storage!.add(Null.fromJson(v));
    //   });
    // }
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['module_name'] = moduleName;
    data['module_type'] = moduleType;
    data['thumbnail'] = thumbnail;
    data['status'] = status;
    data['stores_count'] = storesCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['icon'] = icon;
    data['theme_id'] = themeId;
    data['description'] = description;
    data['all_zone_service'] = allZoneService;
    data['icon_full_url'] = iconFullUrl;
    data['thumbnail_full_url'] = thumbnailFullUrl;
    // if (storage != null) {
    //   data['storage'] = storage!.map((v) => v.toJson()).toList();
    // }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
